package com.tripan.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.DefaultUriBuilderFactory;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;

/**
 * KTO 한국관광공사 Open API 동기화 서비스
 *
 * 수정 내역:
 *  [1] firstimage 빈 문자열 방지
 *      - KTO areaBasedList2 응답에서 firstimage 필드는 optional(0)
 *        → 없으면 null 또는 ""로 옴 → asText()로 ""를 저장하면 이미지 없는 카드 생성됨
 *      - 수정: firstimage가 비어 있으면 image_url을 null로 저장
 *              → PlaceMapper.xml의 image_url IS NOT NULL AND image_url != '' 조건으로 필터됨
 *
 *  [2] 숙박(contentTypeId=32) accommodation 테이블 분리 저장
 *      - 기존: insertPlace()로 place 테이블만 INSERT
 *      - 수정: detailIntro2 API로 체크인/아웃 시간 추가 조회 후 accommodation에도 INSERT
 *
 *  [3] 배치 대상 contentType 정리
 *      - "숙소/축제 외 나머지" 가져오기
 *      - 현재 배치: 12(관광), 14(문화), 32(숙박), 38(쇼핑), 39(식당), 28(레포츠)
 *      - 축제(15)는 festival 테이블이 별도로 있으므로 PlaceServiceImpl에서 제외
 *      - 숙박(32)은 DB에 이미 있으므로 배치에서 스킵 가능 — 환경에 따라 조절
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PlaceServiceImpl implements PlaceService {

    private final PlaceMapper  placeMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${tripan.api.kto-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kto-base-url}")
    private String baseUrl;

    // ── 추천 장소 (DB 캐싱 조회) ────────────────────────────────
    @Override
    public List<PlaceDto> getRecommendPlaces(String category, String cityKeyword, int limit) {
        log.info("[PlaceService] 추천 조회 - category:{}, city:{}", category, cityKeyword);
        List<String> cityList = cityKeyword.isBlank()
            ? List.of()
            : List.of(cityKeyword.split(","));
        // offset=0, limit으로 기본 조회 (서비스 직접 호출 시)
        return placeMapper.selectRecommendPlaces(category, cityList, limit, 0);
    }

    // ── 배치 동기화 (매일 새벽 3시) ─────────────────────────────
    @Override
    @Transactional
    @Scheduled(cron = "0 0 3 * * ?")
    public void syncPlacesBatch() {
        log.info("======== [KTO Sync] 배치 시작 ========");

        // ★ 숙소(32)는 이미 DB에 있으므로 배치에서 제외
        //   축제(15)는 festival 별도 테이블 관리 → 제외
        //   나머지: 관광(12), 문화(14), 쇼핑(38), 식당(39), 레포츠(28)
        String[] contentTypes = {"12", "14", "38", "39", "28"};
        int totalSaved = 0;

        for (String cTypeId : contentTypes) {
            totalSaved += fetchAndSaveByCategory(cTypeId);
        }

        log.info("======== [KTO Sync] 배치 종료 (신규 {}건) ========", totalSaved);
    }

    private int fetchAndSaveByCategory(String contentTypeId) {
        int savedCount = 0;
        int pageNo = 1;
        int numOfRows = 800; 
        boolean hasNextPage = true;

        while (hasNextPage) {
            URI listUri = buildBaseUri("/areaBasedList2")
                    .queryParam("contentTypeId", contentTypeId)
                    .queryParam("numOfRows", String.valueOf(numOfRows))
                    .queryParam("pageNo",    String.valueOf(pageNo)) // 동적 페이지 순회
                    .queryParam("arrange",   "Q") // 수정일 순
                    .build(true).toUri();

            try {
                log.info("[KTO Sync] 카테고리 {} - {}페이지 요청 중... (단위: {}개)", contentTypeId, pageNo, numOfRows);
                
                String listResponse = new RestTemplate().getForObject(listUri, String.class);
                JsonNode items = objectMapper.readTree(listResponse)
                        .path("response").path("body").path("items").path("item");

                // 더 이상 가져올 데이터가 없으면 무한루프 종료
                if (items.isMissingNode() || !items.isArray() || items.isEmpty()) {
                    log.info("[KTO Sync] 카테고리 {} - 데이터 적재 완료. (종료)", contentTypeId);
                    hasNextPage = false;
                    break;
                }

                for (JsonNode item : items) {
                    String contentId = item.path("contentid").asText();

                    // DB 중복 체크
                    if (placeMapper.findPlaceIdByApiContentId(contentId) != null) continue;

                    PlaceDto dto = buildPlaceDto(contentId, contentTypeId, item);
                    if (dto == null) continue;

                    // 단건 INSERT 실행
                    placeMapper.insertKtoPlace(dto);
                    
                    if ("32".equals(contentTypeId)) {
                        fetchAndSaveAccommodationDetail(contentId, dto);
                    }
                    savedCount++;
                }

                pageNo++; // 다음 페이지로 이동
                
                // 공공 API Rate Limit (호출 제한) 및 서버 부하 방어를 위해 0.5초 대기
                Thread.sleep(500); 

            } catch (Exception e) {
                log.error("[KTO Sync] 오류 발생 - contentTypeId:{}, pageNo:{}", contentTypeId, pageNo, e);
                hasNextPage = false; // 안전을 위해 해당 카테고리 순회 중단
            }
        }
        return savedCount;
    }

    private PlaceDto buildPlaceDto(String contentId, String contentTypeId, JsonNode listItem) {
        PlaceDto dto = new PlaceDto();
        dto.setPlaceId(Long.valueOf(contentId));
        dto.setPlaceName(listItem.path("title").asText());
        dto.setAddress(listItem.path("addr1").asText());
        dto.setLatitude(listItem.path("mapy").asDouble());
        dto.setLongitude(listItem.path("mapx").asDouble());

        // [1] ★ firstimage 빈 문자열 방지
        String img = listItem.path("firstimage").asText("").trim();
        dto.setImageUrl(img.isEmpty() ? null : img);

        dto.setCategory(mapContentTypeToCategory(contentTypeId));

        // 상세 조회 (전화번호, 개요)
        try {
            URI detailUri = buildBaseUri("/detailCommon2")
                    .queryParam("contentId",   contentId)
                    .queryParam("defaultYN",   "Y")
                    .queryParam("overviewYN",  "Y")
                    .build(true).toUri();

            String   detailRes  = new RestTemplate().getForObject(detailUri, String.class);
            JsonNode detailItem = objectMapper.readTree(detailRes)
                    .path("response").path("body").path("items").path("item").get(0);

            if (detailItem != null && !detailItem.isMissingNode()) {
                dto.setPhoneNumber(detailItem.path("tel").asText("").trim());
                dto.setDescription(detailItem.path("overview").asText("").trim());
            }
        } catch (Exception e) {
            log.warn("[KTO Sync] 상세 조회 실패 - contentId:{}", contentId);
        }

        return dto;
    }

    /** 숙박 accommodation 테이블에 체크인/아웃 시간 저장 */
    private void fetchAndSaveAccommodationDetail(String contentId, PlaceDto dto) {
        try {
            URI introUri = buildBaseUri("/detailIntro2")
                    .queryParam("contentId",     contentId)
                    .queryParam("contentTypeId", "32")
                    .build(true).toUri();

            String   introRes  = new RestTemplate().getForObject(introUri, String.class);
            JsonNode introItem = objectMapper.readTree(introRes)
                    .path("response").path("body").path("items").path("item").get(0);

            if (introItem != null && !introItem.isMissingNode()) {
                dto.setCheckintime(introItem.path("checkintime").asText("").trim());
                dto.setCheckouttime(introItem.path("checkouttime").asText("").trim());
                placeMapper.insertAccommodationDetail(dto);
            }
        } catch (Exception e) {
            log.warn("[KTO Sync] 숙박 상세 조회 실패 - contentId:{}", contentId);
        }
    }

    // ── 유틸 ─────────────────────────────────────────────────────
    private String mapContentTypeToCategory(String cType) {
        return switch (cType) {
            case "12" -> "TOUR";
            case "14" -> "CULTURE";
            case "28" -> "LEISURE";
            case "32" -> "ACCOMMODATION";
            case "38" -> "SHOPPING";
            case "39" -> "RESTAURANT";
            default   -> "ETC";
        };
    }

    private UriComponentsBuilder buildBaseUri(String path) {
        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl);
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);
        return UriComponentsBuilder.fromUriString(baseUrl + path)
                .queryParam("serviceKey", serviceKey)
                .queryParam("MobileOS",  "ETC")
                .queryParam("MobileApp", "Tripan")
                .queryParam("_type",     "json");
    }
}
