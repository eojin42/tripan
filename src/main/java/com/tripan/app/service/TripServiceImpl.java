package com.tripan.app.service;

import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
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
import com.tripan.app.trip.domain.entity.Tag;
import com.tripan.app.trip.domain.entity.Trip;
import com.tripan.app.trip.domain.entity.TripDay;
import com.tripan.app.trip.domain.entity.TripMember;
import com.tripan.app.trip.domain.entity.TripNotification;
import com.tripan.app.trip.domain.entity.TripRegion;
import com.tripan.app.trip.domain.entity.TripTag;
import com.tripan.app.trip.repository.TagRepository;
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

    /** application.properties: tripan.upload.dir=/uploads/thumbnails */
    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    /** 기본 썸네일 URL (DB에 저장되는 경로) */
    private static final String DEFAULT_THUMB = "/dist/images/logo.png";

    // ═══════════════════════════════════════════════════════
    //  여행 생성
    // ═══════════════════════════════════════════════════════
    @Override
    public Long createTrip(TripCreateDto dto, Long memberId) {

        // ── 썸네일 처리 ──
        String thumbnailUrl = saveThumbnail(dto.getThumbnailBase64());

        Trip trip = new Trip();
        trip.setTripName(dto.getTitle());
        trip.setStartDate(LocalDate.parse(dto.getStartDate()).atStartOfDay());
        trip.setEndDate(LocalDate.parse(dto.getEndDate()).atStartOfDay());
        trip.setTripType(dto.getTripType());          // null 허용
        trip.setTotalBudget(dto.getTotalBudget());    // null 허용
        trip.setDescription(dto.getDescription());
        trip.setMemberId(memberId);
        trip.setStatus("PLANNING");
        trip.setIsPublic(dto.getIsPublic());
        trip.setScrapCount(0);
        trip.setInviteCode(UUID.randomUUID().toString().substring(0, 8));
        trip.setThumbnailUrl(thumbnailUrl);
        // ── original_trip_id: 직접 생성 시 null ──
        trip.setOriginalTripId(null);

        trip.setCities(dto.getCities() != null && !dto.getCities().isEmpty()
            ? String.join(", ", dto.getCities()) : "");

        Trip saved = tripRepository.save(trip);
        Long newTripId = saved.getTripId();

        // OWNER 등록
        TripMember owner = new TripMember();
        owner.setTripId(newTripId); owner.setMemberId(memberId);
        owner.setRole("OWNER"); owner.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(owner);

        // ── DAY 자동 생성 ──
        long days = ChronoUnit.DAYS.between(
            LocalDate.parse(dto.getStartDate()),
            LocalDate.parse(dto.getEndDate())) + 1;
        for (int i = 1; i <= days; i++) {
            TripDay td = new TripDay();
            td.setTripId(newTripId); td.setDayNumber(i);
            td.setTripDate(LocalDate.parse(dto.getStartDate()).plusDays(i - 1).atStartOfDay());
            tripDayRepository.save(td);
        }

        // 태그 저장
        saveTags(newTripId, dto.getTags());

        // 지역 저장
        saveRegions(newTripId, dto.getRegionId());

        // 여행 생성 알림
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
        if (dto.getTripType() != null) trip.setTripType(dto.getTripType());
        if (dto.getTotalBudget() != null) trip.setTotalBudget(dto.getTotalBudget());
        if (dto.getDescription() != null) trip.setDescription(dto.getDescription());
        if (dto.getCities() != null && !dto.getCities().isEmpty())
            trip.setCities(String.join(", ", dto.getCities()));

        // 썸네일 변경 시만 업데이트
        if (dto.getThumbnailBase64() != null && !dto.getThumbnailBase64().isBlank()) {
            trip.setThumbnailUrl(saveThumbnail(dto.getThumbnailBase64()));
        }

        tripRepository.save(trip);

        // 지역 재저장
        tripRegionRepository.deleteByTripId(tripId);
        saveRegions(tripId, dto.getRegionId());

        // DAY 수 조정
        if (newDays > oldDays) {
            for (long i = oldDays + 1; i <= newDays; i++) {
                TripDay td = new TripDay(); td.setTripId(tripId); td.setDayNumber((int) i);
                td.setTripDate(LocalDate.parse(dto.getStartDate()).plusDays(i - 1).atStartOfDay());
                tripDayRepository.save(td);
            }
        } else if (newDays < oldDays) {
            tripDayRepository.deleteByTripIdAndDayNumberGreaterThan(tripId, (int) newDays);
        }

        // 태그 재저장
        tripTagRepository.deleteByTripId(tripId);
        saveTags(tripId, dto.getTags());
    }

    // ═══════════════════════════════════════════════════════
    //  getTripDetails: trip + days + members + tags + expense
    // ═══════════════════════════════════════════════════════
    @Override
    @Transactional(readOnly = true)
    public TripDto getTripDetails(Long tripId) {
        TripDto dto = tripMapper.selectTripDetails(tripId);
        if (dto == null) return null;

        // ── cities: DB에서 "서울, 제주" (String) → List<String> 변환 ──
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
    //
    //  PLANNING  → 시작일 도달 → ONGOING
    //  ONGOING   → 종료일 지남 → COMPLETED
    // ═══════════════════════════════════════════════════════
    @Scheduled(cron = "0 0 0 * * *")   // 매일 00:00:00
    @Transactional
    public void updateTripStatuses() {
        LocalDate today = LocalDate.now();
        log.info("[TripScheduler] status 자동 갱신 실행 - {}", today);

        // PLANNING → ONGOING: 시작일이 오늘 이하이고 종료일이 오늘 이상
        List<Trip> toOngoing = tripRepository
            .findByStatusAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
                "PLANNING",
                today.atStartOfDay(),
                today.atStartOfDay()
            );
        toOngoing.forEach(t -> {
            t.setStatus("ONGOING");
            tripRepository.save(t);
            log.info("[TripScheduler] PLANNING→ONGOING tripId={}", t.getTripId());
        });

        // ONGOING → COMPLETED: 종료일이 오늘 이전
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
    //  클론(담아오기)
    //  original_trip_id: 원본 tripId 보존
    //  → 원본 생성자(본인)가 클론해도 original_trip_id = 원본 tripId
    //    (null로 두지 않음 - 스크랩 출처 추적 목적)
    // ═══════════════════════════════════════════════════════
    @Override
    public Long cloneTrip(Long originalTripId, Long memberId) {
        Trip orig = tripRepository.findById(originalTripId).orElseThrow();

        Trip clone = new Trip();
        clone.setTripName(orig.getTripName() + " (복사본)");
        clone.setStartDate(orig.getStartDate());
        clone.setEndDate(orig.getEndDate());
        clone.setTripType(orig.getTripType());
        clone.setTotalBudget(orig.getTotalBudget());
        clone.setMemberId(memberId);
        clone.setStatus("PLANNING");
        clone.setIsPublic(0);
        clone.setScrapCount(0);
        clone.setInviteCode(UUID.randomUUID().toString().substring(0, 8));
        clone.setThumbnailUrl(orig.getThumbnailUrl()); // 썸네일 공유
        // ── original_trip_id: 스크랩 출처 보존 (본인 스크랩도 포함) ──
        clone.setOriginalTripId(originalTripId);
        clone.setCities(orig.getCities());

        Long newTripId = tripRepository.save(clone).getTripId();

        tripRegionRepository.findByTripId(originalTripId).forEach(r -> {
            TripRegion nr = new TripRegion(); nr.setTripId(newTripId); nr.setRegionId(r.getRegionId());
            tripRegionRepository.save(nr);
        });

        TripMember ow = new TripMember(); ow.setTripId(newTripId); ow.setMemberId(memberId);
        ow.setRole("OWNER"); ow.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(ow);

        tripTagRepository.findByTripId(originalTripId).forEach(ot -> {
            TripTag tt = new TripTag(); tt.setTripId(newTripId); tt.setTagId(ot.getTagId());
            tripTagRepository.save(tt);
        });

        tripDayRepository.findByTripIdOrderByDayNumberAsc(originalTripId).forEach(od -> {
            TripDay cd = new TripDay(); cd.setTripId(newTripId); cd.setDayNumber(od.getDayNumber());
            cd.setTripDate(null); // 날짜는 미설정 (직접 지정하도록)
            tripDayRepository.save(cd);
        });

        orig.setScrapCount(orig.getScrapCount() + 1);
        tripRepository.save(orig);

        saveNotification(newTripId, memberId, null, "담아오기로 새 여행이 생성됐어요 📋", "SYSTEM");
        return newTripId;
    }

    @Override
    public Long joinTripViaLink(String inviteCode, Long memberId) {
        Trip trip = tripRepository.findByInviteCode(inviteCode)
            .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 링크"));
        
        // 이미 방장이거나 합류한 멤버인지 선제 검사
        Optional<TripMember> existingMember = tripMemberRepository.findByTripIdAndMemberId(trip.getTripId(), memberId);
        if (existingMember.isPresent()) {
            // 이미 방장이거나 기존 멤버라면? -> "ALREADY_JOINED:번호" 형태의 에러를 던져서 컨트롤러가 알림을 스킵하게 함!
            throw new IllegalStateException("ALREADY_JOINED:" + trip.getTripId());
        }
        
        // ★ 이미 멤버인 경우 → 알림/방송 없이 그냥 워크스페이스로 이동만 (중복 방지)
        if (tripMemberRepository.existsByTripIdAndMemberId(trip.getTripId(), memberId)) {
            return trip.getTripId();
        }

        TripMember nm = new TripMember();
        nm.setTripId(trip.getTripId());
        nm.setMemberId(memberId);
        nm.setRole("EDITOR");
        nm.setInvitationStatus("ACCEPTED");
        nm.setIsFirstVisit(1); // ★ 환영 모달 표시용
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
    public void acceptTripInvitation(Long tripId, Long memberId) {
        TripMember member = tripMemberRepository.findByTripIdAndMemberId(tripId, memberId)
            .orElseThrow(() -> new IllegalArgumentException("초대 내역이 없습니다."));
        member.setInvitationStatus("ACCEPTED");
        member.setIsFirstVisit(1); // ★ 수락 시 환영 모달 표시용
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

    /**
     * base64 썸네일을 서버 디스크에 저장하고 URL 반환
     * - null이면 기본 이미지 경로 반환
     * - 저장 실패 시 기본 이미지 경로 폴백
     */
    private String saveThumbnail(String base64Data) {
        if (base64Data == null || base64Data.isBlank()) return DEFAULT_THUMB;

        try {
            // "data:image/jpeg;base64,/9j/..." 형태에서 헤더 분리
            String[] parts = base64Data.split(",", 2);
            if (parts.length < 2) return DEFAULT_THUMB;

            String header   = parts[0];  // e.g. "data:image/png;base64"
            String encoded  = parts[1];

            // 확장자 추출
            String ext = "jpg";
            if (header.contains("png"))  ext = "png";
            else if (header.contains("webp")) ext = "webp";
            else if (header.contains("gif"))  ext = "gif";

            byte[] decoded = Base64.getDecoder().decode(encoded);

            // 업로드 디렉토리 생성
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            File outFile = new File(dir, fileName);
            try (FileOutputStream fos = new FileOutputStream(outFile)) {
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
