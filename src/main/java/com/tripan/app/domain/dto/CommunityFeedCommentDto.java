package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommunityFeedCommentDto {
    
    private Long commentId;        // 댓글 고유 번호
    private Long postId;           // 피드 게시글 번호
    private Long memberId;         // 작성자 번호
    private Long parentCommentId;  // 부모 댓글 번호 (대댓글용)
    private String content;        // 댓글 내용
    private String delYn;          // 삭제 여부 (N: 정상, Y: 삭제됨)
    private String createdAt;      // 작성 시간
    
    private String nickname;
    private String profileImage;
}