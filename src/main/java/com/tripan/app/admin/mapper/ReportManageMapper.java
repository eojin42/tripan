package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.ReportManageDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface ReportManageMapper {

    /* ── 콘텐츠 단위 집계 목록 ── */
    List<ReportManageDto> selectContentList(@Param("targetType") String targetType);

    /* ── 신고 상세 목록 ── */
    List<ReportManageDto> selectReportList(
            @Param("targetType") String targetType,
            @Param("targetId")   Long targetId);

    /* ── 이용자별 신고 목록 ── */
    List<ReportManageDto> selectUserReportList();

    /* ── 신고 건수 ── */
    int countReportsByTarget(
            @Param("targetType") String targetType,
            @Param("targetId")   Long targetId);

    int countReportsByReportedUser(@Param("reportedMemberId") Long reportedMemberId);

    /* ── 콘텐츠 작성자 조회 ── */
    Long selectContentOwnerId(
            @Param("targetType") String targetType,
            @Param("targetId")   Long targetId);

    /* ── 콘텐츠 비활성화 ── */
    int hideFeedPost(@Param("targetId")        Long targetId);
    int hidePostComment(@Param("targetId")     Long targetId);
    int hideFreeboard(@Param("targetId")       Long targetId);
    int hideFreeboardComment(@Param("targetId")Long targetId);
    int hideTravelMate(@Param("targetId")      Long targetId);
    int hideTravelMateComment(@Param("targetId")Long targetId);

    /* ── 콘텐츠 활성화 ── */
    int showFeedPost(@Param("targetId")        Long targetId);
    int showPostComment(@Param("targetId")     Long targetId);
    int showFreeboard(@Param("targetId")       Long targetId);
    int showFreeboardComment(@Param("targetId")Long targetId);
    int showTravelMate(@Param("targetId")      Long targetId);
    int showTravelMateComment(@Param("targetId")Long targetId);

    /* ── 유저 정지 ── */
    int banMember(@Param("memberId") Long memberId);
    int insertBanStatus(
            @Param("memberId") Long memberId,
            @Param("memo")     String memo);

    /* ── 신고 처리 완료 ── */
    int updateReportStatus(
            @Param("targetType") String targetType,
            @Param("targetId")   Long targetId);

    /* ── 복구 시점 조회 ── */
    LocalDateTime selectLastRestoredAt(@Param("memberId") Long memberId);

    /* ── FEED 글보기 ── */
    String selectFeedContent(@Param("postId") Long postId);
    List<Map<String,Object>> selectFeedComments(@Param("postId") Long postId);
    Long selectFeedPostIdByCommentId(@Param("commentId") Long commentId);

    /* ── FREEBOARD 글보기 ── */
    String selectFreeboardContent(@Param("boardId") Long boardId);
    List<Map<String,Object>> selectFreeboardComments(@Param("boardId") Long boardId);
    Long selectFreeboardIdByCommentId(@Param("commentId") Long commentId);

    /* ── MATE 글보기 ── */
    String selectMateContent(@Param("mateId") Long mateId);
    List<Map<String,Object>> selectMateComments(@Param("mateId") Long mateId);
    Long selectMateIdByCommentId(@Param("commentId") Long commentId);
}