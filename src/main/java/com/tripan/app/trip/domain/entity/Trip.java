package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "trip")
@Getter @Setter
public class Trip {

	@Id
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "trip_seq_gen")
	@SequenceGenerator(name = "trip_seq_gen", sequenceName = "trip_seq", allocationSize = 1)
	private Long tripId;

    /** 여행 생성자 */
    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Column(name = "trip_name", nullable = false, length = 100)
    private String tripName;

    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDateTime endDate;

    @Column(name = "description", length = 2000)
    private String description;

    /**
     * 대표 썸네일 URL
     * - 업로드: /dist/images/thumbnails/{uuid}.jpg
     * - 미설정: /dist/images/logo.png
     */
    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl;

    /**
     * 총 예산 (null 허용 — 미입력 가능)
     */
    @Column(name = "total_budget", precision = 20, scale = 2)
    private BigDecimal totalBudget;

    /** 0: 비공개, 1: 공개 */
    @Column(name = "is_public", nullable = false)
    private Integer isPublic = 0;

    /**
     * PLANNING  → 계획중 (기본)
     * ONGOING   → 여행중 (스케줄러 자동 변경)
     * COMPLETED → 완료   (스케줄러 자동 변경)
     */
    @Column(name = "status", nullable = false, length = 20)
    private String status = "PLANNING";

    /** 담아가기 횟수 */
    @Column(name = "scrap_count", nullable = false)
    private Integer scrapCount = 0;

    /** 초대 링크 코드 */
    @Column(name = "invite_code", unique = true, length = 50)
    private String inviteCode;

    /** COUPLE / FAMILY / FRIENDS / SOLO / BUSINESS (null 허용) */
    @Column(name = "trip_type", length = 20)
    private String tripType;

    /** 여행지 표시용 텍스트 (예: "제주, 부산") */
    @Column(name = "cities", length = 300)
    private String cities;

    /**
     * 스크랩 원본 trip_id
     * - 직접 생성 → null
     * - 담아오기   → 원본 tripId (본인 스크랩도 포함)
     */
    @Column(name = "original_trip_id")
    private Long originalTripId;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
