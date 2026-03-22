package com.tripan.app.partner.service;

import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

public interface PartnerRoomService {
    void registerNewRoom(PartnerRoomDto dto, List<MultipartFile> images) throws Exception;
}