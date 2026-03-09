package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class CommunityMateCommentDto {
    private Long commentId;
    private Long mateId;
    private Long memberId;
    private String content;
    private Long parentId;
    private String createdAt;

    private String nickname;
    private String profilePhoto;
}