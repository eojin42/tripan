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

                // 성공했거나 데이터가 비어있는 경우 모두 DB 업데이트 (공백이라도 박아서 중복 조회 방지)
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
                // 여기에 진행률 로그를 넣습니다! (성공하든 에러나든 1개 처리했으면 무조건 카운트 증가)
                int current = processedCount.incrementAndGet();
                if (current % 10 == 0) {
                    log.info("📊 실시간 진행 상황: {}/{} 개 완료!", current, emptyPlaces.size());
                }
            }
        });

        return (quotaExceeded.get() > 0 ? "할당량 초과로 중단됨! " : "") + successCount.get() + "개 성공!";
    }
    @Override
    public java.util.Map<String, Object> getRestaurantDetail(String contentId) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        if (contentId == null || contentId.isBlank()) return result;

        try {
            // ── detailIntro2 (식당 전용 상세 필드) ──────────────────────
            URI introUri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                    .queryParam("ServiceKey",     serviceKey)
                    .queryParam("MobileOS",       "ETC")
                    .queryParam("MobileApp",      "Tripan")
                    .queryParam("_type",          "json")
                    .queryParam("contentId",      contentId)
                    .queryParam("contentTypeId",  "39")
                    .build(true).toUri();

            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0");
            ResponseEntity<String> introResp = restTemplate.exchange(
                    introUri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

            JsonNode introItem = objectMapper.readTree(introResp.getBody())
                    .path("response").path("body").path("items").path("item");

            if (introItem.isArray() && introItem.size() > 0) {
                JsonNode n = introItem.get(0);
                putIfNotEmpty(result, "opentimefood",    n, "opentimefood");
                putIfNotEmpty(result, "restdatefood",    n, "restdatefood");
                putIfNotEmpty(result, "parkingfood",     n, "parkingfood");
                putIfNotEmpty(result, "infocenterfood",  n, "infocenterfood");
                putIfNotEmpty(result, "reservationfood", n, "reservationfood");
                putIfNotEmpty(result, "chkcreditcardfood", n, "chkcreditcardfood");
                putIfNotEmpty(result, "kidsfacility",    n, "kidsfacility");
                putIfNotEmpty(result, "packing",         n, "packing");
                putIfNotEmpty(result, "firstmenu",       n, "firstmenu");
                putIfNotEmpty(result, "treatmenu",       n, "treatmenu");
                putIfNotEmpty(result, "seat",            n, "seat");
                putIfNotEmpty(result, "smoking",         n, "smoking");
            }

            // ── detailCommon2 (전화번호, 소개) — 이미 place 테이블에 있으나 안전망 ──
            URI commonUri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                    .queryParam("ServiceKey",  serviceKey)
                    .queryParam("MobileOS",    "ETC")
                    .queryParam("MobileApp",   "Tripan")
                    .queryParam("_type",       "json")
                    .queryParam("contentId",   contentId)
                    .queryParam("numOfRows",   "1")
                    .queryParam("pageNo",      "1")
                    .build(true).toUri();

            ResponseEntity<String> commonResp = restTemplate.exchange(
                    commonUri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

            JsonNode commonItem = objectMapper.readTree(commonResp.getBody())
                    .path("response").path("body").path("items").path("item");

            if (commonItem.isArray() && commonItem.size() > 0) {
                JsonNode n = commonItem.get(0);
                putIfNotEmpty(result, "tel",      n, "tel");
                putIfNotEmpty(result, "homepage", n, "homepage");
            }

        } catch (Exception e) {
            log.warn("[RestaurantDetail] contentId={} 조회 실패: {}", contentId, e.getMessage());
        }
        return result;
    }

    /** JsonNode 필드가 비어있지 않을 때만 Map에 추가 */
    private void putIfNotEmpty(java.util.Map<String, Object> map, String key,
                               JsonNode node, String field) {
        String val = node.path(field).asText("").trim();
        if (!val.isEmpty()) map.put(key, val);
    }
    
    
    @Override
    public String forceSyncRestaurantDetails() {
        // 1. 상세 정보가 없는 식당 조회
        List<Long> emptyRestaurants = placeMapper.findRestaurantsWithoutDetails();
        if (emptyRestaurants.isEmpty()) return "동기화할 식당이 없습니다!";

        log.info("🚀 [식당 상세 동기화] {}개 작업을 시작합니다.", emptyRestaurants.size());
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger quotaExceeded = new AtomicInteger(0);

        emptyRestaurants.parallelStream().forEach(placeId -> {
            if (quotaExceeded.get() > 0) return;

            try {
                // detailIntro2 API 호출 (contentTypeId=39)
                URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                        .queryParam("ServiceKey", serviceKey)
                        .queryParam("MobileOS", "ETC")
                        .queryParam("MobileApp", "Tripan")
                        .queryParam("_type", "json")
                        .queryParam("contentId", placeId)
                        .queryParam("contentTypeId", "39")
                        .queryParam("numOfRows", "1")
                        .queryParam("pageNo", "1")
                        .build(true).toUri();

                HttpHeaders headers = new HttpHeaders();
                headers.set("User-Agent", "Mozilla/5.0");
                ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);
                
                JsonNode item = objectMapper.readTree(response.getBody()).path("response").path("body").path("items").path("item");

                if (item.isArray() && item.size() > 0) {
                    JsonNode node = item.get(0);
                    
                    // [1] RESTAURANT 테이블 (문자열, CLOB)
                    String openTime = node.path("opentimefood").asText("").replace("<br>", "\n").trim();
                    String restDate = node.path("restdatefood").asText("").replace("<br>", "\n").trim();
                    String parking = node.path("parkingfood").asText("").trim();
                    String infoCenter = node.path("infocenterfood").asText("").replace("<br>", "\n").trim();
                    String reservation = node.path("reservationfood").asText("").replace("<br>", "\n").trim();
                    
                    // [2] RESTAURANT_FACILITY 테이블 (문자열 -> 1/0 숫자 변환)
                    int chkCreditCard = parseFacilityText(node.path("chkcreditcardfood").asText(""));
                    int kidsFacility = parseFacilityText(node.path("kidsfacility").asText(""));
                    int packing = parseFacilityText(node.path("packing").asText(""));

                    // [3] RESTAURANT_MENU 테이블
                    String firstMenu = node.path("firstmenu").asText("").trim();
                    String treatMenu = node.path("treatmenu").asText("").trim();
                    String smallImageUrl = ""; // 소개정보에는 이미지가 없으므로 일단 비워둠

                    // DB에 각각 MERGE (저장)
                    placeMapper.upsertRestaurant(placeId, openTime, restDate, parking, infoCenter, reservation);
                    placeMapper.upsertRestaurantFacility(placeId, chkCreditCard, kidsFacility, packing);
                    placeMapper.upsertRestaurantMenu(placeId, firstMenu, treatMenu, smallImageUrl);
                    
                    successCount.incrementAndGet();
                } else {
                    // API에 데이터가 아예 없는 경우 빈값 세팅 (무한루프 방지)
                    placeMapper.upsertRestaurant(placeId, "-", "-", "-", "-", "-");
                    placeMapper.upsertRestaurantFacility(placeId, 0, 0, 0);
                    placeMapper.upsertRestaurantMenu(placeId, "-", "-", "");
                }
            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) {
                    quotaExceeded.incrementAndGet();
                }
            } catch (Exception e) {
                log.error("🚨 식당 ID {} 동기화 실패: {}", placeId, e.getMessage());
            }
        });

        return (quotaExceeded.get() > 0 ? "할당량 초과 중단! " : "") + successCount.get() + "개 식당 정보 저장 완료!";
    }

    // 🔥 "가능", "있음" 등의 글자가 있으면 1(True), 아니면 0(False)으로 바꿔주는 변환기
    private int parseFacilityText(String text) {
        if (text == null || text.trim().isEmpty()) return 0;
        String s = text.trim();
        if (s.contains("불가") || s.contains("없음") || s.contains("안됨")) return 0;
        if (s.contains("가능") || s.contains("있음") || s.contains("유")) return 1;
        return 0; // 애매하면 기본 0
    }

}