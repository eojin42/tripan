package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MagazineBlockDto {

    private int    blockId;
    private int    articleId;
    private String blockType;   // text|h3|img|pair|quote|caption
    private int    sortOrder;
    private String content;     // text / h3 / quote / caption 텍스트
    private String imageUrl;    // img 블록 단독 이미지
    private String imageLeft;   // pair 블록 왼쪽
    private String imageRight;  // pair 블록 오른쪽
    private String citeText;    // quote 블록 출처

}