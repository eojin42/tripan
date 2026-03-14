package com.tripan.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Service
@RequiredArgsConstructor
public class TourApiSyncServiceImpl implements TourApiSyncService {

    private final PlaceMapper placeMapper;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${tripan.api.kto-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kto-base-url}")
    private String baseUrl; 

    @Override
    // 병렬 처리를 위해 @Transactional은 제거 (성능 및 DB 커넥션 최적화)
    public String forceSyncPlaceDetails() {
        // 1. Mapper에서 description IS NULL인 데이터 대량 조회
        List<PlaceDto> emptyPlaces = placeMapper.findPlacesWithNullDescription();

        if (emptyPlaces.isEmpty()) {
            return "동기화할 대상이 없습니다!";
        }

        log.info("🚀 [터보 동기화 시작] 총 {}개의 작업을 병렬로 진행합니다.", emptyPlaces.size());

        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger errorCount = new AtomicInteger(0);
        AtomicInteger quotaExceeded = new AtomicInteger(0);

        emptyPlaces.parallelStream().forEach(place -> {
            // 할당량 초과 시 더 이상 요청 보내지 않음
            if (quotaExceeded.get() > 0) return;

            String contentId = String.valueOf(place.getPlaceId());
            String finalTel = "";
            String finalDesc = " "; // 기본값 공백 (오라클 무한루프 방지)

            try {
                // 매뉴얼 v4.4 규격: detailCommon2 사용 및 불필요 파라미터 제거
                URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                        .queryParam("ServiceKey", serviceKey)
                        .queryParam("MobileOS", "ETC")
                        .queryParam("MobileApp", "Tripan")
                        .queryParam("_type", "json")
                        .queryParam("contentId", contentId)
                        .queryParam("numOfRows", "1")
                        .queryParam("pageNo", "1")
                        .build(true) // 이중 인코딩 방지
                        .toUri();

                HttpHeaders headers = new HttpHeaders();
                headers.set("User-Agent", "Mozilla/5.0"); // 방화벽 통과
                headers.set("Accept", "application/json");
                HttpEntity<String> entity = new HttpEntity<>(headers);

                ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.GET, entity, String.class);
                JsonNode root = objectMapper.readTree(response.getBody());
                JsonNode items = root.path("response").path("body").path("items").path("item");

                if (items != null && items.isArray() && items.size() > 0) {
                    JsonNode item = items.get(0);
                    
                    // 전화번호
                    String tel = item.path("tel").asText("");
                    if (!tel.isBlank()) finalTel = tel.replace("<br>", " ").trim();

                    // 설명
                    String overview = item.path("overview").asText("");
                    if (!overview.isBlank()) {
                        finalDesc = overview.replace("<br>", "\n").replace("<br />", "\n");
                    }
                    successCount.incrementAndGet();
                } else {
                    log.warn("⚠️ [데이터 없음] ID {}: 공백 처리", contentId);
                    errorCount.incrementAndGet();
                }

                placeMapper.updatePlaceDetails(place.getPlaceId(), finalTel, finalDesc);

            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) {
                    log.error("🛑 [할당량 초과] 오늘치 API 한도를 다 썼습니다!");
                    quotaExceeded.incrementAndGet();
                } else {
                    log.error("🚨 [KTO 서버 에러] ID {}: 500/폐기장소 추정. 공백 처리합니다.", contentId);
                    placeMapper.updatePlaceDetails(place.getPlaceId(), "", " ");
                    errorCount.incrementAndGet();
                }
            } catch (Exception e) {
                log.error("🚨 [기타 에러] ID {}: {}", contentId, e.getMessage());
                errorCount.incrementAndGet();
            }
        });

        log.info("🏁 [동기화 종료] 성공: {}, 실패/스킵: {}", successCount.get(), errorCount.get());
        
        if (quotaExceeded.get() > 0) {
            return successCount.get() + "개 성공 후 할당량 초과로 중단되었습니다. 내일 다시 시도하세요!";
        }
        return successCount.get() + "개 성공, " + errorCount.get() + "개 실패/스킵 완료!";
    }
}