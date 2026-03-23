package com.tripan.app.service;

import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.TripCreateDto;
import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.mapper.ExpenseMapper;
import com.tripan.app.mapper.TripMapper;
import com.tripan.app.mapper.TripPlaceMapper;
import com.tripan.app.trip.domain.entity.ItineraryItem;
import com.tripan.app.trip.domain.entity.Tag;
import com.tripan.app.trip.domain.entity.Trip;
import com.tripan.app.trip.domain.entity.TripChecklist;
import com.tripan.app.trip.domain.entity.TripDay;
import com.tripan.app.trip.domain.entity.TripMember;
import com.tripan.app.trip.domain.entity.TripNotification;
import com.tripan.app.trip.domain.entity.TripRegion;
import com.tripan.app.trip.domain.entity.TripTag;
import com.tripan.app.trip.repository.ItineraryItemRepository;
import com.tripan.app.trip.repository.TagRepository;
import com.tripan.app.trip.repository.TripChecklistRepository;
import com.tripan.app.trip.repository.TripDayRepository;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.trip.repository.TripNotificationRepository;
import com.tripan.app.trip.repository.TripRegionRepository;
import com.tripan.app.trip.repository.TripRepository;
import com.tripan.app.trip.repository.TripTagRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final TripMemberRepository tripMemberRepository;
    private final TripDayRepository tripDayRepository;
    private final TagRepository tagRepository;
    private final TripTagRepository tripTagRepository;
    private final TripRegionRepository tripRegionRepository;
    private final TripNotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final TripMapper tripMapper;
    private final TripPlaceMapper tripPlaceMapper;
    private final ExpenseMapper expenseMapper;

    // ★ cloneTrip 확장을 위해 추가된 Repository
    private final ItineraryItemRepository itineraryItemRepository;
    private final TripChecklistRepository tripChecklistRepository;

    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    private static final String DEFAULT_THUMB = "/dist/images/logo.png";

    // ═══════════════════════════════════════════════════════
    //  여행 생성
    // ═══════════════════════════════════════════════════════
    @Override
    public Long createTrip(TripCreateDto dto, Long memberId) {

        String thumbnailUrl = saveThumbnail(dto.getThumbnailBase64());

        Trip trip = new Trip();
        trip.setTripName(dto.getTitle());
        trip.setStartDate(LocalDate.parse(dto.getStartDate()).atStartOfDay());
        trip.setEndDate(LocalDate.parse(dto.getEndDate()).atStartOfDay());
        trip.setTripType(dto.getTripType());
        trip.setTotalBudget(dto.getTotalBudget());
        trip.setDescription(dto.getDescription());
        trip.setMemberId(memberId);
        trip.setStatus("PLANNING");
        trip.setIsPublic(dto.getIsPublic());
        trip.setScrapCount(0);
        trip.setInviteCode(UUID.randomUUID().toString().substring(0, 8));
        trip.setThumbnailUrl(thumbnailUrl);
        trip.setOriginalTripId(null);
        trip.setCities(dto.getCities() != null && !dto.getCities().isEmpty()
            ? String.join(", ", dto.getCities()) : "");

        Trip saved = tripRepository.save(trip);
        Long newTripId = saved.getTripId();

        TripMember owner = new TripMember();
        owner.setTripId(newTripId); owner.setMemberId(memberId);
        owner.setRole("OWNER"); owner.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(owner);

        long days = ChronoUnit.DAYS.between(
            LocalDate.parse(dto.getStartDate()),
            LocalDate.parse(dto.getEndDate())) + 1;
        for (int i = 1; i <= days; i++) {
            TripDay td = new TripDay();
            td.setTripId(newTripId); td.setDayNumber(i);
            td.setTripDate(LocalDate.parse(dto.getStartDate()).plusDays(i - 1).atStartOfDay());
            tripDayRepository.save(td);
        }

        saveTags(newTripId, dto.getTags());
        saveRegions(newTripId, dto.getRegionId());
        saveNotification(newTripId, memberId, null,
            "새 여행 방이 생성됐어요! 동행자를 초대해보세요 ✈️", "SYSTEM");

        return newTripId;
    }

    // ═══════════════════════════════════════════════════════
    //  여행 수정
    // ═══════════════════════════════════════════════════════
    @Override
    public void updateTrip(Long tripId, TripCreateDto dto) {
        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("여행 정보 없음"));

        long oldDays = ChronoUnit.DAYS.between(
            trip.getStartDate().toLocalDate(), trip.getEndDate().toLocalDate()) + 1;
        long newDays = ChronoUnit.DAYS.between(
            LocalDate.parse(dto.getStartDate()), LocalDate.parse(dto.getEndDate())) + 1;

        trip.setTripName(dto.getTitle());
        trip.setStartDate(LocalDate.parse(dto.getStartDate()).atStartOfDay());
        trip.setEndDate(LocalDate.parse(dto.getEndDate()).atStartOfDay());
        if (dto.getTripType() != null)    trip.setTripType(dto.getTripType());
        if (dto.getTotalBudget() != null) trip.setTotalBudget(dto.getTotalBudget());
        if (dto.getDescription() != null) trip.setDescription(dto.getDescription());
        trip.setIsPublic(dto.getIsPublic()); // 공개/비공개 반영
        if (dto.getCities() != null && !dto.getCities().isEmpty())
            trip.setCities(String.join(", ", dto.getCities()));

        if (dto.getThumbnailBase64() != null && !dto.getThumbnailBase64().isBlank()) {
            trip.setThumbnailUrl(saveThumbnail(dto.getThumbnailBase64()));
        }

        tripRepository.save(trip);

        tripRegionRepository.deleteByTripId(tripId);
        saveRegions(tripId, dto.getRegionId());

        LocalDate newStartDate = LocalDate.parse(dto.getStartDate());

        if (newDays < oldDays) {
            tripDayRepository.deleteByTripIdAndDayNumberGreaterThan(tripId, (int) newDays);
        } else if (newDays > oldDays) {
            for (long i = oldDays + 1; i <= newDays; i++) {
                TripDay td = new TripDay();
                td.setTripId(tripId);
                td.setDayNumber((int) i);
                td.setTripDate(newStartDate.plusDays(i - 1).atStartOfDay());
                tripDayRepository.save(td);
            }
        }

        List<TripDay> existingDays = tripDayRepository.findByTripIdOrderByDayNumberAsc(tripId);
        for (TripDay td : existingDays) {
            td.setTripDate(newStartDate.plusDays(td.getDayNumber() - 1).atStartOfDay());
            tripDayRepository.save(td);
        }

        tripTagRepository.deleteByTripId(tripId);
        saveTags(tripId, dto.getTags());
    }

    // ═══════════════════════════════════════════════════════
    //  getTripDetails
    // ═══════════════════════════════════════════════════════
    @Override
    @Transactional(readOnly = true)
    public TripDto getTripDetails(Long tripId) {
        TripDto dto = tripMapper.selectTripDetails(tripId);
        if (dto == null) return null;

        if (dto.getCitiesStr() != null && !dto.getCitiesStr().isBlank()) {
            List<String> cityList = java.util.Arrays.stream(dto.getCitiesStr().split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(java.util.stream.Collectors.toList());
            dto.setCities(cityList);
        }

        dto.setDays(tripPlaceMapper.findDayItemsByTripId(tripId));
        dto.setMembers(tripMapper.selectMembersByTripId(tripId));
        dto.setTags(tripMapper.selectTagsByTripId(tripId));
        Double totalExpense = expenseMapper.selectTotalExpenseAmount(tripId);
        dto.setCurrentExpense(totalExpense != null ? totalExpense : 0.0);
        return dto;
    }

    // ═══════════════════════════════════════════════════════
    //  스케줄러: 매일 자정 status 자동 갱신
    // ═══════════════════════════════════════════════════════
    @Scheduled(cron = "0 0 0 * * *")
    @Transactional
    public void updateTripStatuses() {
        LocalDate today = LocalDate.now();
        log.info("[TripScheduler] status 자동 갱신 실행 - {}", today);

        List<Trip> toOngoing = tripRepository
            .findByStatusAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
                "PLANNING", today.atStartOfDay(), today.atStartOfDay());
        toOngoing.forEach(t -> {
            t.setStatus("ONGOING");
            tripRepository.save(t);
            log.info("[TripScheduler] PLANNING→ONGOING tripId={}", t.getTripId());
        });

        List<Trip> toCompleted = tripRepository
            .findByStatusAndEndDateBefore("ONGOING", today.atStartOfDay());
        toCompleted.forEach(t -> {
            t.setStatus("COMPLETED");
            tripRepository.save(t);
            log.info("[TripScheduler] ONGOING→COMPLETED tripId={}", t.getTripId());
        });
    }

    @Override
    public void updateTripStatus(Long tripId, String status) {
        Trip trip = tripRepository.findById(tripId).orElseThrow();
        trip.setStatus(status);
        tripRepository.save(trip);
    }

    @Override
    public void deleteTrip(Long tripId) { tripRepository.deleteById(tripId); }

    // ═══════════════════════════════════════════════════════
    //  cloneTrip (담아오기) ★ 확장
    //
    //  복사 흐름:
    //    1. Trip 생성
    //    2. OWNER 등록
    //    3. Region / Tag 복사
    //    4. Day 생성 + old→new day_id 매핑 Map 구성
    //    5. ItineraryItem 복사 (TripPlace 재사용, Image 제외)
    //    6. TripChecklist 복사 (구조만, 담당자·체크상태 초기화)
    //    7. 원본 scrap_count +1
    //
    //  절대 복사 금지: ItineraryImage, Expense, Settlement, Vote
    // ═══════════════════════════════════════════════════════
    @Override
    @Transactional
    public Long cloneTrip(Long originalTripId, Long memberId) {

        // ── STEP 1: 원본 Trip 조회 ──────────────────────────────
        Trip orig = tripRepository.findById(originalTripId)
            .orElseThrow(() -> new IllegalArgumentException("원본 여행을 찾을 수 없습니다: " + originalTripId));

        // ── STEP 2: 새 Trip 생성 ────────────────────────────────
        Trip clone = new Trip();
        clone.setTripName(orig.getTripName() + " (복사본)");
        clone.setStartDate(orig.getStartDate());
        clone.setEndDate(orig.getEndDate());
        clone.setTripType(orig.getTripType());
        clone.setTotalBudget(orig.getTotalBudget());
        clone.setDescription(orig.getDescription());
        clone.setMemberId(memberId);
        clone.setStatus("PLANNING");
        clone.setIsPublic(0);                          // 복사본은 기본 비공개
        clone.setScrapCount(0);
        clone.setInviteCode(UUID.randomUUID().toString().substring(0, 8));
        clone.setThumbnailUrl(orig.getThumbnailUrl()); // 썸네일 URL 공유 (파일 복사 X)
        clone.setOriginalTripId(originalTripId);       // 출처 추적용
        clone.setCities(orig.getCities());

        Long newTripId = tripRepository.save(clone).getTripId();
        log.info("[cloneTrip] Trip 생성 완료 originalTripId={} → newTripId={}", originalTripId, newTripId);

        // ── STEP 3: OWNER 등록 ──────────────────────────────────
        TripMember owner = new TripMember();
        owner.setTripId(newTripId);
        owner.setMemberId(memberId);
        owner.setRole("OWNER");
        owner.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(owner);

        // ── STEP 4: Region 복사 ─────────────────────────────────
        tripRegionRepository.findByTripId(originalTripId).forEach(origRegion -> {
            TripRegion newRegion = new TripRegion();
            newRegion.setTripId(newTripId);
            newRegion.setRegionId(origRegion.getRegionId());
            tripRegionRepository.save(newRegion);
        });

        // ── STEP 5: Tag 복사 ────────────────────────────────────
        tripTagRepository.findByTripId(originalTripId).forEach(origTag -> {
            TripTag newTag = new TripTag();
            newTag.setTripId(newTripId);
            newTag.setTagId(origTag.getTagId());
            tripTagRepository.save(newTag);
        });

        // ── STEP 6: Day 생성 + old→new day_id 매핑 Map 구성 ────
        //   핵심: 날짜(trip_date)가 아닌 day_number(순서) 기준으로 구조 유지
        //   trip_date는 원본 그대로 복사하여 날짜 연속성 보장
        List<TripDay> origDays = tripDayRepository.findByTripIdOrderByDayNumberAsc(originalTripId);

        // key: 원본 day_id  /  value: 새로 발급된 day_id
        Map<Long, Long> dayIdMapping = new HashMap<>();

        for (TripDay origDay : origDays) {
            TripDay newDay = new TripDay();
            newDay.setTripId(newTripId);
            newDay.setDayNumber(origDay.getDayNumber());
            newDay.setTripDate(origDay.getTripDate()); // 날짜 구조 유지
            // day_memo는 복사하지 않음 (개인 메모)

            TripDay savedDay = tripDayRepository.save(newDay);
            dayIdMapping.put(origDay.getDayId(), savedDay.getDayId());
        }
        log.info("[cloneTrip] Day 복사 완료 - {}개, tripId={}", origDays.size(), newTripId);

        // ── STEP 7: ItineraryItem 복사 ──────────────────────────
        //   - dayIdMapping으로 old_day_id → new_day_id 변환
        //   - trip_place_id: 기존 ID 그대로 참조 (신규 생성 절대 금지)
        //   - visit_order(LexoRank 문자열) 그대로 유지 → 순서 보장
        //   - ItineraryImage 절대 복사 금지 (개인 사진)
        int copiedItemCount = 0;
        for (TripDay origDay : origDays) {
            Long newDayId = dayIdMapping.get(origDay.getDayId());
            if (newDayId == null) {
                log.warn("[cloneTrip] day_id 매핑 누락 — origDayId={}", origDay.getDayId());
                continue;
            }

            List<ItineraryItem> origItems = itineraryItemRepository.findByDayId(origDay.getDayId());
            for (ItineraryItem origItem : origItems) {
                ItineraryItem newItem = new ItineraryItem();
                newItem.setDayId(newDayId);                          // ★ 새 day_id로 교체
                newItem.setTripPlaceId(origItem.getTripPlaceId());   // 기존 place_id 그대로 참조
                newItem.setVisitOrder(origItem.getVisitOrder());     // LexoRank 순서 유지
                newItem.setMemo(origItem.getMemo());
                newItem.setStartTime(origItem.getStartTime());
                newItem.setEndTime(origItem.getEndTime());
                newItem.setDurationMinutes(origItem.getDurationMinutes());
                newItem.setTransportation(origItem.getTransportation());
                newItem.setDistanceKm(origItem.getDistanceKm());
                // ★ ItineraryImage: 복사하지 않음

                itineraryItemRepository.save(newItem);
                copiedItemCount++;
            }
        }
        log.info("[cloneTrip] ItineraryItem 복사 완료 - {}개, tripId={}", copiedItemCount, newTripId);

        // ── STEP 8: TripChecklist 복사 ──────────────────────────
        //   - 복사: item_name, category (구조/항목명만)
        //   - 초기화: is_checked → 0, check_manager → null
        List<TripChecklist> origChecklists = tripChecklistRepository.findByTripId(originalTripId);
        for (TripChecklist origChecklist : origChecklists) {
            TripChecklist newChecklist = new TripChecklist();
            newChecklist.setTripId(newTripId);
            newChecklist.setItemName(origChecklist.getItemName());
            newChecklist.setCategory(origChecklist.getCategory());
            newChecklist.setIsChecked(0);       // ★ 체크 상태 초기화
            newChecklist.setCheckManager(null); // ★ 담당자 초기화 (개인 데이터 제거)
            tripChecklistRepository.save(newChecklist);
        }
        log.info("[cloneTrip] Checklist 복사 완료 - {}개, tripId={}", origChecklists.size(), newTripId);

        // ── STEP 9: 원본 scrap_count +1 ────────────────────────
        orig.setScrapCount(orig.getScrapCount() + 1);
        tripRepository.save(orig);
        log.info("[cloneTrip] scrap_count 갱신 originalTripId={}, count={}",
            originalTripId, orig.getScrapCount());

        saveNotification(newTripId, memberId, null, "담아오기로 새 여행이 생성됐어요 📋", "SYSTEM");
        return newTripId;
    }

    @Override
    public Long joinTripViaLink(String inviteCode, Long memberId) {
        Trip trip = tripRepository.findByInviteCode(inviteCode)
            .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 링크"));

        Optional<TripMember> existMember = tripMemberRepository.findByTripIdAndMemberId(trip.getTripId(), memberId);
        if (existMember.isPresent() && "DECLINED".equals(existMember.get().getInvitationStatus())) {
            throw new IllegalStateException("방장에 의해 강퇴되었거나 거절된 여행에는 다시 참여할 수 없습니다.");
        }

        Optional<TripMember> existingMember = tripMemberRepository.findByTripIdAndMemberId(trip.getTripId(), memberId);
        if (existingMember.isPresent()) {
            throw new IllegalStateException("ALREADY_JOINED:" + trip.getTripId());
        }

        if (tripMemberRepository.existsByTripIdAndMemberId(trip.getTripId(), memberId)) {
            return trip.getTripId();
        }

        TripMember nm = new TripMember();
        nm.setTripId(trip.getTripId());
        nm.setMemberId(memberId);
        nm.setRole("EDITOR");
        nm.setInvitationStatus("ACCEPTED");
        nm.setIsFirstVisit(1);
        tripMemberRepository.save(nm);

        messagingTemplate.convertAndSend("/sub/trip/" + trip.getTripId(),
            Map.of("action", "NEW_MEMBER_JOINED", "memberId", memberId));

        return trip.getTripId();
    }

    @Override
    public void inviteMemberToTrip(Long tripId, Long inviteeId) {
        TripMember pm = new TripMember(); pm.setTripId(tripId); pm.setMemberId(inviteeId);
        pm.setRole("EDITOR"); pm.setInvitationStatus("PENDING");
        tripMemberRepository.save(pm);
        saveNotification(tripId, inviteeId, null, "여행에 초대됐어요! 수락해주세요 ✉️", "INVITE");
    }

    @Override
    @Transactional
    public String regenerateInviteCode(Long tripId) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 여행입니다."));
        String newCode = UUID.randomUUID().toString().substring(0, 8);
        trip.setInviteCode(newCode);
        return newCode;
    }

    @Override
    public void acceptTripInvitation(Long tripId, Long memberId) {
        TripMember member = tripMemberRepository.findByTripIdAndMemberId(tripId, memberId)
            .orElseThrow(() -> new IllegalArgumentException("초대 내역이 없습니다."));
        member.setInvitationStatus("ACCEPTED");
        member.setIsFirstVisit(1);
        tripMemberRepository.save(member);

        messagingTemplate.convertAndSend("/sub/trip/" + tripId,
            Map.of("action", "NEW_MEMBER_JOINED", "memberId", memberId));
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> searchTags(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return List.of();
        return tripMapper.selectTagNamesByKeyword(keyword);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripDto> searchPublicTrips(String keyword) {
        return tripMapper.selectPublicTrips(keyword);
    }

    // ═══════════════════════════════════════════════════════
    //  내부 유틸
    // ═══════════════════════════════════════════════════════

    private String saveThumbnail(String base64Data) {
        if (base64Data == null || base64Data.isBlank()) return DEFAULT_THUMB;

        try {
            String[] parts = base64Data.split(",", 2);
            if (parts.length < 2) return DEFAULT_THUMB;

            String header  = parts[0];
            String encoded = parts[1];

            String ext = "jpg";
            if (header.contains("png"))       ext = "png";
            else if (header.contains("webp")) ext = "webp";
            else if (header.contains("gif"))  ext = "gif";

            byte[] decoded = Base64.getDecoder().decode(encoded);

            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            try (FileOutputStream fos = new FileOutputStream(new File(dir, fileName))) {
                fos.write(decoded);
            }

            return "/dist/images/thumbnails/" + fileName;

        } catch (Exception e) {
            log.warn("[TripService] 썸네일 저장 실패, 기본 이미지 사용: {}", e.getMessage());
            return DEFAULT_THUMB;
        }
    }

    private void saveTags(Long tripId, List<String> tags) {
        if (tags == null) return;
        tags.forEach(tagName -> {
            if (tagName == null || tagName.isBlank()) return;
            Tag tag = tagRepository.findByTagName(tagName).orElseGet(() -> {
                Tag t = new Tag(); t.setTagName(tagName); return tagRepository.save(t);
            });
            TripTag tt = new TripTag(); tt.setTripId(tripId); tt.setTagId(tag.getTagId());
            tripTagRepository.save(tt);
        });
    }

    private void saveRegions(Long tripId, List<Long> regionIds) {
        if (regionIds == null) return;
        regionIds.forEach(rid -> {
            TripRegion tr = new TripRegion(); tr.setTripId(tripId); tr.setRegionId(rid);
            tripRegionRepository.save(tr);
        });
    }

    private void saveNotification(Long tripId, Long receiverId, Long senderId, String message, String type) {
        if (receiverId == null) return;
        try {
            TripNotification n = new TripNotification();
            n.setTripId(tripId); n.setReceiverId(receiverId); n.setSenderId(senderId);
            n.setMessage(message); n.setType(type); n.setIsRead(0);
            notificationRepository.save(n);
        } catch (Exception e) {
            log.warn("[TripService] 알림 저장 실패: {}", e.getMessage());
        }
    }
}