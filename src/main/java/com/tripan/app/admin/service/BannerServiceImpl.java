package com.tripan.app.admin.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.admin.domain.dto.MainBannerDto;
import com.tripan.app.admin.mapper.BannerMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
public class BannerServiceImpl implements BannerService {

    private static final int MAX_BANNER_COUNT = 5;

    @Autowired
    private BannerMapper bannerMapper;

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
    public void save(MainBannerDto dto, MultipartFile imageFile, String uploadDir) throws IOException {
        if (bannerMapper.countAll() >= MAX_BANNER_COUNT) {
            throw new IllegalStateException("배너는 최대 " + MAX_BANNER_COUNT + "개까지 등록할 수 있습니다.");
        }
        if (imageFile != null && !imageFile.isEmpty()) {
            dto.setImageUrl(storeFile(imageFile, uploadDir));
        }
        bannerMapper.insert(dto);
    }

    @Override
    public void update(MainBannerDto dto, MultipartFile imageFile, String uploadDir) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            dto.setImageUrl(storeFile(imageFile, uploadDir));
        } else {
            MainBannerDto existing = bannerMapper.selectById(dto.getBannerId());
            dto.setImageUrl(existing.getImageUrl());
        }
        bannerMapper.update(dto);
    }

    @Override
    public void toggleVisibility(int bannerId, String isVisible) {
        bannerMapper.updateVisibility(bannerId, isVisible);
    }

    @Override
    public void delete(int bannerId) {
        bannerMapper.delete(bannerId);
    }

    @Override
    public int countAll() {
        return bannerMapper.countAll();
    }

    private String storeFile(MultipartFile file, String uploadDir) throws IOException {
        String ext      = getExt(file.getOriginalFilename());
        String fileName = "banner_" + UUID.randomUUID().toString().replace("-", "") + ext;
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