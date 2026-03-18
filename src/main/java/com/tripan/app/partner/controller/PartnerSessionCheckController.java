package com.tripan.app.partner.controller;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.tripan.app.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class PartnerSessionCheckController {

    private final SessionRegistry sessionRegistry;

    @PostMapping("/partner/api/check-session")
    public ResponseEntity<?> checkSession(@RequestParam("loginId") String loginId) {
        try {
            boolean isAlreadyLoggedIn = false;

            for (Object principal : sessionRegistry.getAllPrincipals()) {
                if (principal instanceof CustomUserDetails) {
                    CustomUserDetails user = (CustomUserDetails) principal;

                    if (user != null && user.getMember() != null && user.getMember().getLoginId() != null) {

                    	if (user.getMember().getLoginId().equals(loginId)) {
                            isAlreadyLoggedIn = true;
                            break;
                        }
                    }
                }
            }
            return ResponseEntity.ok(Map.of("isLoggedIn", isAlreadyLoggedIn));

        } catch (Exception e) {
            System.err.println("====== 🚨 [세션 체크 API 에러 발생] 🚨 ======");
            e.printStackTrace();
            System.err.println("===========================================");
            
            return ResponseEntity.status(500).body(Map.of("error", "서버 내부 에러: " + e.getMessage()));
        }
    }
}