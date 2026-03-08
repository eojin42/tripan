package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityMateDto;
import com.tripan.app.mapper.CommunityMateMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommunityMateServiceImpl implements CommunityMateService {

	private final CommunityMateMapper mateMapper;

    @Override
    public List<CommunityMateDto> getMateList(Long regionId, String startDate, String endDate, String searchTag) {
        log.info("🔍 동행 목록 검색 조건 - 지역:{}, 시작일:{}, 종료일:{}, 태그:{}", regionId, startDate, endDate, searchTag);
        
        return mateMapper.selectMateList(regionId, startDate, endDate, searchTag);
    }

    @Override
    @Transactional 
    public void registerMate(CommunityMateDto dto) {
        log.info("🚀 동행 모집글 등록 진행 - 작성자 회원번호: {}, 제목: {}", dto.getMemberId(), dto.getTitle());
        
        if(dto.getStatus() == null) {
            dto.setStatus("OPEN"); 
        }

        mateMapper.insertMate(dto);
        log.info("✅ 동행 모집글 등록 완료!");
    }

    @Override
    public CommunityMateDto getMateDetail(Long mateId) {
        return mateMapper.selectMateById(mateId);
    }
}