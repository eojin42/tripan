package com.tripan.app.service;

import java.text.SimpleDateFormat;
import java.util.List;

import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.FestivalImageDto;
import com.tripan.app.mapper.FestivalMapper;

@Service
public class FestivalServiceImpl implements FestivalService {

    private final FestivalMapper festivalMapper;

    public FestivalServiceImpl(FestivalMapper festivalMapper) {
        this.festivalMapper = festivalMapper;
    }

    @Override
    public List<FestivalDto> getFestivals(int year, int month) {
        
        List<FestivalDto> festivalList = festivalMapper.selectFestivalsByMonth(year, month);
        
        String[] colors = {"#89CFF0", "#FFB6C1", "#A8C8E1", "#E0BBC2", "#FFD700"};
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        int colorIndex = 0;
        
        for (FestivalDto dto : festivalList) {
            if (dto.getEventStartDate() != null) {
                dto.setStart(sdf.format(dto.getEventStartDate()));
            }
            if (dto.getEventEndDate() != null) {
                dto.setEnd(sdf.format(dto.getEventEndDate()));
            }

            dto.setAddress(dto.getEventPlace()); 
            dto.setImage(dto.getFirstimage());   
            
            dto.setColor(colors[colorIndex % colors.length]);
            colorIndex++;
        }

        return festivalList;
    }
    
    
    
    @Override
    public List<FestivalDto> getFestivalsByTripPeriod(String tripStart, String tripEnd) {
        // 여행 기간과 겹치는 축제 목록 조회 
        List<FestivalDto> festivals = festivalMapper.selectFestivalsByTripPeriod(tripStart, tripEnd);

        // 각 축제의 이미지 목록을 추가 조회 
        for (FestivalDto dto : festivals) {
            List<FestivalImageDto> images =
                festivalMapper.selectFestivalImages(dto.getFestivalId());
            dto.setImageList(images);
        }

        return festivals;
    }
}