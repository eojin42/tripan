package com.tripan.app.admin.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.admin.domain.dto.MagazineArticleDto;
import com.tripan.app.admin.domain.dto.MagazineBlockDto;
import com.tripan.app.admin.service.MagazineService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/curation/magazine")
@RequiredArgsConstructor
public class MagazineRestController {
	private final MagazineService magazineService;
    private final ObjectMapper objectMapper;
 
    // 단건 조회 (수정 모달용)
    @GetMapping("/{articleId}")
    public ResponseEntity<MagazineArticleDto> getOne(@PathVariable int articleId) {
        return ResponseEntity.ok(magazineService.getDetail(articleId));
    }
 
    // 등록
    @PostMapping("/save")
    public ResponseEntity<Map<String, Object>> save(
            @ModelAttribute MagazineArticleDto dto,
            @RequestParam(value = "blocksJson",  defaultValue = "[]") String blocksJson,
            @RequestParam(value = "tagsJson",    defaultValue = "[]") String tagsJson,
            @RequestParam(value = "thumbFile",   required = false) MultipartFile thumbFile,
            @RequestParam(value = "heroFile",    required = false) MultipartFile heroFile) {
        try {
            List<MagazineBlockDto> blocks = objectMapper.readValue(blocksJson, new TypeReference<>() {});
            List<String>           tags   = objectMapper.readValue(tagsJson,   new TypeReference<>() {});
            magazineService.save(dto, blocks, tags, thumbFile, heroFile);
            return ResponseEntity.ok(Map.of("success", true, "articleId", dto.getArticleId()));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
 
    // 수정
    @PostMapping("/update")
    public ResponseEntity<Map<String, Object>> update(
            @ModelAttribute MagazineArticleDto dto,
            @RequestParam(value = "blocksJson",  defaultValue = "[]") String blocksJson,
            @RequestParam(value = "tagsJson",    defaultValue = "[]") String tagsJson,
            @RequestParam(value = "thumbFile",   required = false) MultipartFile thumbFile,
            @RequestParam(value = "heroFile",    required = false) MultipartFile heroFile) {
        try {
            List<MagazineBlockDto> blocks = objectMapper.readValue(blocksJson, new TypeReference<>() {});
            List<String>           tags   = objectMapper.readValue(tagsJson,   new TypeReference<>() {});
            magazineService.update(dto, blocks, tags, thumbFile, heroFile);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
 
    // 상태 변경
    @PostMapping("/status")
    public ResponseEntity<Map<String, Object>> updateStatus(
            @RequestParam int articleId,
            @RequestParam int status) {
        magazineService.updateStatus(articleId, status);
        return ResponseEntity.ok(Map.of("success", true));
    }
 
    // 삭제
    @DeleteMapping("/{articleId}")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable int articleId) {
        magazineService.delete(articleId);
        return ResponseEntity.ok(Map.of("success", true));
    }
}
