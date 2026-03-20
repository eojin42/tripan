package com.tripan.app.partner.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.partner.domain.dto.PartnerFacilityUpdateDto;
import com.tripan.app.partner.service.PartnerFacilityService;

@RestController
@RequestMapping("/api/partner/accommodation")
public class PartnerFacilityController {

    @Autowired
    private PartnerFacilityService facilityService;

    @PostMapping("/facility")
    public ResponseEntity<Map<String, Object>> updateFacility(@RequestBody PartnerFacilityUpdateDto dto) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            facilityService.updateFacility(dto);
            response.put("success", true);
            response.put("message", "숙소 설정이 성공적으로 저장되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "저장 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}