package com.tripan.app.service;

import java.util.List;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.mapper.AccommodationMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccommodationServiceImpl implements AccommodationService{
	private final AccommodationMapper mapper;
	
	
	@Override
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition) {
			return mapper.selectAccommodationList(condition);

	}


	@Override
	public AccommodationDetailDto getAccommodationDetail(Long placeId, Long memberId) {
		
		AccommodationDetailDto detail = mapper.selectAccommodationDetail(placeId, memberId);
        
        if (detail != null) {
            detail.setImages(mapper.selectAccommodationImages(placeId));
            
            detail.setRooms(mapper.selectRoomsByPlaceId(placeId));
        }
        
        return detail;
	}


	@Override
	public RoomDto findRoomById(String roomId) {
		return mapper.findRoomById(roomId);
	}


	@Override
    @Transactional
    public boolean acquireLock(String roomId, String checkin, String sessionId) {
        // 1. 만료된 과거의 쓰레기 락들 싹 청소
        mapper.deleteExpiredLocks();

        // 2. 현재 방을 누가 잠그고 있는지 확인
        String existingSession = mapper.getRoomLockSession(roomId, checkin);

        if (existingSession != null) {
            if (existingSession.equals(sessionId)) {
                // 🟢 아까 들어온 나 자신이라면? -> 시간 5분 다시 채워주고 통과!
                mapper.updateLockTime(roomId, checkin);
                return true;
            } else {
                // 🔴 다른 사람이라면? -> 거절!
                return false;
            }
        } else {
            // 🟢 방이 비어있다면? -> 내 이름으로 락 생성!
            try {
                mapper.insertRoomLock(roomId, checkin, sessionId);
                return true;
            } catch (DuplicateKeyException e) {
                // 🚨 방이 비어있는 줄 알고 INSERT를 날렸는데, 0.001초 차이로 다른 사람이 먼저 가져가서 PK 중복 에러가 터진 경우! -> 안전하게 거절
                return false;
            }
        }
    }


	@Override
    public void releaseLock(String roomId, String checkin, String sessionId) {
        mapper.deleteRoomLock(roomId, checkin, sessionId);
    }


	@Override
    @Transactional(rollbackFor = Exception.class) // 🌟 핵심: 4개 중 하나라도 에러 나면 전면 취소(롤백)!
    public void processReservation(ReservationRequestDto dto) {
        
		// 1. 주문 마스터 생성
        mapper.insertOrder(dto);
        
        // 2. 예약 정보 생성 
        mapper.insertReservation(dto);
        
        // 3. 주문 상세 생성 (위에서 만든 reservationId를 사용)
        mapper.insertOrderDetail(dto);
        
        // 4. 결제 이력 생성
        mapper.insertPayment(dto);
        
        // (+ 추가 팁) 여기서 기존에 걸어뒀던 5분 선점 락(ROOM_LOCK) 데이터를 삭제하는 쿼리를 같이 호출해주면 더욱 완벽합니다!
        // mapper.deleteRoomLock(dto.getRoomId(), dto.getCheckin(), 특정세션ID);
    }


	@Override
	public boolean toggleBookmark(Long placeId, Long memberId) {
		int count = mapper.checkBookmark(placeId, memberId);
        if (count > 0) {
            mapper.deleteBookmark(placeId, memberId); // 이미 있으면 삭제
            return false; 
        } else {
            mapper.insertBookmark(placeId, memberId); // 없으면 추가
            return true;  
        }
	}
	
	
}
