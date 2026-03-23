package com.tripan.app.partner.service;

import java.io.File;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value; // 🌟 Value 임포트!
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.common.StorageService;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import com.tripan.app.partner.mapper.PartnerRoomMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerRoomServiceImpl implements PartnerRoomService {

    private final PartnerRoomMapper partnerRoomMapper;
    private final StorageService storageService;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerNewRoom(PartnerRoomDto dto, List<MultipartFile> images) throws Exception {
        
        // 1. 객실과 시설 테이블의 PK를 임의로 생성
        String generatedRoomId = "R-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String generatedRfId = "RF-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        
        dto.setRoomId(generatedRoomId);
        dto.setRfId(generatedRfId);

        partnerRoomMapper.insertRoomFacility(dto);

        partnerRoomMapper.insertRoom(dto);

        if (images != null && !images.isEmpty()) {
            
            String physicalPath = uploadRoot + File.separator + "room";

            for (MultipartFile image : images) {
                if (!image.isEmpty()) {
                    
                    String savedFilename = storageService.uploadFileToServer(image, physicalPath);
                    
                    String imageUrl = "/uploads/room/" + savedFilename;
                    
                    partnerRoomMapper.insertRoomImage(generatedRoomId, imageUrl);
                }
            }
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRoom(String roomId) throws Exception {
        String rfId = partnerRoomMapper.getRfIdByRoomId(roomId);
        
        partnerRoomMapper.deleteRoomImages(roomId); 
        partnerRoomMapper.deleteRoom(roomId);      
        
        if (rfId != null) {
            partnerRoomMapper.deleteRoomFacility(rfId); 
        }
    }

	@Override
	public void saveRoomImages(String roomId, List<MultipartFile> images) {
		if (images != null && !images.isEmpty() && !images.get(0).isEmpty()) {
            String physicalPath = uploadRoot + File.separator + "room";
            
            for (MultipartFile image : images) {
                if (!image.isEmpty()) {
                    String savedFilename = storageService.uploadFileToServer(image, physicalPath);
                    String imageUrl = "/uploads/room/" + savedFilename;
                    partnerRoomMapper.insertRoomImage(roomId, imageUrl);
                }
            }
        }
		
	}
    
}