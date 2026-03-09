package com.tripan.app.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "follow",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_follow", columnNames = {"follower_id", "following_id"}),
    indexes = {
        @Index(name = "idx_follow_follower",  columnList = "follower_id"),
        @Index(name = "idx_follow_following", columnList = "following_id")
    }
)

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class Follow {

    @Id
    @SequenceGenerator(name="SEQ_FOLLOW_GEN", sequenceName="SEQ_FOLLOW", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="SEQ_FOLLOW_GEN")
    @Column(name = "follow_id")
    private Long followId;

    // 팔로우를 건 사람
    @Column(name = "follower_id", nullable = false)
    private Long followerId;

    // 팔로우를 받은 사람
    @Column(name = "following_id", nullable = false)
    private Long followingId;

    @Column(name = "follow_at", nullable = false)
    private LocalDateTime followAt = LocalDateTime.now();
}