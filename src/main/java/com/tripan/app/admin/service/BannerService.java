package com.tripan.app.admin.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MainBannerDto;

public interface BannerService {
	List<MainBannerDto> getAll();
    List<MainBannerDto> getVisible();
    MainBannerDto getById(int bannerId);
    void save(MainBannerDto dto, MultipartFile imageFile) throws Exception;
    void update(MainBannerDto dto, MultipartFile imageFile) throws Exception;
    void updateSortOrder(int bannerId, int sortOrder);
    void toggleVisibility(int bannerId, String isVisible);
    void delete(int bannerId);
    int countAll();
}
