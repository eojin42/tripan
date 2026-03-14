package com.tripan.app.service;

import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDateTime;
import java.util.ArrayList;
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

    private final ItineraryItemRepository  itemRepository;
    private final TripPlaceRepository      placeRepository;
    private final ItineraryImageRepository imageRepository;
    private final TripDayRepository        dayRepository;

    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    /* ── 새로운 장소 추가 ──────────────────────────────── */
    @Override
    @Transactional
    public Long addPlaceAndItinerary(Long tripId, Long dayId,
                                     TripDto.PlaceAddDto dto, Long loginMemberId) {
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

    /* ── 전체 순서 배열 업데이트 ─────────────────────── */
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

    /* ────────────────────────────────────────────────────
       ★ 메모 + 다중 이미지 저장 (최대 3장)
       ──────────────────────────────────────────────────── */
    @Override
    @Transactional
    public List<String> saveMemoAndImages(Long itemId, String memo,
                                          List<String> imageBase64List, Long loginMemberId) {
        ItineraryItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("장소 아이템 없음: " + itemId));

        // 메모 저장
        if (memo != null) {
            item.setMemo(memo.trim());
        }

        // 기존 이미지 삭제 후 새로 저장 (덮어쓰기)
        // ★ 기존 이미지를 유지하고 싶으면 이 줄을 제거
        imageRepository.deleteByItemId(itemId);

        List<String> savedUrls = new ArrayList<>();
        if (imageBase64List != null) {
            // 최대 3장까지만 처리
            imageBase64List.stream()
                .filter(b64 -> b64 != null && !b64.isBlank())
                .limit(3)
                .forEach(b64 -> {
                    String url = saveImageFile(b64);
                    if (url != null) {
                        ItineraryImage img = new ItineraryImage();
                        img.setItemId(itemId);
                        img.setMemberId(loginMemberId);
                        img.setImageUrl(url);
                        imageRepository.save(img);
                        savedUrls.add(url);
                    }
                });
        }

        return savedUrls;
    }

    /* ── getTripIdByItemId ─────────────────────────────── */
    @Override
    public Long getTripIdByItemId(Long itemId) {
        return itemRepository.findTripIdByItemId(itemId);
    }

    /* ── moveItem ──────────────────────────────────────── */
    @Override
    @Transactional
    public void moveItem(Long itemId, int dayNumber, String visitOrder) {
        ItineraryItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("아이템 없음: " + itemId));

        TripDay currentDay = dayRepository.findById(item.getDayId())
            .orElseThrow(() -> new IllegalArgumentException("현재 일차 없음: " + item.getDayId()));
        Long tripId = currentDay.getTripId();

        TripDay targetDay = dayRepository.findByTripIdAndDayNumber(tripId, dayNumber)
            .orElseThrow(() -> new IllegalArgumentException(
                "이동 목적지 일차 없음: tripId=" + tripId + ", dayNumber=" + dayNumber));

        item.setDayId(targetDay.getDayId());
        item.setVisitOrder(visitOrder);
        itemRepository.save(item);
    }

    /* ── deleteItem ────────────────────────────────────── */
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
