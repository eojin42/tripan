package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;
 
import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.admin.domain.dto.PartnerManageDto;
 
@Mapper
public interface PartnerManageMapper {
 
	List<PartnerManageDto> selectAllPartners();
    List<PartnerManageDto> selectActivePartners();
    int updatePartnerStatus(Map<String, Object> params);
    void insertPartner(Map<String, Object> params);
    List<Map<String, Object>> selectPartnerDocs(Long applyId);
    PartnerManageDto selectPartnerDetail(Long partnerId);
    int selectApprovedThisMonth();
    void insertPartnerContract(Map<String, Object> params);
    List<Long> selectExpiredPartnerIds();
    void updatePartnerActiveStatus(Map<String, Object> params);
    void insertPartnerStatusPending(Map<String, Object> params); // 신규 등록 시 pending상태 등록
}
