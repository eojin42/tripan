package com.tripan.app.service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.TripCreateDto;
import com.tripan.app.mapper.TripMemberMapper;
import com.tripan.app.trip.domian.entity.Tag;
import com.tripan.app.trip.domian.entity.Trip;
import com.tripan.app.trip.domian.entity.TripDay;
import com.tripan.app.trip.domian.entity.TripMember;
import com.tripan.app.trip.domian.entity.TripTag;
import com.tripan.app.trip.repository.TagRepository;
import com.tripan.app.trip.repository.TripDayRepository;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.trip.repository.TripRepository;
import com.tripan.app.trip.repository.TripTagRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class TripServiceImpl implements TripService{
	
	private final TripRepository tripRepository;
    private final TripMemberRepository tripMemberRepository;
    private final TripDayRepository tripDayRepository;
    private final TagRepository tagRepository;
    private final TripTagRepository tripTagRepository;
    private final TripMemberMapper tripMemberMapper;
	
    // 여행 생성
	@Override
	public Long createTrip(TripCreateDto dto, Long memberId) {
		// 여행 기본 정보 저장 
		Trip trip = new Trip();
        trip.setTripName(dto.getTitle());
        trip.setStartDate(LocalDate.parse(dto.getStartDate()).atStartOfDay());
        trip.setEndDate(LocalDate.parse(dto.getEndDate()).atStartOfDay());
        trip.setTripType(dto.getTripType());
        trip.setTotalBudget(dto.getTotalBudget());
        trip.setRegionId(dto.getRegionId()); 
        trip.setMemberId(memberId);
        
        trip.setStatus("PLANNING"); // 초기 상태 (계획중)
        trip.setIsPublic(0); // 비공개
        trip.setScrapCount(0);
        trip.setInviteCode(UUID.randomUUID().toString().substring(0, 8)); // 초대코드 예: a1b2c3d4
		
        Long newTripId = tripRepository.save(trip).getTripId();
        
        TripMember owner = new TripMember();
        owner.setTripId(newTripId);
        owner.setMemberId(memberId);
        owner.setRole("OWNER"); // 방 만든 사람을 방장으로 등록
        owner.setInvitationStatus("ACCEPTED"); // 자동 승인
        tripMemberRepository.save(owner);
        
        // 여행 기간
        long days = ChronoUnit.DAYS.between(LocalDate.parse(dto.getStartDate()), LocalDate.parse(dto.getEndDate())) + 1;
        for (int i = 1; i <= days; i++) {
            TripDay tripDay = new TripDay();
            tripDay.setTripId(newTripId);
            tripDay.setDayNumber(i); // 1, 2, 3... 번호 부여
            tripDay.setTripDate(LocalDate.parse(dto.getStartDate()).plusDays(i - 1).atStartOfDay());
            tripDayRepository.save(tripDay);
        }
        
        
        // 해시태그 저장 (DB에 없으면 새로 만들고, 방이랑 연결)
        if (dto.getTags() != null) {
            dto.getTags().forEach(tagName -> {
                Tag tag = tagRepository.findByTagName(tagName).orElseGet(() -> {
                    Tag newTag = new Tag();
                    newTag.setTagName(tagName);
                    return tagRepository.save(newTag);
                });
                TripTag tripTag = new TripTag();
                tripTag.setTripId(newTripId);
                tripTag.setTagId(tag.getTagId());
                tripTagRepository.save(tripTag);
            });
        }
        
        
        return newTripId;
	}
	
	
	@Override
    public void updateTrip(Long tripId, TripCreateDto dto) {
        // 수정할 여행 방 찾기
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new IllegalArgumentException("여행 정보 없음"));
        
        // 날짜가 바뀌었을 수 있으니 기존 며칠짜리 여행인지, 바뀐 건 며칠인지 계산
        long oldDays = ChronoUnit.DAYS.between(trip.getStartDate().toLocalDate(), trip.getEndDate().toLocalDate()) + 1;
        long newDays = ChronoUnit.DAYS.between(LocalDate.parse(dto.getStartDate()), LocalDate.parse(dto.getEndDate())) + 1;

        // 기본 정보 덮어쓰기
        trip.setTripName(dto.getTitle());
        trip.setStartDate(LocalDate.parse(dto.getStartDate()).atStartOfDay());
        trip.setEndDate(LocalDate.parse(dto.getEndDate()).atStartOfDay());
        trip.setTripType(dto.getTripType());
        trip.setTotalBudget(dto.getTotalBudget());
        trip.setRegionId(dto.getRegionId());
        tripRepository.save(trip);

        
        // 여행 기간이 늘어나면 4일차, 5일차 추가 생성 / 줄어들면 뒤에 일정 삭제
        if (newDays > oldDays) {
            for (long i = oldDays + 1; i <= newDays; i++) {
                TripDay tripDay = new TripDay();
                tripDay.setTripId(tripId);
                tripDay.setDayNumber((int) i); // 번호 부여
                tripDay.setTripDate(LocalDate.parse(dto.getStartDate()).plusDays(i - 1).atStartOfDay());
                tripDayRepository.save(tripDay);
            }
        } else if (newDays < oldDays) {
            tripDayRepository.deleteByTripIdAndDayNumberGreaterThan(tripId, (int) newDays);
        }

        
        // 태그 수정 시 기존 태그 다 지우고 새로 들어온 걸로 교체
        tripTagRepository.deleteByTripId(tripId);
        if (dto.getTags() != null) {
            dto.getTags().forEach(tagName -> {
                Tag tag = tagRepository.findByTagName(tagName).orElseGet(() -> {
                    Tag newTag = new Tag();
                    newTag.setTagName(tagName);
                    return tagRepository.save(newTag);
                });
                TripTag tripTag = new TripTag();
                tripTag.setTripId(tripId);
                tripTag.setTagId(tag.getTagId());
                tripTagRepository.save(tripTag);
            });
        }
    }

    @Override
    public void deleteTrip(Long tripId) {
        // 방 삭제 
        tripRepository.deleteById(tripId);
    }

    @Override
    public void updateTripStatus(Long tripId, String status) {
        // 여행 상태만 업데이트 (PLANNING -> COMPLETED)
        Trip trip = tripRepository.findById(tripId).orElseThrow();
        trip.setStatus(status);
        tripRepository.save(trip);
    }

    // 담아오기 
    @Override
    public Long cloneTrip(Long originalTripId, Long memberId) {
        // 남의 여행 원본 데이터 가져오기
        Trip originalTrip = tripRepository.findById(originalTripId).orElseThrow();

        // 내 걸로 복사해오기
        Trip clonedTrip = new Trip();
        clonedTrip.setTripName(originalTrip.getTripName() + " (복사본)");
        clonedTrip.setStartDate(originalTrip.getStartDate());
        clonedTrip.setEndDate(originalTrip.getEndDate());
        clonedTrip.setTripType(originalTrip.getTripType());
        clonedTrip.setTotalBudget(originalTrip.getTotalBudget());
        clonedTrip.setRegionId(originalTrip.getRegionId());
        clonedTrip.setMemberId(memberId);
        clonedTrip.setStatus("PLANNING");
        clonedTrip.setIsPublic(0);
        clonedTrip.setScrapCount(0);
        clonedTrip.setInviteCode(UUID.randomUUID().toString().substring(0, 8));
        clonedTrip.setOriginalTripId(originalTripId); // 족보 남기기
        
        Long newTripId = tripRepository.save(clonedTrip).getTripId();

        // 담아온 사람을 방장으로 임명
        TripMember owner = new TripMember();
        owner.setTripId(newTripId);
        owner.setMemberId(memberId);
        owner.setRole("OWNER");
        owner.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(owner);

        // 원본 태그 그대로 긁어오기
        tripTagRepository.findByTripId(originalTripId).forEach(originalTag -> {
            TripTag clonedTag = new TripTag();
            clonedTag.setTripId(newTripId);
            clonedTag.setTagId(originalTag.getTagId());
            tripTagRepository.save(clonedTag);
        });

        // 원본의 날짜 순서대로 가져와서 뼈대만 복사
        tripDayRepository.findByTripIdOrderByDayNumberAsc(originalTripId).forEach(originalDay -> {
            TripDay clonedDay = new TripDay();
            clonedDay.setTripId(newTripId);
            
            // 순서는 그대로 유지 
            clonedDay.setDayNumber(originalDay.getDayNumber()); 
            
            // 날짜와 메모는 리셋
            clonedDay.setTripDate(null); 
            clonedDay.setMemo(null);     
            
            tripDayRepository.save(clonedDay);
        });

        // 스크랩(담아오기) 횟수 +1
        originalTrip.setScrapCount(originalTrip.getScrapCount() + 1);
        tripRepository.save(originalTrip);

        return newTripId;
    }

    
    @Override
    public Long joinTripViaLink(String inviteCode, Long memberId) {
        // 초대 코드로 무슨 방인지 찾기
        Trip trip = tripRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 링크"));
        
        // 이미 방에 들어온 사람이면 팅겨내지 말고 그냥 방 번호 돌려줌
        if (tripMemberRepository.existsByTripIdAndMemberId(trip.getTripId(), memberId)) {
            return trip.getTripId();
        }

        TripMember newMember = new TripMember();
        newMember.setTripId(trip.getTripId());
        newMember.setMemberId(memberId);
        newMember.setRole("EDITOR");  // 새로 온 사람 EDITOR(편집자)로 가입 완료 처리
        newMember.setInvitationStatus("ACCEPTED");
        tripMemberRepository.save(newMember);

        return trip.getTripId();
    }

    @Override
    public void inviteMemberToTrip(Long tripId, Long inviteeId) {
        // 아이디로 초대장 보내기 
        TripMember pendingMember = new TripMember();
        pendingMember.setTripId(tripId);
        pendingMember.setMemberId(inviteeId);
        pendingMember.setRole("EDITOR"); 
        pendingMember.setInvitationStatus("PENDING"); // 수락 대기 상태인 PENDING
        tripMemberRepository.save(pendingMember);
    }

    @Override
    public void acceptTripInvitation(Long tripId, Long memberId) {
        // PENDING으로 멈춰있던 초대장 ACCEPTED로 수락 처리
    	TripMember member = tripMemberMapper.findByTripIdAndMemberId(tripId, memberId);
        
        if (member == null) {
            throw new IllegalArgumentException("초대 내역이 없습니다.");
        }
        member.setInvitationStatus("ACCEPTED");
        
        tripMemberRepository.save(member);
    }
}