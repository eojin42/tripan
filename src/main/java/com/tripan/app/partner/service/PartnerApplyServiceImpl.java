package com.tripan.app.partner.service;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.partner.domain.dto.PartnerApplyDto;
import com.tripan.app.partner.domain.dto.PartnerFileDto;
import com.tripan.app.partner.mapper.PartnerApplyMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class PartnerApplyServiceImpl implements PartnerApplyService {

    private final PartnerApplyMapper partnerApplyMapper;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    @Transactional(rollbackFor = Exception.class) 
    public void applyPartner(PartnerApplyDto dto) throws Exception {
        
    	partnerApplyMapper.insertPartner(dto); 
        Long generatedPartnerId = dto.getPartnerId();
        partnerApplyMapper.insertPartnerStatus(generatedPartnerId);
        
        partnerApplyMapper.insertEmptyPlace(dto); 
        
        Map<String, Object> accMap = new HashMap<>();
        accMap.put("placeId", dto.getPlaceId());
        partnerApplyMapper.insertEmptyAccommodation(accMap);
        
        log.info("파트너 DB 저장 완료. 생성된 ID: {}", generatedPartnerId);

        if (dto.getBizLicenseFiles() != null && !dto.getBizLicenseFiles().isEmpty()) {
            
            String partnerUploadDir = uploadRoot + "/partner/";
            File dir = new File(partnerUploadDir);
            if (!dir.exists()) dir.mkdirs();

            for (MultipartFile file : dto.getBizLicenseFiles()) {
                if (file.isEmpty()) continue;

                String originalFilename = file.getOriginalFilename();
                String saveFilename = UUID.randomUUID().toString() + "_" + originalFilename;
                
                String saveFilePath = partnerUploadDir + saveFilename;
                String webUrl = "/uploads/partner/" + saveFilename; 

                file.transferTo(new File(saveFilePath));

                PartnerFileDto fileDto = PartnerFileDto.builder()
                        .partnerId(generatedPartnerId)
                        .originFileName(originalFilename)
                        .fileUrl(webUrl)
                        .fileType(file.getContentType())
                        .build();

                partnerApplyMapper.insertPartnerFile(fileDto);
            }
        }
    }
    
    @Override
    public String getPartnerStatus(Long memberId) {
        return partnerApplyMapper.findPartnerStatusByMemberId(memberId);
    }
    
    @Override
    public PartnerApplyDto getPartnerApplyByMemberId(Long memberId) {
        return partnerApplyMapper.findPartnerApplyByMemberId(memberId);
    }
    
    @Override
    public PartnerApplyDto getPartnerApplyByPartnerId(Long partnerId) {
        return partnerApplyMapper.findPartnerApplyByPartnerId(partnerId);
    }
    
    
}