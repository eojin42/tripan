package com.tripan.app.admin.service;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MagazineArticleDto;
import com.tripan.app.admin.domain.dto.MagazineBlockDto;

public interface MagazineService {
	List<MagazineArticleDto> getAll();
    List<MagazineArticleDto> getPublished();
    MagazineArticleDto getDetail(int articleId);
    void save(MagazineArticleDto dto, List<MagazineBlockDto> blocks, List<String> tags,
              MultipartFile thumbFile, MultipartFile heroFile, String uploadDir) throws IOException;
    void update(MagazineArticleDto dto, List<MagazineBlockDto> blocks, List<String> tags,
                MultipartFile thumbFile, MultipartFile heroFile, String uploadDir) throws IOException;
    void updateStatus(int articleId, int status);
    void delete(int articleId);
}
