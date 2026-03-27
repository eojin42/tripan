package com.tripan.app.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "place_review")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class PlaceReview {

    @Id
    @SequenceGenerator(name="SEQ_PLACE_REVIEW_GEN", sequenceName="SEQ_PLACE_REVIEW", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="SEQ_PLACE_REVIEW_GEN")
    @Column(name = "review_id")
    private Long reviewId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Column(name = "place_id", nullable = false)
    private Long placeId;

    @Column(name = "rating")
    private Integer rating;

    @Lob
    @Column(name = "content")
    private String content;

    @Lob
    @Column(name = "images")
    private String images;

    @Transient
    @Column(name = "visit_date")
    private LocalDate visitDate;

    @Column(name = "helpful_count")
    private Integer helpfulCount;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Lob
    @Column(name = "owner_reply")
    private String ownerReply;

    @Column(name = "reply_created_at")
    private LocalDateTime replyCreatedAt;
}