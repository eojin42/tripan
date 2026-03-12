package com.tripan.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.mapper.TripPlaceMapper;
import lombok.RequiredArgsConstructor;
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
 * 한국관광공사 API 연동 + 나만의 장소 관리 서비스
 *
 * [사용 API 엔드포인트 - 매뉴얼 기준]
 *  - /areaBasedList2  : 지역기반 관광정보 목록 조회 (contentTypeId별 대량 수집)
 *  - /searchKeyword2  : 키워드 검색 조회            (실시간 검색 fallback)
 *  - /detailCommon2   : 공통정보 조회               (tel 보완용)
 *
 * [contentTypeId 코드표]
 *  12: 관광지   14: 문화시설   28: 레포츠
 *  32: 숙박     38: 쇼핑       39: 음식점
 */
@Service
@RequiredArgsConstructor
public class TripPlaceServiceImpl implements TripPlaceService {

    private final TripPlaceMapper tripPlaceMapper;
    private final ObjectMapper    objectMapper = new ObjectMapper();

    @Value("${tripan.api.kto-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kto-base-url}")
    private String baseUrl;

    // contentTypeId → category 매핑
    private static final int[] CONTENT_TYPE_IDS = {12, 14, 28, 32, 38, 39};

    private String mapCategory(int contentTypeId) {
        switch (contentTypeId) {
            case 12: return "TOUR";
            case 14: return "CULTURE";
            case 28: return "LEISURE";
            case 32: return "STAY";
            case 38: return "SHOPPING";
            case 39: return "RESTAURANT";
            default: return "ETC";
        }
    }

    // ════════════════════════════════════════════════════
    //  배치: 매일 새벽 3시 자동 실행
    //  한국관광공사 areaBasedList2 API → DB 동기화
    // ════════════════════════════════════════════════════
    @Override
    @Scheduled(cron = "0 0 3 * * ?")
    @Transactional
    public void syncPlacesBatch() {
        System.out.println("🚀 관광지 데이터 배치 동기화 시작...");

        for (int contentTypeId : CONTENT_TYPE_IDS) {
            try {
                syncByContentType(contentTypeId);
            } catch (Exception e) {
                System.err.println("❌ contentTypeId=" + contentTypeId + " 동기화 실패: " + e.getMessage());
            }
        }

        System.out.println("✅ 관광지 데이터 배치 동기화 완료!");
    }

    /**
     * contentTypeId 하나씩 지역기반 목록 조회 후 DB 저장
     * - numOfRows=100 으로 페이징하며 전체 수집
     * - api_content_id 중복이면 SKIP
     */
    private void syncByContentType(int contentTypeId) throws Exception {
        int pageNo   = 1;
        int pageSize = 100;
        int total    = Integer.MAX_VALUE;

        while ((pageNo - 1) * pageSize < total) {
            URI uri = buildBaseUri("/areaBasedList2")
                    .queryParam("contentTypeId", contentTypeId)
                    .queryParam("numOfRows", pageSize)
                    .queryParam("pageNo", pageNo)
                    .queryParam("arrange", "C")
                    .build().toUri();

            String   json  = new RestTemplate().getForObject(uri, String.class);
            JsonNode body  = objectMapper.readTree(json).path("response").path("body");

            if (pageNo == 1) {
                total = body.path("totalCount").asInt(0);
                System.out.println("  ▶ contentTypeId=" + contentTypeId + " 총 " + total + "건 수집 시작");
            }

            JsonNode items = body.path("items").path("item");
            if (!items.isArray() || items.size() == 0) break;

            for (JsonNode node : items) {
                String apiContentId = node.path("contentid").asText();

                // 중복 체크 → 있으면 SKIP
                if (tripPlaceMapper.findPlaceIdByApiContentId(apiContentId) != null) continue;

                TripPlaceDto dto = new TripPlaceDto();
                dto.setMemberId(null); // 공용 장소
                dto.setPlaceName(node.path("title").asText());
                dto.setAddress(node.path("addr1").asText());
                dto.setLatitude(node.path("mapy").asDouble(0.0));
                dto.setLongitude(node.path("mapx").asDouble(0.0));
                dto.setCategory(mapCategory(contentTypeId));
                dto.setImageUrl(node.path("firstimage").asText(""));
                dto.setApiContentId(apiContentId);
                dto.setContentTypeId(contentTypeId);

                String tel = node.path("tel").asText("");
                dto.setPhone(tel.isEmpty() ? fetchTel(apiContentId) : tel);

                tripPlaceMapper.insertPlace(dto);
            }

            pageNo++;
        }
    }

