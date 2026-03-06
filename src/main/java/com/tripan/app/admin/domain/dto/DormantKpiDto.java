package com.tripan.app.admin.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DormantKpiDto {

    /** 전체 휴면 회원 수 */
    private long totalDormant;

    /** 30일 내 파기 예정 회원 수 */
    private long willDeleteCount;

    /** 최근 7일 내 복귀 회원 수 */
    private long reactivatedCount;
}