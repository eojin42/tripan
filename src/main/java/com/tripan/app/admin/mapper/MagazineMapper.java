package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.MagazineArticleDto;
import com.tripan.app.admin.domain.dto.MagazineBlockDto;

public interface MagazineMapper {
	List<MagazineArticleDto> selectAll();
    List<MagazineArticleDto> selectPublished();
    MagazineArticleDto       selectById(int articleId);
    int                      insertArticle(MagazineArticleDto dto);
    int                      updateArticle(MagazineArticleDto dto);
    int                      updateStatus(@Param("articleId") int articleId,
                                          @Param("status") int status);
    int                      deleteArticle(int articleId);
 
    // 블록
    List<MagazineBlockDto>   selectBlocksByArticleId(int articleId);
    int                      insertBlock(MagazineBlockDto dto);
    int                      deleteBlocksByArticleId(int articleId);
 
    // 태그
    List<String>             selectTagsByArticleId(int articleId);
    int                      insertTag(@Param("articleId") int articleId,
                                       @Param("tagName") String tagName);
    int                      deleteTagsByArticleId(int articleId);
}
