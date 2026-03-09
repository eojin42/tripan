package com.tripan.app.service;

import com.tripan.app.mapper.RegionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.util.UriComponentsBuilder;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;

@Service
public class RegionSyncService {

    @Value("${tripan.api.kto-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kto-base-url}")
    private String baseUrl;

    @Autowired
    private RegionMapper regionMapper;

    @Scheduled(cron = "0 0 4 * * *") // 매일 새벽 4시 실행
    public void syncRegionDataFromApi() {
        System.out.println("=== [스케줄러 동작] 시/도 및 시/군/구 동기화 시작 ===");

        try {
            JsonNode sidoItems = fetchApiData(null);

            if (sidoItems != null && sidoItems.isArray()) {
                for (JsonNode sidoNode : sidoItems) {
                    Integer sidoCode = sidoNode.path("code").asInt();
                    String sidoName = sidoNode.path("name").asText();

                    regionMapper.upsertRegion(sidoName, null, sidoCode, null);
                    System.out.println("✅ [시/도] " + sidoName + " 저장 (코드: " + sidoCode + ")");

                    JsonNode sigunguItems = fetchApiData(sidoCode);

                    if (sigunguItems != null && sigunguItems.isArray()) {
                        for (JsonNode sigunguNode : sigunguItems) {
                            Integer sigunguCode = sigunguNode.path("code").asInt();
                            String sigunguName = sigunguNode.path("name").asText();

                            regionMapper.upsertRegion(sidoName, sigunguName, sidoCode, sigunguCode);
                        }
                        System.out.println("   └─ 🎯 [" + sidoName + "] 하위 시/군/구 " + sigunguItems.size() + "개 동기화 완료!");
                    }
                    
                    Thread.sleep(200); 
                }
            }
            System.out.println("=== [스케줄러 동작] 전체 지역 동기화 완벽 종료 ===");

        } catch (Exception e) {
            System.err.println("❌ 지역 코드 동기화 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * API 호출을 담당하는 헬퍼 메서드
     * @param areaCode null이면 시/도 목록, 값이 있으면 해당 지역의 시/군/구 목록 반환
     */
    private JsonNode fetchApiData(Integer areaCode) throws Exception {
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(baseUrl + "/areaCode2")
                .queryParam("serviceKey", serviceKey)
                .queryParam("numOfRows", 999) 
                .queryParam("pageNo", 1)
                .queryParam("MobileOS", "ETC")
                .queryParam("MobileApp", "Tripan")
                .queryParam("_type", "json");

        if (areaCode != null) {
            builder.queryParam("areaCode", areaCode);
        }

        URI uri = builder.build(true).toUri();

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.getForEntity(uri, String.class);

        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(response.getBody());

        JsonNode header = root.path("response").path("header");
        if (header.path("resultCode").asText().equals("0000")) {
            return root.path("response").path("body").path("items").path("item");
        } else {
            System.err.println("❌ API 응답 에러: " + header.path("resultMsg").asText());
            return null;
        }
    }
}