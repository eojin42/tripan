package com.tripan.app.service;


// 여행방 전체 멤버에게 알림을 발송하는 공통 서비스.
public interface NotificationService {

    /**
     * 여행방 전체 ACCEPTED 멤버에게 알림 발송 (발신자 본인 제외)
     *
     * @param tripId   여행 ID
     * @param senderId 발신자 멤버 ID (본인 제외용)
     * @param message  알림 메시지
     * @param type     알림 유형 (SYSTEM/INVITE/ITINERARY/CHECKLIST/VOTE/EXPENSE/TRIP 등)
     */
    void notifyAll(Long tripId, Long senderId, String message, String type);

    /**
     * 특정 멤버 1명에게 알림 발송
     * * @param tripId     여행 ID
     * @param receiverId 수신자 멤버 ID
     * @param senderId   발신자 멤버 ID
     * @param message    알림 메시지
     * @param type       알림 유형
     */
    void notifyOne(Long tripId, Long receiverId, Long senderId, String message, String type);
}