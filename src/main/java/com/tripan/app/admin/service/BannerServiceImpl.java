package com.tripan.app.admin.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MainBannerDto;
import com.tripan.app.admin.mapper.BannerMapper;
import com.tripan.app.common.StorageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BannerServiceImpl implements BannerService {

	 private static final int MAX_BANNER_COUNT = 5;
	 
	    private final BannerMapper bannerMapper;
	    private final StorageService storageService;
	 
	    @Value("${file.upload-root}/banner")
	    private String uploadPath;
	 
	    @Override
	    public List<MainBannerDto> getAll() {
	        return bannerMapper.selectAll();
	    }
	 
	    @Override
	    public List<MainBannerDto> getVisible() {
	        return bannerMapper.selectVisible();
	    }
	 
	    @Override
	    public MainBannerDto getById(int bannerId) {
	        return bannerMapper.selectById(bannerId);
	    }
	 
	    @Override
	    public void save(MainBannerDto dto, MultipartFile imageFile) throws Exception {
	        if (bannerMapper.countAll() >= MAX_BANNER_COUNT) {
	            throw new IllegalStateException("배너는 최대 " + MAX_BANNER_COUNT + "개까지 등록할 수 있습니다.");
	        }
	        if (imageFile != null && !imageFile.isEmpty()) {
	            String savedFilename = storageService.uploadFileToServer(imageFile, uploadPath);
	            dto.setImageUrl(savedFilename);
	        }
	        if (dto.getSortOrder() <= 0) {
	            dto.setSortOrder(bannerMapper.countAll() + 1);
	        }
	        bannerMapper.insert(dto);
	    }
	 
	    @Override
	    public void update(MainBannerDto dto, MultipartFile imageFile) throws Exception {
	        if (imageFile != null && !imageFile.isEmpty()) {
	            // 기존 이미지 삭제
	            MainBannerDto existing = bannerMapper.selectById(dto.getBannerId());
	            if (existing.getImageUrl() != null && !existing.getImageUrl().isBlank()) {
	                storageService.deleteFile(uploadPath, existing.getImageUrl());
	            }
	            String savedFilename = storageService.uploadFileToServer(imageFile, uploadPath);
	            dto.setImageUrl(savedFilename);
	        } else {
	            dto.setImageUrl(bannerMapper.selectById(dto.getBannerId()).getImageUrl());
	        }
	        bannerMapper.update(dto);
	    }
	 
	    @Override
	    public void updateSortOrder(int bannerId, int sortOrder) {
	        bannerMapper.updateSortOrder(bannerId, sortOrder);
	    }
	 
	    @Override
	    public void toggleVisibility(int bannerId, String isVisible) {
	        bannerMapper.updateVisibility(bannerId, isVisible);
	    }
	 
	    @Override
	    public void delete(int bannerId) {
	        // 이미지 파일도 같이 삭제
	        MainBannerDto existing = bannerMapper.selectById(bannerId);
	        if (existing != null && existing.getImageUrl() != null && !existing.getImageUrl().isBlank()) {
	            storageService.deleteFile(uploadPath, existing.getImageUrl());
	        }
	        bannerMapper.delete(bannerId);
	    }
	 
	    @Override
	    public int countAll() {
	        return bannerMapper.countAll();
	    }
}