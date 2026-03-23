package com.tripan.app.partner.service;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
	
	@Override
    public List<Map<String, Object>> getCalendarEvents(Long placeId, String start, String end) {
        
        String startDate = start.substring(0, 10);
        String endDate = end.substring(0, 10);
        
        List<Map<String, Object>> dbReservations = partnerRoomMapper.selectReservationsForCalendar(placeId, startDate, endDate);
        
        List<Map<String, Object>> events = new ArrayList<>();
        
        for (Map<String, Object> row : dbReservations) {
            Map<String, Object> event = new HashMap<>();
            
            String status = (String) row.get("STATUS");
            String roomName = (String) row.get("ROOM_NAME");
            String memberName = (String) row.get("MEMBER_NAME");
            
            event.put("id", row.get("RESERVATION_ID").toString());
            event.put("title", memberName + " (" + roomName + ")");
            event.put("start", row.get("CHECK_IN"));
            event.put("end", row.get("CHECK_OUT")); 
            
            if ("SUCCESS".equals(status)) {
                event.put("color", "#2563eb"); // 파란색 (예약완료)
            } else if ("CANCELED".equals(status)) {
                event.put("color", "#dc2626"); // 빨간색 (취소됨)
                event.put("title", "[취소] " + event.get("title"));
            } else {
                event.put("color", "#d97706"); // 주황색 (대기/기타)
            }
            
            event.put("amount", row.get("AMOUNT"));
            event.put("guestCount", row.get("GUEST_COUNT"));
            event.put("request", row.get("REQUEST") != null ? row.get("REQUEST") : "요청사항 없음");
            event.put("status", status); // 취소 여부 등
            events.add(event);
        }
        
        return events;
    }
    
}