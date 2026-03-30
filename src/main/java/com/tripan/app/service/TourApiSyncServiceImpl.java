package com.tripan.app.service;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

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

    /** 동시 API 호출 수 제한 (초당 처리량 초과 방지) — 필요 시 조정 */
    private static final int MAX_CONCURRENT = 5;
    private final Semaphore apiSemaphore = new Semaphore(MAX_CONCURRENT, true);

    // ─────────────────────────────────────────────────────────────────
    // [1] place 테이블 description / phone_number 동기화
    //     이미지 동기화 제외 — API 호출 최소화
    //     호출: GET /api/admin/sync/places
    // ─────────────────────────────────────────────────────────────────
    @Override
    public String forceSyncPlaceDetails() {
        List<PlaceDto> emptyPlaces = placeMapper.findPlacesWithNullDescription();
        if (emptyPlaces.isEmpty()) return "동기화할 대상이 없습니다!";

        log.info("🚀 [place 동기화] {}개 → detailCommon2 (description + tel)", emptyPlaces.size());
        AtomicInteger successCount   = new AtomicInteger(0);
        AtomicBoolean quotaExceeded  = new AtomicBoolean(false);
        AtomicInteger processedCount = new AtomicInteger(0);

        emptyPlaces.parallelStream().forEach(place -> {
            if (quotaExceeded.get()) return;
            try {
                apiSemaphore.acquire();
                try {
                    URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                            .queryParam("ServiceKey", serviceKey)
                            .queryParam("MobileOS",   "ETC")
                            .queryParam("MobileApp",  "Tripan")
                            .queryParam("_type",      "json")
                            .queryParam("contentId",  place.getPlaceId())
                            .queryParam("numOfRows",  "1")
                            .queryParam("pageNo",     "1")
                            .build(true).toUri();

                    HttpHeaders headers = new HttpHeaders();
                    headers.set("User-Agent", "Mozilla/5.0");
                    ResponseEntity<String> response = restTemplate.exchange(
                            uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

                    // ★ TourAPI는 할당량 초과도 HTTP 200으로 반환 → resultCode 체크 필수
                    JsonNode root = objectMapper.readTree(response.getBody());
                    String resultCode = root.path("response").path("header").path("resultCode").asText("0000");
                    if (isQuotaError(resultCode)) {
                        log.warn("⚠️ TourAPI 할당량 초과 (resultCode={})", resultCode);
                        quotaExceeded.set(true);
                        placeMapper.updatePlaceDetails(place.getPlaceId(), "", " ");
                        return;
                    }

                    JsonNode item = root.path("response").path("body").path("items").path("item");

                    String tel  = "";
                    String desc = " ";
                    if (item.isArray() && item.size() > 0) {
                        JsonNode n = item.get(0);
                        tel  = n.path("tel").asText("").replace("<br>", " ").trim();
                        String ov = n.path("overview").asText("");
                        if (!ov.isBlank()) desc = ov.replace("<br>", "\n").replace("<br />", "\n").trim();
                        successCount.incrementAndGet();
                    }
                    placeMapper.updatePlaceDetails(place.getPlaceId(), tel, desc);

                } finally {
                    apiSemaphore.release();
                }
            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) quotaExceeded.set(true);
                else placeMapper.updatePlaceDetails(place.getPlaceId(), "", " ");
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                log.error("🚨 ID {} 동기화 실패: {}", place.getPlaceId(), e.getMessage());
            } finally {
                int cur = processedCount.incrementAndGet();
                if (cur % 20 == 0) log.info("📊 진행: {}/{}", cur, emptyPlaces.size());
            }
        });

        return (quotaExceeded.get() ? "할당량 초과 중단! " : "") + successCount.get() + "개 성공!";
    }

    @Override
    public String forceSyncPlaceImages() {
        return "이미지 동기화는 사용하지 않습니다.";
    }

    // ─────────────────────────────────────────────────────────────────
    // [2] 식당 실시간 조회 (DB 저장 X, 워크스페이스 모달용)
    // ─────────────────────────────────────────────────────────────────
    @Override
    public Map<String, Object> getRestaurantDetail(String contentId) {
        Map<String, Object> result = new HashMap<>();
        if (contentId == null || contentId.isBlank()) return result;

        try {
            URI introUri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                    .queryParam("ServiceKey", serviceKey)
                    .queryParam("MobileOS", "ETC")
                    .queryParam("MobileApp", "Tripan")
                    .queryParam("_type", "json")
                    .queryParam("contentId", contentId)
                    .queryParam("contentTypeId", "39")
                    .build(true).toUri();

            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0");
            ResponseEntity<String> introResp = restTemplate.exchange(
                    introUri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

            JsonNode introItem = objectMapper.readTree(introResp.getBody())
                    .path("response").path("body").path("items").path("item");

            if (introItem.isArray() && introItem.size() > 0) {
                JsonNode n = introItem.get(0);
                putIfNotEmpty(result, "opentimefood",      n, "opentimefood");
                putIfNotEmpty(result, "restdatefood",      n, "restdatefood");
                putIfNotEmpty(result, "parkingfood",       n, "parkingfood");
                putIfNotEmpty(result, "infocenterfood",    n, "infocenterfood");
                putIfNotEmpty(result, "reservationfood",   n, "reservationfood");
                putIfNotEmpty(result, "chkcreditcardfood", n, "chkcreditcardfood");
                putIfNotEmpty(result, "kidsfacility",      n, "kidsfacility");
                putIfNotEmpty(result, "packing",           n, "packing");
                putIfNotEmpty(result, "firstmenu",         n, "firstmenu");
                putIfNotEmpty(result, "treatmenu",         n, "treatmenu");
                putIfNotEmpty(result, "seat",              n, "seat");
                putIfNotEmpty(result, "smoking",           n, "smoking");
            }

            URI commonUri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                    .queryParam("ServiceKey", serviceKey)
                    .queryParam("MobileOS", "ETC")
                    .queryParam("MobileApp", "Tripan")
                    .queryParam("_type", "json")
                    .queryParam("contentId", contentId)
                    .queryParam("numOfRows", "1")
                    .queryParam("pageNo", "1")
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

    // ─────────────────────────────────────────────────────────────────
    // [3] 식당 배치 동기화 → restaurant / restaurant_facility / restaurant_menu
    // ─────────────────────────────────────────────────────────────────
    @Override
    public String forceSyncRestaurantDetails() {
        List<Long> emptyRestaurants = placeMapper.findRestaurantsWithoutDetails();
        if (emptyRestaurants.isEmpty()) return "동기화할 식당이 없습니다!";

        log.info("🚀 [식당 상세 동기화] {}개 작업을 시작합니다.", emptyRestaurants.size());
        AtomicInteger successCount  = new AtomicInteger(0);
        AtomicBoolean quotaExceeded = new AtomicBoolean(false);

        emptyRestaurants.parallelStream().forEach(placeId -> {
            if (quotaExceeded.get()) return;

            try {
                apiSemaphore.acquire();
                try {
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
                    ResponseEntity<String> response = restTemplate.exchange(
                            uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

                    // ★ HTTP 200이라도 resultCode 체크
                    JsonNode root = objectMapper.readTree(response.getBody());
                    String resultCode = root.path("response").path("header").path("resultCode").asText("0000");
                    if (isQuotaError(resultCode)) {
                        log.warn("⚠️ TourAPI 할당량 초과 (resultCode={})", resultCode);
                        quotaExceeded.set(true);
                        return;
                    }

                    JsonNode item = root.path("response").path("body").path("items").path("item");

                    if (item.isArray() && item.size() > 0) {
                        JsonNode node = item.get(0);

                        String openTime    = node.path("opentimefood").asText("").replace("<br>", "\n").trim();
                        String restDate    = node.path("restdatefood").asText("").replace("<br>", "\n").trim();
                        String parking     = node.path("parkingfood").asText("").trim();
                        String infoCenter  = node.path("infocenterfood").asText("").replace("<br>", "\n").trim();
                        String reservation = node.path("reservationfood").asText("").replace("<br>", "\n").trim();

                        int chkCreditCard = parseFacilityText(node.path("chkcreditcardfood").asText(""));
                        int kidsFacility  = parseFacilityText(node.path("kidsfacility").asText(""));
                        int packing       = parseFacilityText(node.path("packing").asText(""));

                        String firstMenu = node.path("firstmenu").asText("").trim();
                        String treatMenu = node.path("treatmenu").asText("").trim();

                        placeMapper.upsertRestaurant(placeId, openTime, restDate, parking, infoCenter, reservation);
                        placeMapper.upsertRestaurantFacility(placeId, chkCreditCard, kidsFacility, packing);
                        placeMapper.upsertRestaurantMenu(placeId, firstMenu, treatMenu, "");

                        successCount.incrementAndGet();
                    } else {
                        placeMapper.upsertRestaurant(placeId, "-", "-", "-", "-", "-");
                        placeMapper.upsertRestaurantFacility(placeId, 0, 0, 0);
                        placeMapper.upsertRestaurantMenu(placeId, "-", "-", "");
                    }
                } finally {
                    apiSemaphore.release();
                }
            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) quotaExceeded.set(true);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                log.error("🚨 식당 ID {} 동기화 실패: {}", placeId, e.getMessage());
            }
        });

        return (quotaExceeded.get() ? "할당량 초과 중단! " : "") + successCount.get() + "개 저장 완료!";
    }

    // ─────────────────────────────────────────────────────────────────
    // [4] ★ 관광지/문화시설/레포츠 배치 동기화 → attraction 테이블 MERGE
    // ─────────────────────────────────────────────────────────────────
    @Override
    public String forceSyncAttractionDetails() {
        List<Map<String, Object>> targets = placeMapper.findAttractionsWithoutDetails();
        if (targets.isEmpty()) return "동기화할 관광지/문화/레포츠가 없습니다!";

        log.info("🚀 [관광지 상세 동기화] {}개 작업을 시작합니다.", targets.size());
        AtomicInteger successCount  = new AtomicInteger(0);
        AtomicBoolean quotaExceeded = new AtomicBoolean(false);

        targets.parallelStream().forEach(row -> {
            if (quotaExceeded.get()) return;

            Long   placeId  = ((Number) row.get("PLACE_ID")).longValue();
            String category = String.valueOf(row.get("CATEGORY"));

            int contentTypeId = switch (category) {
                case "TOUR"    -> 12;
                case "CULTURE" -> 14;
                case "LEISURE" -> 28;
                default        -> 12;
            };

            try {
                apiSemaphore.acquire();
                try {
                    URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                            .queryParam("ServiceKey",    serviceKey)
                            .queryParam("MobileOS",      "ETC")
                            .queryParam("MobileApp",     "Tripan")
                            .queryParam("_type",         "json")
                            .queryParam("contentId",     placeId)
                            .queryParam("contentTypeId", contentTypeId)
                            .queryParam("numOfRows",     "1")
                            .queryParam("pageNo",        "1")
                            .build(true).toUri();

                    HttpHeaders headers = new HttpHeaders();
                    headers.set("User-Agent", "Mozilla/5.0");
                    ResponseEntity<String> response = restTemplate.exchange(
                            uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

                    // ★ HTTP 200이라도 resultCode 체크
                    JsonNode root = objectMapper.readTree(response.getBody());
                    String resultCode = root.path("response").path("header").path("resultCode").asText("0000");
                    if (isQuotaError(resultCode)) {
                        log.warn("⚠️ TourAPI 할당량 초과 (resultCode={})", resultCode);
                        quotaExceeded.set(true);
                        return;
                    }

                    JsonNode item = root.path("response").path("body").path("items").path("item");

                    String closedDays = "";
                    String usetime    = "";

                    if (item.isArray() && item.size() > 0) {
                        JsonNode node = item.get(0);

                        closedDays = switch (contentTypeId) {
                            case 12 -> node.path("restdate").asText("").replace("<br>", "\n").trim();
                            case 14 -> node.path("restdateculture").asText("").replace("<br>", "\n").trim();
                            case 28 -> node.path("restdateleports").asText("").replace("<br>", "\n").trim();
                            default -> "";
                        };

                        usetime = switch (contentTypeId) {
                            case 12 -> node.path("usetime").asText("").replace("<br>", "\n").trim();
                            case 14 -> node.path("usetimeculture").asText("").replace("<br>", "\n").trim();
                            case 28 -> node.path("usetimeleports").asText("").replace("<br>", "\n").trim();
                            default -> "";
                        };

                        successCount.incrementAndGet();
                    }
                    placeMapper.upsertAttraction(placeId,
                            closedDays.isEmpty() ? "-" : closedDays,
                            usetime.isEmpty()    ? "-" : usetime);

                } finally {
                    apiSemaphore.release();
                }
            } catch (HttpStatusCodeException e) {
                if (e.getStatusCode().value() == 429) {
                    quotaExceeded.set(true);
                } else {
                    placeMapper.upsertAttraction(placeId, "-", "-");
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                log.error("🚨 관광지 ID {} 동기화 실패: {}", placeId, e.getMessage());
            }
        });

        return (quotaExceeded.get() ? "할당량 초과 중단! " : "") + successCount.get() + "개 저장 완료!";
    }

    // ── 유틸 및 추가 동기화 ──────────────────────────────────────────────────────────

    @Async
    @Override
    public void syncOnDemand(Long placeId, String category) {
        if (placeId == null || category == null) return;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0");

            // ── 1. description/phone 없으면 채우기 ──────────────────
            if (placeMapper.hasNullDescription(placeId) != 0) {
                URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailCommon2")
                        .queryParam("ServiceKey", serviceKey)
                        .queryParam("MobileOS", "ETC")
                        .queryParam("MobileApp", "Tripan")
                        .queryParam("_type", "json")
                        .queryParam("contentId", placeId)
                        .queryParam("numOfRows", "1")
                        .queryParam("pageNo", "1")
                        .build(true).toUri();

                ResponseEntity<String> res = restTemplate.exchange(
                        uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);
                JsonNode item = objectMapper.readTree(res.getBody())
                        .path("response").path("body").path("items").path("item");

                if (item.isArray() && item.size() > 0) {
                    JsonNode n = item.get(0);
                    String tel  = n.path("tel").asText("").replace("<br>", " ").trim();
                    String desc = n.path("overview").asText("").replace("<br>", "\n").trim();
                    placeMapper.updatePlaceDetails(placeId, tel, desc.isBlank() ? " " : desc);
                } else {
                    placeMapper.updatePlaceDetails(placeId, "", " ");
                }
            }

            // ── 2. 카테고리별 상세 없으면 채우기 ───────────────────
            switch (category) {
                case "RESTAURANT" -> {
                    if (placeMapper.hasRestaurantDetail(placeId) == 0) {
                        URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                                .queryParam("ServiceKey", serviceKey)
                                .queryParam("MobileOS", "ETC").queryParam("MobileApp", "Tripan")
                                .queryParam("_type", "json").queryParam("contentId", placeId)
                                .queryParam("contentTypeId", "39").queryParam("numOfRows", "1")
                                .queryParam("pageNo", "1").build(true).toUri();

                        ResponseEntity<String> res = restTemplate.exchange(
                                uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);
                        JsonNode item = objectMapper.readTree(res.getBody())
                                .path("response").path("body").path("items").path("item");

                        if (item.isArray() && item.size() > 0) {
                            JsonNode n = item.get(0);
                            placeMapper.upsertRestaurant(placeId,
                                    n.path("opentimefood").asText("").replace("<br>", "\n").trim(),
                                    n.path("restdatefood").asText("").replace("<br>", "\n").trim(),
                                    n.path("parkingfood").asText("").trim(),
                                    n.path("infocenterfood").asText("").replace("<br>", "\n").trim(),
                                    n.path("reservationfood").asText("").replace("<br>", "\n").trim());
                            placeMapper.upsertRestaurantFacility(placeId,
                                    parseFacilityText(n.path("chkcreditcardfood").asText("")),
                                    parseFacilityText(n.path("kidsfacility").asText("")),
                                    parseFacilityText(n.path("packing").asText("")));
                            placeMapper.upsertRestaurantMenu(placeId,
                                    n.path("firstmenu").asText("").trim(),
                                    n.path("treatmenu").asText("").trim(), "");
                        } else {
                            placeMapper.upsertRestaurant(placeId, "-", "-", "-", "-", "-");
                            placeMapper.upsertRestaurantFacility(placeId, 0, 0, 0);
                            placeMapper.upsertRestaurantMenu(placeId, "-", "-", "");
                        }
                    }
                }
                case "TOUR", "CULTURE", "LEISURE" -> {
                    if (placeMapper.hasAttractionDetail(placeId) == 0) {
                        int typeId = switch (category) {
                            case "CULTURE"  -> 14;
                            case "LEISURE"  -> 28;
                            default         -> 12;
                        };
                        URI uri = UriComponentsBuilder.fromUriString(baseUrl + "/detailIntro2")
                                .queryParam("ServiceKey", serviceKey)
                                .queryParam("MobileOS", "ETC").queryParam("MobileApp", "Tripan")
                                .queryParam("_type", "json").queryParam("contentId", placeId)
                                .queryParam("contentTypeId", typeId).queryParam("numOfRows", "1")
                                .queryParam("pageNo", "1").build(true).toUri();

                        ResponseEntity<String> res = restTemplate.exchange(
                                uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);
                        JsonNode item = objectMapper.readTree(res.getBody())
                                .path("response").path("body").path("items").path("item");

                        String closed = "-", usetime = "-";
                        if (item.isArray() && item.size() > 0) {
                            JsonNode n = item.get(0);
                            closed  = switch (typeId) {
                                case 14 -> n.path("restdateculture").asText("-");
                                case 28 -> n.path("restdateleports").asText("-");
                                default -> n.path("restdate").asText("-");
                            };
                            usetime = switch (typeId) {
                                case 14 -> n.path("usetimeculture").asText("-");
                                case 28 -> n.path("usetimeleports").asText("-");
                                default -> n.path("usetime").asText("-");
                            };
                            closed  = closed.replace("<br>", "\n").trim();
                            usetime = usetime.replace("<br>", "\n").trim();
                        }
                        placeMapper.upsertAttraction(placeId,
                                closed.isBlank()  ? "-" : closed,
                                usetime.isBlank() ? "-" : usetime);
                    }
                }
            }
        } catch (Exception e) {
            log.warn("⚡ [온디맨드] placeId={} 동기화 실패 (무시): {}", placeId, e.getMessage());
        }
    }

    /**
     * [통합 배치] place(설명+전화+이미지) + 식당 + 관광지 한번에
     * detailCommon2 1회로 description+tel+image 모두 처리 → API 호출 최소화
     * GET /api/admin/sync/all
     */
    @Override
    public String forceSyncAll() {
        StringBuilder sb = new StringBuilder();
        sb.append("▶ place (설명+전화+이미지): ").append(forceSyncPlaceDetails()).append("\n");
        sb.append("▶ 식당 상세:               ").append(forceSyncRestaurantDetails()).append("\n");
        sb.append("▶ 관광지 상세:             ").append(forceSyncAttractionDetails());
        return sb.toString();
    }

    private boolean isQuotaError(String resultCode) {
        return "0021".equals(resultCode) // 서비스 접근 거부
            || "0022".equals(resultCode) // 일시적 서비스 중지 / 할당량 초과
            || "0030".equals(resultCode) // 서비스 키 미등록
            || "0031".equals(resultCode) // 기한 만료
            || "0032".equals(resultCode);// 미등록 IP
    }

    private void putIfNotEmpty(Map<String, Object> map, String key, JsonNode node, String field) {
        String val = node.path(field).asText("").trim();
        if (!val.isEmpty()) map.put(key, val);
    }

    private int parseFacilityText(String text) {
        if (text == null || text.trim().isEmpty()) return 0;
        String s = text.trim();
        if (s.contains("불가") || s.contains("없음") || s.contains("안됨")) return 0;
        if (s.contains("가능") || s.contains("있음") || s.contains("유"))   return 1;
        return 0;
    }
}