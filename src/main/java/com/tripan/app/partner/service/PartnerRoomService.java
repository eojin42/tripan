package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.partner.domain.dto.PartnerRoomDto;

public interface PartnerRoomService {
    void registerNewRoom(PartnerRoomDto dto, List<MultipartFile> images) throws Exception;
    void deleteRoom(String roomId) throws Exception;
    void saveRoomImages(String roomId, List<MultipartFile> images);
    List<Map<String, Object>> getCalendarEvents(Long placeId, String start, String end);
}