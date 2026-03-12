package com.tripan.app.service;

import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.trip.domain.entity.ItineraryImage;
import com.tripan.app.trip.domain.entity.ItineraryItem;
import com.tripan.app.trip.domain.entity.TripDay;
import com.tripan.app.trip.domain.entity.TripPlace;
import com.tripan.app.trip.repository.ItineraryImageRepository;
import com.tripan.app.trip.repository.ItineraryItemRepository;
import com.tripan.app.trip.repository.TripDayRepository;
import com.tripan.app.trip.repository.TripPlaceRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ItineraryServiceImpl implements ItineraryService {

    private final ItineraryItemRepository itemRepository;
    private final TripPlaceRepository     placeRepository;
    private final ItineraryImageRepository imageRepository;
    private final TripDayRepository       dayRepository;

    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    /* ── 새로운 장소 추가 ──────────────────────────────── */
    @Override
    @Transactional
    public Long addPlaceAndItinerary(Long tripId, Long dayId, TripDto.PlaceAddDto dto, Long loginMemberId) {
        TripPlace place = placeRepository.findByApiPlaceId(dto.getApiPlaceId())
            .orElseGet(() -> {
                TripPlace np = new TripPlace();
                np.setApiPlaceId(dto.getApiPlaceId());
                np.setPlaceName(dto.getPlaceName());
                np.setAddress(dto.getAddress());
                np.setLatitude(dto.getLatitude());
                np.setLongitude(dto.getLongitude());
                np.setCategoryName(dto.getCategoryName());
                np.setPlaceUrl(dto.getPlaceUrl());
                np.setMemberId(dto.isCustomPlace() ? loginMemberId : null);
                np.setCreatedAt(LocalDateTime.now());
                return placeRepository.save(np);
            });

        ItineraryItem item = new ItineraryItem();
        item.setDayId(dayId);
        item.setTripPlaceId(place.getTripPlaceId());

        List<ItineraryItem> existing = itemRepository.findByDayId(dayId);
        String nextOrder = existing.isEmpty() ? "000001"
            : String.format("%06d", existing.size() + 1);
        item.setVisitOrder(nextOrder);

        return itemRepository.save(item).getItemId();
    }

    /* ── 전체 순서 배열 업데이트 (기존 방식) ───────────── */
    @Override
    @Transactional
    public void updateVisitOrder(Long tripId, List<ItemOrderDto> orderList) {
        for (ItemOrderDto dto : orderList) {
            itemRepository.updateVisitOrder(dto.getItemId(), dto.getVisitOrder());
        }
    }

    /* ── 시간/메모 수정 ─────────────────────────────────── */
    @Override
    @Transactional
    public void updateItemDetails(Long tripId, Long itemId, String startTime, String memo) {
        itemRepository.updateItemDetails(itemId, startTime, memo);
    }

    /* ── 장소 삭제 (tripId 포함 기존 버전) ─────────────── */
    @Override
    @Transactional
    public void deleteItineraryItem(Long tripId, Long itemId) {
        itemRepository.deleteById(itemId);
    }

    /* ── 메모 + 이미지 저장 ─────────────────────────────── */
    @Override
    @Transactional
    public String saveMemoAndImage(Long itemId, String memo, String imageBase64, Long loginMemberId) {
        ItineraryItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("장소 아이템 없음: " + itemId));

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

    /* ══════════════════════════════════════════════════════
       ✅ WS 연동용 신규 3개 메서드
    ══════════════════════════════════════════════════════ */

    /**
     * getTripIdByItemId
     * itemId → ItineraryItem.dayId → TripDay.tripId
     */
    @Override
    public Long getTripIdByItemId(Long itemId) {
        return itemRepository.findTripIdByItemId(itemId);
    }

    /**
     * moveItem
     * 드래그앤드롭 단건 이동
     * 1. 현재 item 조회
     * 2. item의 dayId → TripDay → tripId 확보
     * 3. (tripId + dayNumber)로 이동 목적지 TripDay 조회
     * 4. item의 dayId + visitOrder 갱신 후 저장
     */
    @Override
    @Transactional
    public void moveItem(Long itemId, int dayNumber, String visitOrder) {
        ItineraryItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("아이템 없음: " + itemId));

        // 현재 dayId → tripId
        TripDay currentDay = dayRepository.findById(item.getDayId())
            .orElseThrow(() -> new IllegalArgumentException("현재 일차 없음: " + item.getDayId()));
        Long tripId = currentDay.getTripId();

        // 이동 목적지 TripDay
        TripDay targetDay = dayRepository.findByTripIdAndDayNumber(tripId, dayNumber)
            .orElseThrow(() -> new IllegalArgumentException(
                "이동 목적지 일차 없음: tripId=" + tripId + ", dayNumber=" + dayNumber));

        item.setDayId(targetDay.getDayId());
        item.setVisitOrder(visitOrder);
        itemRepository.save(item);
    }

    /**
     * deleteItem
     * 장소 단건 삭제 (itemId만으로)
     */
    @Override
    @Transactional
    public void deleteItem(Long itemId) {
        itemRepository.deleteById(itemId);
    }

    /* ── 이미지 파일 물리 저장 ───────────────────────────── */
    private String saveImageFile(String base64Data) {
        try {
            String[] parts = base64Data.split(",", 2);
            if (parts.length < 2) return null;
            String header  = parts[0];
            String encoded = parts[1];
            String ext     = header.contains("png")  ? "png"
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
            log.error("[ItineraryService] 이미지 저장 실패: {}", e.getMessage());
            return null;
        }
    }
}
