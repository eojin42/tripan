package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;
 
import org.apache.ibatis.annotations.Mapper;
 
@Mapper
public interface PartnerManageMapper {
 
	List<Map<String, Object>> selectAllPartners();
    List<Map<String, Object>> selectActivePartners();
    int updatePartnerStatus(Map<String, Object> params);
    void insertPartner(Map<String, Object> params);
    List<Map<String, Object>> selectPartnerDocs(Long applyId);
}
