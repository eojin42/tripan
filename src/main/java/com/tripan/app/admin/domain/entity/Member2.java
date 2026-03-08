package com.tripan.app.admin.domain.entity;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "member2")
@Getter @Setter
public class Member2 {

    @Id
    @Column(name = "member_id")
    private Long memberId;

    @MapsId 
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member1 member1;

    @Column(length = 50)
    private String nickname;

    @Column(name = "profile_image", length = 255)
    private String profileImage;

    @Lob
    private String bio;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "preferred_region", length = 100)
    private String preferredRegion;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    @Column(name = "equipped_badge_id")
    private Long equippedBadgeId;
}