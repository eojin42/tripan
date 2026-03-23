package com.tripan.app.domain.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PointSummaryDto {
	private int  totalPoint;  // 현재 보유 포인트 (최신 rem_point)
    private int  monthEarn;   // 이번 달 적립 합계 (point_amount > 0)
    private int  monthUse;    // 이번 달 사용 합계 (point_amount < 0, 절댓값)
 
    private List<PointDto> list;        // 전체 포인트 내역 (최신순)
}
