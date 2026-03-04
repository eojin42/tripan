package com.tripan.app.domain.dto;

import java.util.Date;
import java.util.List;
import lombok.Data;

@Data
public class FestivalDto {
    private Long festivalId;       
    private Long placeId;          
    private Long apiContentId;     
    private Date eventStartDate;
    private Date eventEndDate;
    private String playTime;
    private String eventPlace;
    private String spendTime;
    private String festivalGrade;
    private String usageFee;
    private String program;        
    private String subEvent;       
    private String sponsor1;
    private String sponsor1Tel;
    
    private String title;       
    private String firstimage;  
    private Double mapx;        
    private Double mapy;        

    private String start;       // 달력 시작일 (YYYY-MM-DD)
    private String end;         // 달력 종료일 (YYYY-MM-DD)
    private String address;     // 화면 출력용 주소
    private String image;       // 화면 출력용 대표 이미지
    private String color;       // 달력 이벤트 라벨 색상
    
    private List<FestivalImageDto> imageList; 
}