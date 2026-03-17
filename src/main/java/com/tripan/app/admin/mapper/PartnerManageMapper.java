package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;
 
import org.apache.ibatis.annotations.Mapper;
 
@Mapper
public interface PartnerManageMapper {
 
    /** 파트너 전체 목록 조회 */
    List<Map<String, Object>> selectAllPartners();
 
    /** 활성 파트너 목록 조회 (status = 'ACTIVE') */
    List<Map<String, Object>> selectActivePartners();
 
    /**
     * 파트너 상태 업데이트 (승인 / 반려 / 차단 공통)
     * params: partnerId, status, commissionRate(nullable), rejectReason(nullable)
     * @return 변경된 row 수
     */
    int updatePartnerStatus(Map<String, Object> params);
}
