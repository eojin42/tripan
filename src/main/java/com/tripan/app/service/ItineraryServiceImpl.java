package com.tripan.app.service;

import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.trip.domain.entity.ItineraryImage;
import com.tripan.app.trip.domain.entity.ItineraryItem;
import com.tripan.app.trip.domain.entity.TripPlace;
import com.tripan.app.trip.repository.ItineraryImageRepository; 
import com.tripan.app.trip.repository.ItineraryItemRepository;
import com.tripan.app.trip.repository.TripPlaceRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ItineraryServiceImpl implements ItineraryService {

    private final ItineraryItemRepository itemRepository;
    private final TripPlaceRepository placeRepository;
    private final ItineraryImageRepository imageRepository; 
    private final SimpMessagingTemplate messagingTemplate;

    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    @Override
    @Transactional 
    public Long addPlaceAndItinerary(Long tripId, Long dayId, TripDto.PlaceAddDto dto, Long loginMemberId) {
        TripPlace place = placeRepository.findByApiPlaceId(dto.getApiPlaceId())
            .orElseGet(() -> {
                TripPlace newPlace = new TripPlace();
                newPlace.setApiPlaceId(dto.getApiPlaceId());
                newPlace.setPlaceName(dto.getPlaceName());
                newPlace.setAddress(dto.getAddress());
                newPlace.setLatitude(dto.getLatitude());
                newPlace.setLongitude(dto.getLongitude());
                newPlace.setCategoryName(dto.getCategoryName());
                newPlace.setPlaceUrl(dto.getPlaceUrl());
                newPlace.setMemberId(dto.isCustomPlace() ? loginMemberId : null);
                newPlace.setCreatedAt(LocalDateTime.now());
                return placeRepository.save(newPlace);
            });

        ItineraryItem item = new ItineraryItem();
        item.setDayId(dayId);
        item.setTripPlaceId(place.getTripPlaceId());
        
        List<ItineraryItem> existingItems = itemRepository.findByDayId(dayId);
        String nextVisitOrder = "100000"; 
        
        if (!existingItems.isEmpty()) {
            String maxOrder = existingItems.stream()
                .map(ItineraryItem::getVisitOrder)
                .filter(java.util.Objects::nonNull)
                .max(String::compareTo)
                .orElse("100000");
                
            nextVisitOrder = maxOrder + "a"; 
        }
        
        item.setVisitOrder(nextVisitOrder);
        ItineraryItem saved = itemRepository.save(item);

        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "ADD_ITEM");
        payload.put("dayId", dayId);
        payload.put("item", saved);
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
        
        return saved.getItemId();
    }

    @Override
    @Transactional
    public void updateVisitOrder(Long tripId, List<ItemOrderDto> orderList) {
        for (ItemOrderDto dto : orderList) {
            itemRepository.updateVisitOrder(dto.getItemId(), dto.getVisitOrder());
        }
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, Map.of("action", "REORDER", "data", orderList));
    }

    @Override
    @Transactional
    public void updateItemDetails(Long tripId, Long itemId, String startTime, String memo) {
        LocalTime parsedTime = (startTime != null && !startTime.isEmpty()) ? LocalTime.parse(startTime) : null;
        itemRepository.updateItemDetails(itemId, parsedTime, memo);
        
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, Map.of(
            "action", "UPDATE_DETAIL", 
            "itemId", itemId, 
            "startTime", startTime, 
            "memo", memo
        ));
    }

    @Override
    @Transactional
    public void deleteItineraryItem(Long tripId, Long itemId) {
        itemRepository.deleteById(itemId);
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, Map.of("action", "DELETE", "itemId", itemId));
    }

    @Override
    @Transactional
    public String saveMemoAndImage(Long itemId, String memo, String imageBase64, Long loginMemberId) {
        ItineraryItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("장소 아이템을 찾을 수 없어요: " + itemId));

        if (memo != null) {
            item.setMemo(memo.trim());
        }

        String savedUrl = null;
        if (imageBase64 != null && !imageBase64.isBlank()) {
            savedUrl = saveImageFile(imageBase64); 

            if (savedUrl != null) {
                ItineraryImage image = new ItineraryImage();
                image.setItemId(itemId);          
                image.setMemberId(loginMemberId); 
                image.setImageUrl(savedUrl);      
                
                imageRepository.save(image); 
            }
        }

        return savedUrl;
    }

    private String saveImageFile(String base64Data) {
        try {
            String[] parts = base64Data.split(",", 2);
            if (parts.length < 2) return null;

            String header  = parts[0];
            String encoded = parts[1];
            String ext = header.contains("png") ? "png"
                       : header.contains("webp") ? "webp" : "jpg";

            byte[] decoded = Base64.getDecoder().decode(encoded);
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            try (FileOutputStream fos = new FileOutputStream(new File(dir, fileName))) {
                fos.write(decoded);
            }
            return "/dist/images/thumbnails/" + fileName;
        } catch (Exception e) {
            log.error("[ItineraryService] 이미지 물리 파일 저장 실패: {}", e.getMessage());
            return null;
        }
    }
}