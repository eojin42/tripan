package com.tripan.app.admin.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "member3")
@Getter @Setter
public class Member3 {

    @Id
    @Column(name = "member_id")
    private Long id;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member1 member1;

    // 탈퇴일
    @Column(name = "withdraw_date", nullable = false)
    private LocalDateTime withdrawDate;

    // 탈퇴 사유
    @Column(name = "withdraw_reason", length = 255, nullable = false)
    private String withdrawReason;
}