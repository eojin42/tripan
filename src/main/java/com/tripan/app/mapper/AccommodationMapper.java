package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.ReviewDto;
import com.tripan.app.domain.dto.ReviewStatsDto;
import com.tripan.app.domain.dto.RoomDto;

@Mapper
public interface AccommodationMapper {
	public List<AccommodationDto> selectAccommodationList(AdSearchConditionDto condition);
	
	AccommodationDetailDto selectAccommodationDetail(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
	AccommodationDetailDto selectAccommodationDetailForPartner(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
	void cancelReservationByPartnerStatus(@Param("reservationId") Long reservationId, @Param("reason")String cancelReason);
    
    public List<String> selectAccommodationImages(Long placeId);
    
    public List<RoomDto> selectRoomsByPlaceId(Long placeId);
    
    public RoomDto findRoomById(String roomId);
    
    int getBookmarkCountByPlaceId(Long placeId);
    
    // 동시성 문제 해결 관련
    void deleteExpiredLocks();
    int countActiveLocks(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    int checkMyLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    void insertRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    void updateLockTime(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    void deleteRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    
    // 예약, 결제 관련
    void insertOrder(ReservationRequestDto dto);
    void insertOrderDetail(ReservationRequestDto dto);
    void insertReservation(ReservationRequestDto dto);
    void insertPayment(ReservationRequestDto dto);
    
    
    // 북마크(찜) 관련
    int checkBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    void insertBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    void deleteBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    
    // 예약 필터링
    int checkRoomBookingCount(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("checkout") String checkout);
    int getTotalRoomCountByPlace(Long placeId);
    List<Map<String, Object>> selectFutureReservationsByPlace(Long placeId);
    
    // 예약 번호로 방 번호 조회
    ReservationRequestDto getReservationInfobyId(Long reservationId);
    
    // 예약 번호로 리뷰 존재 여부 확인
    int checkReviewExistsByReservationId(Long reservationId);
    
    // 리뷰 관련
    void insertReview(ReviewDto dto); 
    void insertReviewImage(@Param("reviewId") Long reviewId, @Param("imageUrl") String imageUrl); 
    
    List<String> selectReviewImagesByReviewId(Long reviewId);
    void deleteReviewImagesByReviewId(Long reviewId);
    void deleteReview(Long reviewId);
    
    int getReviewCount(@Param("placeId") Long placeId, @Param("roomId") String roomId);
    ReviewStatsDto getReviewStatsByPlaceId(Long placeId);
    List<ReviewDto> getReviewListByPlaceId(@Param("placeId") Long placeId,
    										@Param("sort") String sort, 
    										@Param("roomId") String roomId,
    										@Param("offset") int offset, 
                                            @Param("size") int size);
    
    ReviewDto getReviewById(Long reviewId);
    void updateReview(ReviewDto dto);
    
    List<String> getReviewPhotosByPlaceId(@Param("placeId") Long placeId, @Param("roomId") String roomId);
    
    // 예약 취소 관련
    Map<String, Object> getCancelInfo(Long reservationId);

    void cancelReservationStatus(Long reservationId);
    void cancelOrderStatus(String orderId);
    void cancelOrderDetailStatus(String orderId);
    void cancelPaymentStatus(String orderId);
    
    // 객실 상세 정보 및 편의시설 조회
    Map<String, Object> selectRoomDetailWithFacilities(String roomId);
    
    // 객실 상세 모달용 여러 장의 사진 조회
    List<String> selectRoomImagesByRoomId(String roomId);
}
