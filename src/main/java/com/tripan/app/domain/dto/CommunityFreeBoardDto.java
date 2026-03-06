package com.tripan.app.domain.dto;

import org.springframework.web.multipart.MultipartFile;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommunityFreeBoardDto {
    // 게시글 기본 정보
    private Long boardId;
    private Long memberId;      // 작성자 FK
    private String category;    // tip, question, review
    private String title;
    private String content;     
    private String thumbnailUrl;
    private int viewCount;
    private int likeCount;
    private int replyCount;
    private String createdAt;   // TIMESTAMP
    private String updatedAt;

    private String nickname;
    private String profilePhoto;

    private MultipartFile uploadFile;
}