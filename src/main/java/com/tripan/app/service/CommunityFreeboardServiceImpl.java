package com.tripan.app.service;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;
import com.tripan.app.mapper.CommunityFreeBoardMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j; 

@Slf4j 
@Service
@RequiredArgsConstructor
public class CommunityFreeboardServiceImpl implements CommunityFreeboardService {

    private final CommunityFreeBoardMapper freeboardMapper;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    public List<CommunityFreeBoardDto> getBoardList() {
        return freeboardMapper.selectAll();
    }
    
    @Override
    public List<CommunityFreeBoardDto> getBoardList(String category) {
        if (category == null || "all".equals(category)) {
            return freeboardMapper.selectAll();
        } 
        else {
            return freeboardMapper.selectByCategory(category);
        }
    }

    @Override
    @Transactional
    public void registerBoard(CommunityFreeBoardDto dto) {
        if (dto.getFiles() != null && !dto.getFiles().isEmpty()) {
            MultipartFile file = dto.getFiles().get(0); 
            
            if (!file.isEmpty()) {
                String freeboardUploadPath = uploadRoot + "/freeboard/"; 
                File destDir = new File(freeboardUploadPath);
                if (!destDir.exists()) destDir.mkdirs();

                String originalFilename = file.getOriginalFilename();
                String cleanFilename = "lounge_img";
                
                if (originalFilename != null) {
                    cleanFilename = originalFilename.replaceAll("[^a-zA-Z0-9가-힣\\.\\-_]", "_");
                }
                
                String savedFilename = UUID.randomUUID().toString() + "_" + cleanFilename;
                try {
                    file.transferTo(new File(destDir, savedFilename));
                    // 🌟 쉼표 없이 단일 파일명으로 깔끔하게 저장!
                    dto.setThumbnailUrl(savedFilename); 
                } catch (Exception e) {
                    log.error("자유게시판 파일 업로드 실패", e);
                }
            }
        }

        freeboardMapper.insertBoard(dto);
    }

    @Override
    @Transactional
    public CommunityFreeBoardDto getBoardDetail(Long boardId, boolean updateView) {
    	if (updateView) {
            freeboardMapper.updateViewCount(boardId);
        }
        return freeboardMapper.selectById(boardId); 
    }
    
    @Override
    public List<CommunityFreeboardCommentDto> getCommentList(Long boardId) {
        return freeboardMapper.selectComments(boardId);
    }
    
    @Override
    @Transactional 
    public void registerComment(CommunityFreeboardCommentDto dto) {
        freeboardMapper.insertComment(dto);
        freeboardMapper.updateReplyCount(dto.getBoardId());
    }
    
    @Override
    @Transactional
    public int incrementLikeCount(Long boardId) {
    	freeboardMapper.updateLikeCount(boardId, 1);
        return freeboardMapper.getLikeCount(boardId);
    }
    
    @Override
    @Transactional
    public Map<String, Object> toggleLike(Long boardId, Long memberId) {
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("boardId", boardId);
        params.put("memberId", memberId);
        
        int isLiked = freeboardMapper.checkLike(params);
        String status;
        int amount;
        
        if (isLiked > 0) {
            freeboardMapper.deleteLike(params); // 취소
            amount = -1;
            status = "unliked";
        } else { 
            freeboardMapper.insertLike(params); // 추가
            amount = 1;
            status = "liked";
        }
        
        freeboardMapper.updateLikeCount(boardId, amount);
        int newCount = freeboardMapper.getLikeCount(boardId);
        
        return Map.of("status", status, "count", newCount);
    }
    
    @Override
    public int checkLikeStatus(Long boardId, Long memberId) {
        Map<String, Object> params = new HashMap<>();
        params.put("boardId", boardId);
        params.put("memberId", memberId);
        return freeboardMapper.checkLike(params); 
    }
    
    @Override
    @Transactional
    public boolean deleteBoard(Long boardId, Long currentMemberId) {
        Long writerId = freeboardMapper.getBoardWriterId(boardId);
        
        if (writerId == null) {
            log.warn("존재하지 않는 자유게시판 게시글 삭제 시도 - boardId: {}", boardId);
            return false;
        }
        
        if (!writerId.equals(currentMemberId)) {
            log.warn("자유게시판 게시글 삭제 권한 없음 - boardId: {}, 요청자: {}, 실제작성자: {}", boardId, currentMemberId, writerId);
            return false; 
        }
        
        int result = freeboardMapper.deleteBoard(boardId);
        return result > 0;
    }
    
    @Override
    @Transactional
    public boolean deleteComment(Long commentId, Long currentMemberId) {
        CommunityFreeboardCommentDto comment = freeboardMapper.selectCommentById(commentId);
        
        if (comment == null) {
            log.warn("존재하지 않는 자유게시판 댓글 삭제 시도 - commentId: {}", commentId);
            return false;
        }
        
        if (!comment.getMemberId().equals(currentMemberId)) {
            log.warn("자유게시판 댓글 삭제 권한 없음 - commentId: {}, 요청자: {}, 실제작성자: {}", commentId, currentMemberId, comment.getMemberId());
            return false; 
        }
        
        int result = freeboardMapper.deleteComment(commentId);
        
        if (result > 0) {
            freeboardMapper.decreaseReplyCount(comment.getBoardId()); 
        }
        
        return result > 0;
    }
    
    @Override
    @Transactional
    public boolean updateBoard(CommunityFreeBoardDto dto, Long currentMemberId) {
        Long writerId = freeboardMapper.getBoardWriterId(dto.getBoardId());
        
        if (writerId == null || !writerId.equals(currentMemberId)) {
            return false; 
        }
        
        
        int result = freeboardMapper.updateBoard(dto);
        return result > 0;
    }
    
}