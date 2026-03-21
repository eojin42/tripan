package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;

@Mapper
public interface MemberManageMapper {

	MemberKpiDto           selectMemberKpi();
    List<MemberDto>        selectAllMembers();
    MemberDto              selectMemberDetail(Long memberId);
    DormantKpiDto          selectDormantKpi();
    List<DormantMemberDto> selectDormantMembers();
    
    void updateMember1Status(@Param("memberId") Long memberId, @Param("status") int status);
    void insertMemberStatusHistory(@Param("memberId") Long memberId, @Param("status") int status, @Param("memo") String memo);

   
}
