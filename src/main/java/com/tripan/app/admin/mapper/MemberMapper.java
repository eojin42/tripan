package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.entity.Member1;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper 
public interface MemberMapper {

    List<Member1> selectAllMembers();

    Member1 selectMemberDetail(Long memberId);
}