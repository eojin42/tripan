package com.tripan.app.admin.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MagazineArticleDto;
import com.tripan.app.admin.domain.dto.MagazineBlockDto;
import com.tripan.app.admin.mapper.MagazineMapper;
import com.tripan.app.common.StorageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MagazineServiceImpl implements MagazineService{
	private final MagazineMapper magazineMapper;
    private final StorageService storageService;
 
    @Value("${file.upload-root}/magazine")
    private String uploadPath;
 
    @Override
    public List<MagazineArticleDto> getAll() {
        return magazineMapper.selectAll();
    }
 
    @Override
    public List<MagazineArticleDto> getPublished() {
        return magazineMapper.selectPublished();
    }
 
    @Override
    public MagazineArticleDto getDetail(int articleId) {
        MagazineArticleDto article = magazineMapper.selectById(articleId);
        if (article == null) return null;
        article.setBlocks(magazineMapper.selectBlocksByArticleId(articleId));
        article.setTags(magazineMapper.selectTagsByArticleId(articleId));
        return article;
    }
 
    @Override
    @Transactional
    public void save(MagazineArticleDto dto, List<MagazineBlockDto> blocks, List<String> tags,
                     MultipartFile thumbFile, MultipartFile heroFile) throws Exception {
 
        if (thumbFile != null && !thumbFile.isEmpty()) {
            String saved = storageService.uploadFileToServer(thumbFile, uploadPath);
            dto.setThumbnailUrl(saved);
        }
        if (heroFile != null && !heroFile.isEmpty()) {
            String saved = storageService.uploadFileToServer(heroFile, uploadPath);
            dto.setHeroImgUrl(saved);
        }
 
        magazineMapper.insertArticle(dto);
        saveBlocks(dto.getArticleId(), blocks);
        saveTags(dto.getArticleId(), tags);
    }
 
    @Override
    @Transactional
    public void update(MagazineArticleDto dto, List<MagazineBlockDto> blocks, List<String> tags,
                       MultipartFile thumbFile, MultipartFile heroFile) throws Exception {
 
        MagazineArticleDto prev = magazineMapper.selectById(dto.getArticleId());
 
        if (thumbFile != null && !thumbFile.isEmpty()) {
            if (prev.getThumbnailUrl() != null && !prev.getThumbnailUrl().isBlank()) {
                storageService.deleteFile(uploadPath,prev.getThumbnailUrl());
            }
            String saved = storageService.uploadFileToServer(thumbFile, uploadPath);
            dto.setThumbnailUrl(saved);
        } else {
            dto.setThumbnailUrl(prev.getThumbnailUrl());
        }
 
        if (heroFile != null && !heroFile.isEmpty()) {
            if (prev.getHeroImgUrl() != null && !prev.getHeroImgUrl().isBlank()) {
                storageService.deleteFile(uploadPath,prev.getHeroImgUrl());
            }
            String saved = storageService.uploadFileToServer(heroFile, uploadPath);
            dto.setHeroImgUrl(saved);
        }
 
        magazineMapper.updateArticle(dto);
 
        magazineMapper.deleteBlocksByArticleId(dto.getArticleId());
        saveBlocks(dto.getArticleId(), blocks);
 
        magazineMapper.deleteTagsByArticleId(dto.getArticleId());
        saveTags(dto.getArticleId(), tags);
    }
 
    @Override
    public void updateStatus(int articleId, int status) {
        magazineMapper.updateStatus(articleId, status);
    }
 
    @Override
    @Transactional
    public void delete(int articleId) {
        magazineMapper.deleteArticle(articleId);
    }
 
    private void saveBlocks(int articleId, List<MagazineBlockDto> blocks) {
        if (blocks == null) return;
        for (int i = 0; i < blocks.size(); i++) {
            MagazineBlockDto b = blocks.get(i);
            b.setArticleId(articleId);
            b.setSortOrder(i);
            magazineMapper.insertBlock(b);
        }
    }
 
    private void saveTags(int articleId, List<String> tags) {
        if (tags == null) return;
        for (String tag : tags) {
            String clean = tag.trim().replaceAll("^#", "");
            if (!clean.isEmpty())
                magazineMapper.insertTag(articleId, clean);
        }
    }
}
