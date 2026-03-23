package com.tripan.app.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.PointDto;
import com.tripan.app.domain.dto.PointSummaryDto;
import com.tripan.app.mapper.PointMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class PointServiceImpl implements PointService{
	private final PointMapper pointMapper;

	@Override
	public long getLatestPoint(Long memberId) {
		Long point = pointMapper.getLatestPoint(memberId);
        return point == null ? 0L : point;
	}

	@Override
	public void processPointForOrder(Long memberId, String orderId, long usedPoint, long earnPoint) {
        long currentPoint = getLatestPoint(memberId);

        if (usedPoint > 0) {
            currentPoint -= usedPoint;
            
            PointDto useDto = new PointDto();
            useDto.setMemberId(memberId);
            useDto.setOrderId(orderId);
            useDto.setChangeReason("상품 결제 사용");
            useDto.setPointAmount(-usedPoint); 
            useDto.setRemPoint(currentPoint);
            
            pointMapper.insertPoint(useDto);
        }

        if (earnPoint > 0) {
            currentPoint += earnPoint; 
            
            PointDto earnDto = new PointDto();
            earnDto.setMemberId(memberId);
            earnDto.setOrderId(orderId);
            earnDto.setChangeReason("숙박 결제 적립");
            earnDto.setPointAmount(earnPoint); 
            earnDto.setRemPoint(currentPoint);
            
            pointMapper.insertPoint(earnDto);
        }
		
	}
	
	@Override
	public void processPointForCancel(Long memberId, String orderId, long usedPoint, long earnPoint) {
	    long currentPoint = getLatestPoint(memberId);

	    // 썼던 포인트 다시 돌려주기 (+)
	    if (usedPoint > 0) {
	        currentPoint += usedPoint;
	        PointDto refundDto = new PointDto();
	        refundDto.setMemberId(memberId); refundDto.setOrderId(orderId);
	        refundDto.setChangeReason("예약취소(복구)");
	        refundDto.setPointAmount(usedPoint); 
	        refundDto.setRemPoint(currentPoint);
	        pointMapper.insertPoint(refundDto);
	    }

	    // 결제로 얻었던 포인트 다시 회수 (-)
	    if (earnPoint > 0) {
	        currentPoint -= earnPoint;
	        PointDto clawbackDto = new PointDto();
	        clawbackDto.setMemberId(memberId); clawbackDto.setOrderId(orderId);
	        clawbackDto.setChangeReason("예약취소(회수)");
	        clawbackDto.setPointAmount(-earnPoint); 
	        clawbackDto.setRemPoint(currentPoint);
	        pointMapper.insertPoint(clawbackDto);
	    }
	}

	@Override
	public PointSummaryDto getPointSummary(Long memberId) {
		Long latest = pointMapper.getLatestPoint(memberId);
		 List<PointDto> list = pointMapper.selectPointList(memberId);
		 
        return PointSummaryDto.builder()
                .totalPoint(latest != null ? latest.intValue() : 0)
                .monthEarn (pointMapper.selectMonthEarn  (memberId))
                .monthUse  (pointMapper.selectMonthUse   (memberId))
                .list(list)
                .build();
	}
}
