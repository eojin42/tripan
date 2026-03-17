package com.tripan.app.admin.service;

import java.util.List;
import java.util.Map;
 
public interface PartnerManageService {
 
    /** 파트너 전체 목록 조회 */
    List<Map<String, Object>> getAllPartners();
 
    /** 활성 파트너 옵션 목록 (쿠폰 등록 select용) */
    List<Map<String, Object>> getActivePartners();
 
    /** 파트너 승인 */
    void approvePartner(Long partnerId, Double commissionRate);
 
    /** 파트너 반려 */
    void rejectPartner(Long partnerId, String rejectReason);
 
    /** 파트너 차단 */
    void suspendPartner(Long partnerId);
}
