package com.tripan.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.FestivalImageDto;
import com.tripan.app.mapper.FestivalMapper;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.DefaultUriBuilderFactory;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class FestivalSyncServiceImpl implements FestivalSyncService {

    private final FestivalMapper festivalMapper;
    private final ObjectMapper mapper = new ObjectMapper();

    @Value("${tripan.api.kto-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kto-base-url}")
    private String baseUrl;

    public FestivalSyncServiceImpl(FestivalMapper festivalMapper) {
        this.festivalMapper = festivalMapper;
    }

    @Override
    @Scheduled(cron = "0 0 4 * * ?") // 매일 새벽 4시 자동 실행
    @Transactional 
    public void syncFestivalsBatch() {
    	String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        try {
            URI listUri = buildUri("/searchFestival2", null)
                    .queryParam("eventStartDate", today)
                    .queryParam("arrange", "C")
                    .queryParam("numOfRows", 50) 
                    .build().toUri();
            JsonNode listItems = callApiAndGetItems(listUri);

            if (listItems != null && listItems.isArray()) {
                for (int i = 0; i < listItems.size(); i++) {
                    JsonNode node = listItems.get(i);
                    String contentId = node.path("contentid").asText();
                    
                    Long currentPlaceId = 1L; 
                    
                    FestivalDto festival = new FestivalDto();
                    festival.setPlaceId(currentPlaceId);
                    festival.setApiContentId(Long.parseLong(contentId));
                    festival.setEventStartDate(parseDate(node.path("eventstartdate").asText()));
                    festival.setEventEndDate(parseDate(node.path("eventenddate").asText()));

                    URI commonUri = buildUri("/detailCommon2", contentId).build().toUri();
                    JsonNode commonNode = callApiAndGetFirstItem(commonUri);
                    if (commonNode != null) {
                        festival.setProgram(commonNode.path("overview").asText()); 
                    }

                    URI introUri = buildUri("/detailIntro2", contentId)
                            .queryParam("contentTypeId", "15") 
                            .build().toUri();
                    JsonNode introNode = callApiAndGetFirstItem(introUri);
                    if (introNode != null) {
                        festival.setPlayTime(introNode.path("playtime").asText());
                        festival.setSpendTime(introNode.path("spendtimefestival").asText());
                        festival.setUsageFee(introNode.path("usetimefestival").asText());
                        festival.setEventPlace(introNode.path("eventplace").asText());
                        festival.setSponsor1(introNode.path("sponsor1").asText());
                        festival.setSponsor1Tel(introNode.path("sponsor1tel").asText());
                        festival.setFestivalGrade(introNode.path("festivalgrade").asText());
                    }

                    try {
                        festivalMapper.insertFestival(festival);
                        Long newFestivalId = festival.getFestivalId(); 

                        URI imageUri = buildUri("/detailImage2", contentId)
                                .queryParam("imageYN", "Y")
                                .build().toUri();
                        JsonNode imageItems = callApiAndGetItems(imageUri);
                        
                        if (imageItems != null && imageItems.isArray() && imageItems.size() > 0) {
                            List<FestivalImageDto> imageList = new ArrayList<>();
                            
                            for (int j = 0; j < imageItems.size(); j++) {
                                JsonNode imgNode = imageItems.get(j);
                                FestivalImageDto imgDto = new FestivalImageDto();
                                imgDto.setFestivalId(newFestivalId); 
                                imgDto.setOriginImgUrl(imgNode.path("originimgurl").asText());
                                imgDto.setSmallImgUrl(imgNode.path("smallimageurl").asText());
                                imgDto.setImgName(imgNode.path("imgname").asText());
                                imageList.add(imgDto);
                            }
                            festivalMapper.insertFestivalImages(imageList);
                        }
                    } catch (Exception e) {
                        System.err.println("⚠️ 축제 Insert 중 에러 (이미 등록된 축제일 수 있음): " + e.getMessage());
                    }
                }
            }
            System.out.println("✅ 축제 데이터 동기화 완료!");

        } catch (Exception e) {
            System.err.println("❌ 동기화 중 에러 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private UriComponentsBuilder buildUri(String path, String contentId) {
        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory(baseUrl);
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE); 
        
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(baseUrl + path)
                .queryParam("serviceKey", serviceKey)
                .queryParam("MobileOS", "ETC")
                .queryParam("MobileApp", "Tripan")
                .queryParam("_type", "json");
        
        if (contentId != null) {
            builder.queryParam("contentId", contentId);
        }
        return builder;
    }

    private JsonNode callApiAndGetItems(URI uri) throws Exception {
        RestTemplate restTemplate = new RestTemplate();
        String responseJson = restTemplate.getForObject(uri, String.class);
        JsonNode body = mapper.readTree(responseJson).path("response").path("body");
        
        if (body != null && body.has("items") && body.path("items").has("item")) {
            return body.path("items").path("item");
        }
        return null;
    }

    private JsonNode callApiAndGetFirstItem(URI uri) throws Exception {
        JsonNode items = callApiAndGetItems(uri);
        if (items != null && items.isArray() && items.size() > 0) {
            return items.get(0);
        }
        return null;
    }
    
    private Date parseDate(String yyyymmdd) {
        try {
            if (yyyymmdd == null || yyyymmdd.length() != 8) return null;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            return sdf.parse(yyyymmdd);
        } catch (Exception e) {
            return null;
        }
    }
}