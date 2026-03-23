package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;
import java.util.Date;
import java.util.List;

@Getter
@Setter
public class MagazineArticleDto {
    private int    articleId;
    private String category;
    private String layoutType;
    private String title;
    private String summary;
    private String thumbnailUrl;
    private String heroImgUrl;
    private String leadText;
    private int    status;
    private Date   pubDate;
    private int    sortOrder;
    private Date   regDate;
    private Date   modDate;

    private List<MagazineBlockDto> blocks;
    private List<String>           tags;

    public String getStatusLabel() {
        switch (status) {
            case 1:  return "게시중";
            case 2:  return "임시저장";
            case 3:  return "숨김";
            default: return "-";
        }
    }

    public String getCategoryLabel() {
        if (category == null) return "";
        switch (category) {
            case "EDITOR_CHOICE":  return "EDITOR'S CHOICE";
            case "TASTE":          return "TASTE";
            case "JOURNEY":        return "JOURNEY";
            case "LIFESTYLE":      return "LIFESTYLE";
            case "SPECIAL_REPORT": return "SPECIAL REPORT";
            default:               return category;
        }
    }

    public String getLayoutLabel() {
        if (layoutType == null) return "";
        switch (layoutType) {
            case "hero":      return "히어로";
            case "item-v":    return "세로형";
            case "item-h":    return "가로형";
            case "item-full": return "전체 너비";
            default:          return layoutType;
        }
    }
}