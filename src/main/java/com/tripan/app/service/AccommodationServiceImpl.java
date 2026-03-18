package com.tripan.app.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.common.StorageService;
import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.ReviewDto;
import com.tripan.app.domain.dto.ReviewStatsDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.mapper.AccommodationMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccommodationServiceImpl implements AccommodationService{
	private final AccommodationMapper mapper;
	private final StorageService storageService;
	
	@Value("${file.upload-root}/review")
    private String uploadPath;
	
	@Override
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition) {
			return mapper.selectAccommodationList(condition);

	}


	@Override
	public AccommodationDetailDto getAccommodationDetail(Long placeId, Long memberId, String checkin, String checkout) {
		
		AccommodationDetailDto detail = mapper.selectAccommodationDetail(placeId, memberId);
        
        if (detail != null) {
            detail.setImages(mapper.selectAccommodationImages(placeId));
            List<RoomDto> rooms = mapper.selectRoomsByPlaceId(placeId);
            
            if (checkin != null && !checkin.isEmpty() && checkout != null && !checkout.isEmpty()) {
                for (RoomDto room : rooms) {
                    int bookingCount = mapper.checkRoomBookingCount(room.getRoomId(), checkin, checkout);
                    
                    int remaining = room.getRoomCount() - bookingCount;
                    
                    room.setRemainingCount(remaining > 0 ? remaining : 0);
                    
                    if (remaining <= 0) {
                        room.setAvailable(false);
                    }
                }
            } else {
                for (RoomDto room : rooms) {
                    room.setRemainingCount(room.getRoomCount());
                }
            }
            detail.setRooms(rooms);
        }
        
        return detail;
	}


	@Override
	public RoomDto findRoomById(String roomId) {
		return mapper.findRoomById(roomId);
	}
	
	@Override
    public int getBookmarkCount(Long placeId) {
        return mapper.getBookmarkCountByPlaceId(placeId);
    }


	@Override
    @Transactional
    public boolean acquireLock(String roomId, String checkin, String checkout, String sessionId) {
        mapper.deleteExpiredLocks();

        // 락을 가지고 있다면? -> 시간 5분 다시 채워주고 통과
        if (mapper.checkMyLock(roomId, checkin, sessionId) > 0) {
            mapper.updateLockTime(roomId, checkin, sessionId);
            return true;
        } 
        
        // 내가 락이 없다면, 방이 남아있는지 확인
        RoomDto room = mapper.findRoomById(roomId);
        int totalRoomCount = room.getRoomCount(); 
        
        // 현재 확정된 예약 건수
        int bookedCount = mapper.checkRoomBookingCount(roomId, checkin, checkout);
        
        // 현재 다른 사람들이 결제 진행 중인(락을 건) 건수
        int lockedCount = mapper.countActiveLocks(roomId, checkin, sessionId);

        // 예약된 방 + 락 걸린 방의 합이 총 방 개수보다 크거나 같으면 거절
        if ((bookedCount + lockedCount) >= totalRoomCount) {
            return false;
        }

        // 방이 남아있다면 내 이름으로 락 생성
        mapper.insertRoomLock(roomId, checkin, sessionId);
        return true;
    }


	@Override
    public void releaseLock(String roomId, String checkin, String sessionId) {
        mapper.deleteRoomLock(roomId, checkin, sessionId);
    }


	@Override
    @Transactional(rollbackFor = Exception.class) 
    public void processReservation(ReservationRequestDto dto, String sessionId) {
        
		if (dto.getRequest() == null || dto.getRequest().trim().isEmpty()) {
            dto.setRequest("요청사항 없음");
        }
		
        mapper.insertOrder(dto);
        
        mapper.insertReservation(dto);
        
        mapper.insertOrderDetail(dto);
        
        mapper.insertPayment(dto);
        
        mapper.deleteRoomLock(dto.getRoomId(), dto.getCheckin(), sessionId);
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


	@Override
    public List<String> getFullyBookedDates(Long placeId) {
        // 1. 해당 숙소의 전체 객실 수 가져오기
        int totalRooms = mapper.getTotalRoomCountByPlace(placeId);
        if (totalRooms == 0) return Collections.emptyList();

        // 2. 해당 숙소의 미래 예약 내역 가져오기
        List<Map<String, Object>> reservations = mapper.selectFutureReservationsByPlace(placeId);

        // 3. 날짜별 예약 건수를 누적할 Map
        Map<java.time.LocalDate, Integer> dateCountMap = new HashMap<>();
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (Map<String, Object> res : reservations) {
            java.time.LocalDate checkIn = java.time.LocalDate.parse(String.valueOf(res.get("checkIn")), formatter);
            java.time.LocalDate checkOut = java.time.LocalDate.parse(String.valueOf(res.get("checkOut")), formatter);

            // 퇴실일 전날까지만 카운트 +1
            for (java.time.LocalDate date = checkIn; date.isBefore(checkOut); date = date.plusDays(1)) {
                dateCountMap.put(date, dateCountMap.getOrDefault(date, 0) + 1);
            }
        }

        // 4. 예약 꽉 찬 날짜만 추출
        List<String> fullyBookedDates = new ArrayList<>();
        for (Map.Entry<java.time.LocalDate, Integer> entry : dateCountMap.entrySet()) {
            if (entry.getValue() >= totalRooms) {
                fullyBookedDates.add(entry.getKey().format(formatter));
            }
        }

        Collections.sort(fullyBookedDates);
        return fullyBookedDates;
    }


	@Override
	public ReservationRequestDto getReservationInfobyId(Long reservationId) {
		try {
			return mapper.getReservationInfobyId(reservationId);
		} catch (Exception e) {
			log.info("getRoomIdbyReservationId : ", e);
		}
		return null;
	}
	
	@Override
	public boolean checkReviewExistsByReservationId(Long reservationId) {
        int count = mapper.checkReviewExistsByReservationId(reservationId);
        return count > 0;
    }


	@Override
	public void insertReview(ReviewDto dto) {
		mapper.insertReview(dto);

		if (dto.getUploadFiles() != null && !dto.getUploadFiles().isEmpty()) {
            for (MultipartFile file : dto.getUploadFiles()) {
                if (file.isEmpty()) continue; 
                
                try {
                    String saveFilename = storageService.uploadFileToServer(file, uploadPath);
                    
                    if (saveFilename != null) {
                        mapper.insertReviewImage(dto.getReviewId(), saveFilename);
                    }
                } catch (Exception e) {
                    log.error("리뷰 이미지 업로드 실패", e);
                    throw new RuntimeException("파일 업로드 중 오류가 발생했습니다.");
                }
            }
		}
	}


	@Override
	public ReviewStatsDto getReviewStats(Long placeId) {
		return mapper.getReviewStatsByPlaceId(placeId);
	}


	@Override
	public List<ReviewDto> getReviewList(Long placeId, String sort, String roomId, int offset, int size) {
		return mapper.getReviewListByPlaceId(placeId, sort, roomId, offset, size);
	}


	@Override
    @Transactional(rollbackFor = Exception.class) 
    public void deleteReview(Long reviewId) {
        List<String> imageUrls = mapper.selectReviewImagesByReviewId(reviewId);
        
        if (imageUrls != null && !imageUrls.isEmpty()) {
            for (String fileName : imageUrls) {
                storageService.deleteFile(uploadPath, fileName);
            }
        }
        
        mapper.deleteReviewImagesByReviewId(reviewId);
        
        mapper.deleteReview(reviewId);
    }


	@Override
	public List<RoomDto> getRoomsByPlaceId(Long placeId) {
		return mapper.selectRoomsByPlaceId(placeId);
	}
	
	
	
	@Override
	public ReviewDto getReviewById(Long reviewId) {
	    return mapper.getReviewById(reviewId);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void updateReview(ReviewDto dto) {
	    mapper.updateReview(dto);

	    // 물리적(서버) 파일 삭제 처리
	    List<String> oldImages = mapper.selectReviewImagesByReviewId(dto.getReviewId()); // 원래 DB에 있던 사진들
	    List<String> retainImages = dto.getRetainImageUrls(); // 사용자가 안 지우고 남긴 사진들
	    if (retainImages == null) retainImages = new ArrayList<>();

	    if (oldImages != null) {
	        for (String oldImg : oldImages) {
	            // 남기기로 한 목록에 원래 사진이 없다면 = 사용자가 X 버튼을 눌러 지웠다는 뜻
	            if (!retainImages.contains(oldImg)) {
	                // 서버 폴더에서 실제 파일을 삭제합니다.
	                storageService.deleteFile(uploadPath, oldImg);
	            }
	        }
	    }

	    // 기존 매퍼 활용: DB 이미지 매핑 싹 다 지우기
	    mapper.deleteReviewImagesByReviewId(dto.getReviewId());

	    // 남기기로 한 기존 사진들을 DB에 다시 INSERT
	    for (String retainImg : retainImages) {
	        mapper.insertReviewImage(dto.getReviewId(), retainImg);
	    }

	    // 새로 첨부한 사진 서버 업로드 및 DB INSERT
	    if (dto.getUploadFiles() != null && !dto.getUploadFiles().isEmpty()) {
	        for (MultipartFile file : dto.getUploadFiles()) {
	            if (file.isEmpty()) continue;
	            try {
	                String saveFilename = storageService.uploadFileToServer(file, uploadPath);
	                if (saveFilename != null) {
	                    mapper.insertReviewImage(dto.getReviewId(), saveFilename);
	                }
	            } catch (Exception e) {
	                log.error("리뷰 이미지 수정 업로드 실패", e);
	                throw new RuntimeException("파일 업로드 중 오류 발생");
	            }
	        }
	    }
	}


	@Override
    public int getReviewCount(Long placeId, String roomId) {
        return mapper.getReviewCount(placeId, roomId);
    }


	@Override
	public List<String> getReviewPhotos(Long placeId, String roomId) {
		return mapper.getReviewPhotosByPlaceId(placeId, roomId);
	}
	
}
