package com.tripan.app.service;

public interface PointService {
    long getLatestPoint(Long memberId);
    
    void processPointForOrder(Long memberId, String orderId, long usedPoint, long earnPoint);

	void processPointForCancel(Long memberId, String orderId, long usedPoint, long earnPoint);
}
