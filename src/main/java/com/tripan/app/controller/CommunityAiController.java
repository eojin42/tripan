package com.tripan.app.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@RestController
@RequestMapping("/community/api/ai")
public class CommunityAiController {

    @Value("${tripan.api.google-gemini-api-key}")
    private String geminiApiKey;

    @SuppressWarnings({ "rawtypes", "unchecked" })
    @PostMapping("/roulette") 
    public ResponseEntity<?> getRouletteRecommendation(@RequestBody Map<String, List<String>> requestData) {
        List<String> answers = requestData.get("answers");
        
        try {
            String prompt = "너는 여행 추천 전문가야. 사용자가 다음 취향을 골랐어: " + answers.toString() + 
                            ". 이 취향에 딱 맞는 한국의 여행지(제주, 부산, 강원, 여수, 서울 등) 딱 1곳을 추천해줘. " +
                            "반드시 아래 JSON 형식으로만 대답해. 다른 말은 절대 하지마. " +
                            "{\"keyword\": \"지역명\", \"reason\": \"2~3줄의 친근한 추천 이유\"}";

            String url = "https://generativelanguage.googleapis.com/v1alpha/models/gemini-3-flash-preview:generateContent?key=" + geminiApiKey;            
            Map<String, Object> requestBody = new HashMap<>();
            Map<String, Object> parts = new HashMap<>();
            parts.put("text", prompt);
            
            Map<String, Object> contents = new HashMap<>();
            contents.put("parts", Collections.singletonList(parts));
            requestBody.put("contents", Collections.singletonList(contents));

            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
            
            Map<String, Object> responseBody = response.getBody();
            
            List<Map<String, Object>> candidates = (List<Map<String, Object>>) responseBody.get("candidates");
            
            Map<String, Object> content = (Map<String, Object>) candidates.get(0).get("content");
            
            List<Map<String, Object>> resParts = (List<Map<String, Object>>) content.get("parts");
            
            String aiText = (String) resParts.get(0).get("text");

            aiText = aiText.replace("```json", "").replace("```", "").trim();

            return ResponseEntity.ok(aiText);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "AI 응답 지연"));
        }
    }
}