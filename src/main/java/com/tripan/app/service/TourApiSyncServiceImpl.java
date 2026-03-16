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
    public String forceSyncPlaceDetails() {
        List<PlaceDto> emptyPlaces = placeMapper.findPlacesWithNullDescription();
        if (emptyPlaces.isEmpty()) return "동기화할 대상이 없습니다!";

        log.info("🚀 [터보 동기화] {}개 작업을 시작합니다.", emptyPlaces.size());
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger quotaExceeded = new AtomicInteger(0);
        
        // 🔥 전체 진행률을 세기 위한 카운터 추가!
        AtomicInteger processedCount = new AtomicInteger(0);

        emptyPlaces.parallelStream().forEach(place -> {
            if (quotaExceeded.get() > 0) return;
            
            // 🔥 어떤 ID 작업하는지 확인
            log.info("🔍 작업 시작 -> ID: {}", place.getPlaceId());
            
            String finalTel = "";
            String finalDesc = " "; // 기본값 공백 (설명이 없어도 공백을 넣어야 다음 조회에서 빠짐)
            
            try {
                URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                        .queryParam("ServiceKey", serviceKey)
                        .queryParam("MobileOS", "ETC")
                        .queryParam("MobileApp", "Tripan")
                        .queryParam("_type", "json")
                        .queryParam("contentId", place.getPlaceId())
                        .queryParam("numOfRows", "1")
                        .queryParam("pageNo", "1")
                        .build(true).toUri();

                HttpHeaders headers = new HttpHeaders();
                headers.set("User-Agent", "Mozilla/5.0");
                ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);
                
                JsonNode item = objectMapper.readTree(response.getBody()).path("response").path("body").path("items").path("item");

                if (item.isArray() && item.size() > 0) {
                    JsonNode node = item.get(0);
                    // 전화번호: <br> 제거 및 정리
                    finalTel = node.path("tel").asText("").replace("<br>", " ").trim();
                    // 설명: <br>을 개행으로 바꾸고 정리
                    String ov = node.path("overview").asText("");
                    if (!ov.isBlank()) {
                        finalDesc = ov.replace("<br>", "\n").replace("<br />", "\n").trim();
                    }
                    successCount.incrementAndGet();
                }

                // 🟢 성공했거나 데이터가 비어있는 경우 모두 DB 업데이트 (공백이라도 박아서 중복 조회 방지)
                placeMapper.updatePlaceDetails(place.getPlaceId(), finalTel, finalDesc);

            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) {
                    quotaExceeded.incrementAndGet(); // 할당량 초과 시 멈춤
                } else {
                    // 🚨 500 에러(폐기장소) 등은 공백을 박아서 다음 리스트에서 탈출시킴
                    placeMapper.updatePlaceDetails(place.getPlaceId(), "", " ");
                }
            } catch (Exception e) {
                log.error("🚨 ID {} 동기화 실패: {}", place.getPlaceId(), e.getMessage());
            } finally {
                // 🔥 여기에 진행률 로그를 넣습니다! (성공하든 에러나든 1개 처리했으면 무조건 카운트 증가)
                int current = processedCount.incrementAndGet();
                if (current % 10 == 0) {
                    log.info("📊 실시간 진행 상황: {}/{} 개 완료!", current, emptyPlaces.size());
                }
            }
        });

        return (quotaExceeded.get() > 0 ? "할당량 초과로 중단됨! " : "") + successCount.get() + "개 성공!";
    }
}