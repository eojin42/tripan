package com.tripan.app.admin.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MainBannerDto;
import com.tripan.app.admin.service.BannerService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/admin/curation/banner")
@RequiredArgsConstructor
public class BannerRestController {
	private final BannerService bannerService;
	 
    // 단건 조회 (수정 모달용)
    @GetMapping("/{bannerId}")
    public ResponseEntity<MainBannerDto> getOne(@PathVariable("bannerId") int bannerId) {
        return ResponseEntity.ok(bannerService.getById(bannerId));
    }
 
    // 등록
    @PostMapping("/save")
    public ResponseEntity<Map<String, Object>> save(
            @ModelAttribute MainBannerDto dto,
            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
        try {
            bannerService.save(dto, imageFile);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
 
    // 수정
    @PostMapping("/update")
    public ResponseEntity<Map<String, Object>> update(
            @ModelAttribute MainBannerDto dto,
            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
        try {
            bannerService.update(dto, imageFile);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
 
    // 드래그 후 순서 일괄 저장
    // body: [ {bannerId: 1, sortOrder: 0}, {bannerId: 3, sortOrder: 1}, ... ]
    @PostMapping("/sort")
    public ResponseEntity<Map<String, Object>> updateSort(
            @RequestBody List<Map<String, Integer>> orders) {
        try {
            for (Map<String, Integer> item : orders) {
                bannerService.updateSortOrder(item.get("bannerId"), item.get("sortOrder"));
            }
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
 
    // 노출 여부 토글
    @PostMapping("/toggle")
    public ResponseEntity<Map<String, Object>> toggle(
            @RequestParam(name="bannerId") int bannerId,
            @RequestParam(name="isVisible") String isVisible) {
        bannerService.toggleVisibility(bannerId, isVisible);
        return ResponseEntity.ok(Map.of("success", true));
    }
 
    // 삭제
    @PostMapping("/delete/{bannerId}")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable("bannerId") int bannerId) {
        bannerService.delete(bannerId);
        return ResponseEntity.ok(Map.of("success", true));
    }
}
