package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.common.StorageService;
import com.tripan.app.partner.domain.dto.PartnerInfoDto;
import com.tripan.app.partner.mapper.PartnerInfoMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PartnerInfoServiceImpl implements PartnerInfoService {

	private final PartnerInfoMapper partnerInfoMapper;
    private final StorageService storageService; 

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Value("${tripan.api.kakao-map-api-key}") 
    private String kakaoApiKey;
    
	@Value("${tripan.api.kakao-rest-api-key}")
    private String kakaoRestApiKey;

    @Override
    public PartnerInfoDto getPartnerInfo(Long memberId) {
        return partnerInfoMapper.getPartnerInfoByMemberId(memberId);
    }

    @Override
    public Long getPlaceIdByMemberId(Long memberId) {
        return partnerInfoMapper.getPlaceIdByMemberId(memberId);
    }
    
    @Override
    public List<PartnerInfoDto> getPartnerListByMemberId(Long memberId) {
        return partnerInfoMapper.getPartnerListByMemberId(memberId);
    }
    
    @Override
    public Long getPlaceIdByPartnerId(Long partnerId) {
        return partnerInfoMapper.getPlaceIdByPartnerId(partnerId);
    }

    @Override
    public Map<String, Object> getFacilityByAfId(String afId) {
        return partnerInfoMapper.getFacilityByAfId(afId);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePartnerInfo(PartnerInfoDto dto) {
        partnerInfoMapper.updatePartnerInfo(dto);

        if (dto.getAddress() != null && !dto.getAddress().isBlank()) {
            calculateLatLngFromAddress(dto);
        }

        if (dto.getUploadImage() != null && !dto.getUploadImage().isEmpty()) {
            String dirPath = uploadRoot + "/place";
            String savedFileName = storageService.uploadFileToServer(dto.getUploadImage(), dirPath);
            dto.setImageUrl("/uploads/place/" + savedFileName);
        }

        if (dto.getPlaceId() != null) {
            partnerInfoMapper.updatePlaceInfo(dto);
        }
        if (dto.getAccommodationType() != null) {
            partnerInfoMapper.updateAccommodationType(dto);
        }
    }

    public void calculateLatLngFromAddress(PartnerInfoDto dto) {
        
        String targetAddress = (dto.getBaseAddress() != null && !dto.getBaseAddress().trim().isEmpty()) 
                               ? dto.getBaseAddress() 
                               : dto.getAddress();
        
        String searchAddress = targetAddress.replaceAll("^\\[.*?\\]\\s*", "");

        String url = "https://dapi.kakao.com/v2/local/search/address.json?query={address}";

        RestTemplate restTemplate = new RestTemplate();
        
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + kakaoRestApiKey);
        
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                String.class, 
                searchAddress 
            );
            
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());
            JsonNode documents = root.path("documents");
            
            if (documents.isArray() && !documents.isEmpty()) {
                JsonNode firstDocument = documents.get(0);
                double lng = firstDocument.path("x").asDouble(); 
                double lat = firstDocument.path("y").asDouble(); 
                
                dto.setLongitude(lng);
                dto.setLatitude(lat);
                
                log.info("카카오 API 좌표 변환 성공 - 검색주소: {}, 위도: {}, 경도: {}", searchAddress, lat, lng);
            } else {
                throw new RuntimeException("검색된 주소 결과가 없습니다. (API가 인식하지 못하는 주소입니다)");
            }
            
        } catch (Exception e) {
            log.error("카카오 API 호출 실패: {}", e.getMessage());
            throw new RuntimeException("주소를 좌표로 변환하는 데 실패했습니다. 주소를 다시 확인해 주세요.");
        }
    }
}