    /**
     * detailCommon2 API 호출 → 전화번호 추출
     */
    private String fetchTel(String contentId) {
        try {
            URI uri = buildBaseUri("/detailCommon2")
                    .queryParam("contentId", contentId)
                    .queryParam("defaultYN", "Y")
                    .build().toUri();
            String   json = new RestTemplate().getForObject(uri, String.class);
            JsonNode item = objectMapper.readTree(json)
                    .path("response").path("body")
                    .path("items").path("item");
            if (item.isArray() && item.size() > 0) {
                return item.get(0).path("tel").asText("");
            }
        } catch (Exception ignored) {}
        return "";
    }

    // ════════════════════════════════════════════════════
    //  추천 장소 (카테고리별 랜덤)
    // ════════════════════════════════════════════════════
    @Override
    public List<TripPlaceDto> getRecommendPlaces(String category, String cityKeyword,
                                                  Long currentMemberId, int limit) {
        List<String> cityList = (cityKeyword == null || cityKeyword.isBlank()) 
                                ? List.of() 
                                : List.of(cityKeyword.split(","));
                                
        return tripPlaceMapper.selectRecommendPlaces(category, cityList, currentMemberId, limit);
    }

    // ════════════════════════════════════════════════════
    //  키워드 검색
    //  1단계: DB 검색 (권한 필터 적용)
    //  2단계: DB 결과 없으면 KTO 실시간 API 호출
    // ════════════════════════════════════════════════════
    @Override
    public List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId) {
        // 1. DB 먼저
        List<TripPlaceDto> dbResult = tripPlaceMapper.searchPlacesByKeyword(keyword, currentMemberId);
        if (!dbResult.isEmpty()) return dbResult;

        // 2. DB에 없으면 KTO API 실시간 검색
        try {
            URI uri = buildBaseUri("/searchKeyword2")
                    .queryParam("keyword", keyword)
                    .queryParam("numOfRows", 20)
                    .queryParam("arrange", "C")
                    .build().toUri();

            String   json  = new RestTemplate().getForObject(uri, String.class);
            JsonNode items = objectMapper.readTree(json)
                    .path("response").path("body")
                    .path("items").path("item");

            if (items.isArray()) {
                for (JsonNode node : items) {
                    String apiContentId = node.path("contentid").asText();
                    if (tripPlaceMapper.findPlaceIdByApiContentId(apiContentId) != null) continue;

                    TripPlaceDto dto = new TripPlaceDto();
                    dto.setMemberId(null);
                    dto.setPlaceName(node.path("title").asText());
                    dto.setAddress(node.path("addr1").asText());
                    dto.setLatitude(node.path("mapy").asDouble(0.0));
                    dto.setLongitude(node.path("mapx").asDouble(0.0));
                    dto.setImageUrl(node.path("firstimage").asText(""));
                    dto.setApiContentId(apiContentId);
                    int ctid = node.path("contenttypeid").asInt(12);
                    dto.setContentTypeId(ctid);
                    dto.setCategory(mapCategory(ctid));
                    tripPlaceMapper.insertPlace(dto); // 검색 결과도 DB에 저장
                }
            }
        } catch (Exception e) {
            System.err.println("⚠️ KTO 키워드 검색 API 오류: " + e.getMessage());
        }

        // API 저장 후 다시 DB 조회
        return tripPlaceMapper.searchPlacesByKeyword(keyword, currentMemberId);
    }

    // ════════════════════════════════════════════════════
    //  나만의 장소 등록
    // ════════════════════════════════════════════════════
    @Override
    @Transactional
    public TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId) {
        Long existing = tripPlaceMapper.findPlaceIdByNameAndAddress(
                dto.getPlaceName(), dto.getAddress());
        if (existing != null) {
            dto.setPlaceId(existing);
            return dto;
        }
        dto.setMemberId(memberId);   // ★ 소유자 기록
        dto.setApiContentId(null);
        dto.setContentTypeId(null);
        if (dto.getCategory() == null) dto.setCategory("ETC");
        tripPlaceMapper.insertPlace(dto);
        return dto;
    }

    // ════════════════════════════════════════════════════
    //  나만의 장소 목록 (본인 전용)
    // ════════════════════════════════════════════════════
    @Override
    public List<TripPlaceDto> getMyPlaces(Long memberId) {
        return tripPlaceMapper.selectMyPlaces(memberId);
    }

    // ════════════════════════════════════════════════════
    //  공통 URI 빌더 (매뉴얼 필수 파라미터 포함)
    // ════════════════════════════════════════════════════
    private UriComponentsBuilder buildBaseUri(String path) {
        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl);
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

        return UriComponentsBuilder.fromHttpUrl(baseUrl + path)
                .queryParam("serviceKey", serviceKey)
                .queryParam("MobileOS",  "ETC")
                .queryParam("MobileApp", "Tripan")
                .queryParam("_type",     "json");
    }
}
