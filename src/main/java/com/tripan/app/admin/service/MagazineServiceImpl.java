package com.tripan.app.admin.service;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MagazineArticleDto;
import com.tripan.app.admin.domain.dto.MagazineBlockDto;
import com.tripan.app.admin.mapper.MagazineMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MagazineServiceImpl implements MagazineService{
	 @Autowired
	    private MagazineMapper magazineMapper;
	 
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
	                     MultipartFile thumbFile, MultipartFile heroFile, String uploadDir) throws IOException {
	 
	        if (thumbFile != null && !thumbFile.isEmpty())
	            dto.setThumbnailUrl(storeFile(thumbFile, uploadDir, "thumb"));
	        if (heroFile != null && !heroFile.isEmpty())
	            dto.setHeroImgUrl(storeFile(heroFile, uploadDir, "hero"));
	 
	        magazineMapper.insertArticle(dto);
	        saveBlocks(dto.getArticleId(), blocks);
	        saveTags(dto.getArticleId(), tags);
	    }
	 
	    @Override
	    @Transactional
	    public void update(MagazineArticleDto dto, List<MagazineBlockDto> blocks, List<String> tags,
	                       MultipartFile thumbFile, MultipartFile heroFile, String uploadDir) throws IOException {
	 
	        if (thumbFile != null && !thumbFile.isEmpty()) {
	            dto.setThumbnailUrl(storeFile(thumbFile, uploadDir, "thumb"));
	        } else {
	            MagazineArticleDto prev = magazineMapper.selectById(dto.getArticleId());
	            dto.setThumbnailUrl(prev.getThumbnailUrl());
	        }
	        if (heroFile != null && !heroFile.isEmpty()) {
	            dto.setHeroImgUrl(storeFile(heroFile, uploadDir, "hero"));
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
	 
	    private String storeFile(MultipartFile file, String uploadDir, String prefix) throws IOException {
	        String ext      = getExt(file.getOriginalFilename());
	        String fileName = "mag_" + prefix + "_" + UUID.randomUUID().toString().replace("-", "") + ext;
	        String subDir   = uploadDir + File.separator + "curation";
	        File   dir      = new File(subDir);
	        if (!dir.exists()) dir.mkdirs();
	        file.transferTo(new File(dir, fileName));
	        return "/dist/uploads/curation/" + fileName;
	    }
	 
	    private String getExt(String filename) {
	        if (filename == null || !filename.contains(".")) return ".jpg";
	        return filename.substring(filename.lastIndexOf('.'));
	    }
}
