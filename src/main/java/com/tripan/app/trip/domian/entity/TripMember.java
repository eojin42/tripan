package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "trip_member",
    uniqueConstraints = {  // 한 명의 유저가 같은 여행에 중복 등록 방지
        @UniqueConstraint(columnNames = {"trip_id", "member_id"})
    },
    indexes = {  // "내 여행 목록 조회" 성능 최적화
        @Index(name = "idx_trip_member_user", columnList = "member_id")
    }
)
@Getter @Setter
public class TripMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "trip_member_id")
    private Long tripMemberId;

    @Column(name = "trip_id", nullable = false)
    private Long tripId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    // OWNER(방장), EDITOR(편집 가능), VIEWER(읽기 전용)
    @Column(name = "role", nullable = false, length = 20)
    private String role; 

    @Column(name = "joined_at")
    private LocalDateTime joinedAt = LocalDateTime.now();

    // PENDING(초대중), ACCEPTED(수락), DECLINED(거절)
    @Column(name = "invitation_status", length = 20)
    private String invitationStatus = "PENDING";

}