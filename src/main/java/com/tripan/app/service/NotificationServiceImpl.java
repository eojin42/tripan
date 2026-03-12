package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.TripNotification;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.trip.repository.TripNotificationRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final TripMemberRepository       memberRepo;
    private final TripNotificationRepository notifRepo;

    @Override
    @Transactional
    public void notifyAll(Long tripId, Long senderId, String message, String type) {
        try {
            memberRepo.findByTripId(tripId).stream()
                .filter(m -> "ACCEPTED".equals(m.getInvitationStatus()))
                .filter(m -> senderId == null || !m.getMemberId().equals(senderId))
                .forEach(m -> saveNotification(tripId, m.getMemberId(), senderId, message, type));
        } catch (Exception e) {
            log.warn("[NotificationService] 알림 발송 실패: tripId={}, error={}", tripId, e.getMessage());
        }
    }

    @Override
    @Transactional
    public void notifyOne(Long tripId, Long receiverId, Long senderId, String message, String type) {
        try {
            saveNotification(tripId, receiverId, senderId, message, type);
        } catch (Exception e) {
            log.warn("[NotificationService] 단건 알림 실패: receiverId={}, error={}", receiverId, e.getMessage());
        }
    }

    // 내부 저장 공통 로직
    private void saveNotification(Long tripId, Long receiverId, Long senderId, String message, String type) {
        if (receiverId == null) return;
        TripNotification n = new TripNotification();
        n.setTripId(tripId);
        n.setReceiverId(receiverId);
        n.setSenderId(senderId);
        n.setMessage(message);
        n.setType(type);
        n.setIsRead(0);
        notifRepo.save(n);
    }
}