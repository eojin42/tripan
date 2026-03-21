package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommunityFreeboardCommentDto {
    
    // 댓글 기본 정보
    private Long commentId;   
    private Long boardId;     // 어느 게시글에 달린 댓글인지
    private Long memberId;    // 누가 썼는지 (작성자 번호)
    private String content;   // 댓글 내용
    private String createdAt; // 작성 시간
    
    // 작성자 조인 정보 
    private String nickname;
    private String profilePhoto;
    
    private int status;
    
}