package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.admin.domain.dto.PartnerManageDto;
 
@Mapper
public interface PartnerManageMapper {
 
	 // ── 조회 ──────────────────────────────────────────────────────────────
    List<PartnerManageDto>    selectAllPartners();
    List<PartnerManageDto>    selectActivePartners();
    PartnerManageDto          selectPartnerDetail(Long partnerId);
    int                       selectApprovedThisMonth();
    long                      selectTotalMonthlySales();
    List<Long>                selectExpiredPartnerIds();
 
    /** 파트너가 운영 중인 숙소 목록 */
    List<Map<String, Object>> selectPlacesByPartnerId(Long partnerId);
 
    /** 파트너 소속 숙소의 예약 내역 목록 */
    List<Map<String, Object>> selectReservationsByPartnerId(Long partnerId);
 
    /** 제출 서류 목록 */
    List<Map<String, Object>> selectPartnerDocs(Long applyId);
 
    // ── 상태 변경 ──────────────────────────────────────────────────────────
    void insertPartnerStatus(Map<String, Object> params);        // → updatePartnerStatus (XML id 맞춤)
    void updatePartnerStatus(Map<String, Object> params);
    void updatePartnerActiveStatus(Map<String, Object> params);
    void updateMemberRoleToPartner(Map<String, Object> params);
 
    // ── 등록 ──────────────────────────────────────────────────────────────
    void insertPartner(Map<String, Object> params);
    void insertPartnerStatusPending(Map<String, Object> params);
    void insertPartnerContract(Map<String, Object> params);
}
