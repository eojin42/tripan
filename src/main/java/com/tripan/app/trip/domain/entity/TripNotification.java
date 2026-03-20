package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "trip_notification")
@Getter @Setter
public class TripNotification {

	@Id
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "noti_seq_gen")
	@SequenceGenerator(name = "noti_seq_gen", sequenceName = "SEQ_NOTIFICATION", allocationSize = 1)
	@Column(name = "notification_id")
	private Long notificationId;

    @Column(name = "trip_id", nullable = false)
    private Long tripId;

    /** 받는 사람 */
    @Column(name = "receiver_id", nullable = false)
    private Long receiverId;

    /** 보낸 사람 (시스템 알림이면 null) */
    @Column(name = "sender_id")
    private Long senderId;

    @Column(name = "message", nullable = false, length = 500)
    private String message;

    /** SYSTEM / INVITE / ACCEPT / VOTE / COMMENT */
    @Column(name = "type", nullable = false, length = 20)
    private String type;

    /** 0: 미읽음, 1: 읽음 */
    @Column(name = "is_read", nullable = false)
    private Integer isRead = 0;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
