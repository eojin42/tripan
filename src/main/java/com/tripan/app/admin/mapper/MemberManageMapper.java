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

    // 회원 목록/KPI
    MemberKpiDto      selectMemberKpi();
    List<MemberDto>   selectAllMembers();
    MemberDto         selectMemberDetail(@Param("memberId") Long memberId);

    // 상태/권한 변경
    void updateMemberStatus(
        @Param("memberId")  Long   memberId,
        @Param("newStatus") String newStatus,
        @Param("reason")    String reason
    );

    void updateMemberRole(
        @Param("memberId") Long   memberId,
        @Param("newRole")  String newRole
    );

    void bulkUpdateMemberStatus(
        @Param("memberIds") List<Long> memberIds,
        @Param("newStatus") String     newStatus,
        @Param("reason")    String     reason
    );

    // 뱃지 관리
    void insertMemberBadge(
        @Param("memberId")  Long   memberId,
        @Param("badgeCode") String badgeCode,
        @Param("grantDate") String grantDate,
        @Param("memo")      String memo
    );

    void deleteMemberBadge(
        @Param("memberId") Long memberId,
        @Param("badgeId")  Long badgeId
    );

    // 휴면 회원
    DormantKpiDto          selectDormantKpi();
    List<DormantMemberDto> selectDormantMembers();

    // 휴면 복귀
    void restoreDormantMember(@Param("email") String email);

    // 휴면 파기
    void deleteDormantMemberData(@Param("email") String email);
    void bulkDeleteDormantMemberData(@Param("emails") List<String> emails);

    // 메일 발송 이력 기록
    void insertMailLog(@Param("email") String email);
}
