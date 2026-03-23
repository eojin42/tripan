package com.tripan.app.service;

import com.tripan.app.domain.dto.PointSummaryDto;

public interface PointService {
    long getLatestPoint(Long memberId);
    
    void processPointForOrder(Long memberId, String orderId, long usedPoint, long earnPoint);

	void processPointForCancel(Long memberId, String orderId, long usedPoint, long earnPoint);
	public PointSummaryDto getPointSummary(Long memberId);
}
