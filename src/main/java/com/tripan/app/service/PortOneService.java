package com.tripan.app.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class PortOneService {

    @Value("${portone.api.key}")
    private String apiKey;

    @Value("${portone.api.secret}")
    private String apiSecret;

    private final RestTemplate restTemplate = new RestTemplate();

    // 포트원 API에 접근하기 위한 '출입증(토큰)' 발급받기
    public String getToken() {
        String url = "https://api.iamport.kr/users/getToken";

        Map<String, String> request = new HashMap<>();
        request.put("imp_key", apiKey);
        request.put("imp_secret", apiSecret);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            Map<String, Object> body = response.getBody();

            if (body != null && (Integer) body.get("code") == 0) {
                Map<String, Object> res = (Map<String, Object>) body.get("response");
                return (String) res.get("access_token");
            } else {
                throw new RuntimeException("포트원 토큰 발급 실패: " + body.get("message"));
            }
        } catch (Exception e) {
            log.error("포트원 토큰 발급 중 오류 발생", e);
            throw new RuntimeException("결제 서버 연결에 실패했습니다.");
        }
    }

    // 토큰과 주문번호(orderId)를 들고 가서 '결제 취소' 요청하기
    public void cancelPayment(String orderId, String reason, long cancelAmount) {
        // 먼저 출입증(토큰)을 받아옴
        String token = getToken();

        String url = "https://api.iamport.kr/payments/cancel";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(token); // Authorization: Bearer {token} 세팅

        Map<String, Object> request = new HashMap<>();
        request.put("merchant_uid", orderId); // 우리가 DB에 저장한 주문번호(ORDER_XXX)
        request.put("reason", reason);
        request.put("amount", cancelAmount);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);
            Map<String, Object> body = response.getBody();

            // code가 0이 아니면 취소 실패 (이미 취소됨, 금액 불일치 등)
            if (body == null || (Integer) body.get("code") != 0) {
                String errorMsg = body != null ? (String) body.get("message") : "응답 없음";
                log.error("포트원 취소 실패: {}", errorMsg);
                throw new RuntimeException("결제 취소 실패: " + errorMsg);
            }
            
            log.info("포트원 결제 취소 성공 - 주문번호: {}", orderId);

        } catch (Exception e) {
            log.error("포트원 결제 취소 통신 중 오류 발생", e);
            throw new RuntimeException(e.getMessage()); // 트랜잭션 롤백을 위해 에러 던지기
        }
    }
}