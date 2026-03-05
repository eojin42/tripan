package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.entity.Member1;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper 
public interface MemberManageMapper {

    List<MemberDto> selectAllMembers();

    MemberDto selectMemberDetail(Long memberId);
}