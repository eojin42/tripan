package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.ReportManageDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ReportManageMapper {

    List<ReportManageDto> selectContentList(@Param("targetType") String targetType);

    List<ReportManageDto> selectReportList(
            @Param("targetType") String targetType,
            @Param("targetId")   Long   targetId);

    List<ReportManageDto> selectUserReportList();

    int countReportsByTarget(
            @Param("targetType") String targetType,
            @Param("targetId")   Long   targetId);

    int countReportsByReportedUser(@Param("reportedMemberId") Long reportedMemberId);

    Long selectContentOwnerId(
            @Param("targetType") String targetType,
            @Param("targetId")   Long   targetId);

    void hideFeedPost(@Param("targetId") Long targetId);
    void hidePostComment(@Param("targetId") Long targetId);
    void hideFreeboard(@Param("targetId") Long targetId);
    void hideFreeboardComment(@Param("targetId") Long targetId);
    void hideTravelMate(@Param("targetId") Long targetId);
    void hideTravelMateComment(@Param("targetId") Long targetId);

    void banMember(@Param("memberId") Long memberId);
    void insertBanStatus(@Param("memberId") Long memberId, @Param("memo") String memo);

    void updateReportStatus(
            @Param("targetType") String targetType,
            @Param("targetId")   Long   targetId);

    LocalDateTime selectLastRestoredAt(@Param("memberId") Long memberId);
}