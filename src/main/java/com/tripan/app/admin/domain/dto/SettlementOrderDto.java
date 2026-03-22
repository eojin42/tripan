package com.tripan.app.admin.domain.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 정산 상세 페이지 - 예약(주문) 건별 라인
 */
@Data
public class SettlementOrderDto {

    private String  orderId;            // orders.order_id
    private Long    reservationId;      // order_detail.reservation_id
    private Date    orderDate;          // orders.order_date
    private String  guestNickname;      // 예약자 닉네임

    private BigDecimal totalAmount;         // orders.total_amount      (할인 전)
    private BigDecimal couponDiscount;      // orders.coupon_discount   (쿠폰 전체 할인액)
    private BigDecimal pointDiscount;       // orders.point_discount
    private BigDecimal realTotalAmount;     // orders.real_total_amount (실제 결제액)

    // 쿠폰 사용 여부 & 부담 분리
    private BigDecimal couponPlatformAmt;   // coupon_usage.platform_discount_amount
    private BigDecimal couponPartnerAmt;    // coupon_usage.partner_discount_amount

    // 수수료
    private BigDecimal commissionRate;
    private BigDecimal commissionAmount;    // realTotalAmount × commissionRate / 100

    // 파트너 최종 수취액
    private BigDecimal partnerPayout;       // realTotalAmount - commissionAmount - couponPartnerAmt

    // 결제 상태
    private String  paymentStatus;         // payment.status
    private String  orderStatus;           // orders.status
    private String  reservationStatus;
}
