package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;

@Mapper 
public interface MemberManageMapper {

    List<MemberDto> selectAllMembers();

    MemberDto selectMemberDetail(Long memberId);
    MemberKpiDto selectMemberKpi();
}