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
    }

    /**
     * 카카오 주소 검색 API를 사용해 주소를 위경도로 변환
     */
    private void calculateLatLngFromAddress(PartnerInfoDto dto) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "KakaoAK " + kakaoApiKey); 
            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = "https://dapi.kakao.com/v2/local/search/address.json?query=" + dto.getAddress();
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map<String, Object> body = response.getBody();
            if (body != null && body.containsKey("documents")) {
                List<Map<String, Object>> docs = (List<Map<String, Object>>) body.get("documents");
                if (!docs.isEmpty()) {
                    Map<String, Object> doc = docs.get(0);
                    dto.setLongitude(Double.parseDouble(doc.get("x").toString())); // 경도
                    dto.setLatitude(Double.parseDouble(doc.get("y").toString()));  // 위도
                }
            }
        } catch (Exception e) {
            log.error("카카오 지오코딩 API 호출 실패 (주소: {})", dto.getAddress(), e);
        }
    }
}
