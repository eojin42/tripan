<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<div style="padding: 24px; display: flex; flex-direction: column; gap: 16px;">
    
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <img src="${not empty feed.profileImage ? pageContext.request.contextPath += '/uploads/profile/' += feed.profileImage : pageContext.request.contextPath += '/dist/images/default.png'}" 
                 style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color);">
            <div>
                <h4 style="margin: 0 0 4px; font-size: 16px; font-weight: 800; color: var(--text-black);">${feed.nickname}</h4>
                <p style="margin: 0; font-size: 12px; color: var(--text-gray);">${feed.createdAt}</p>
            </div>
        </div>
        
        <div style="display: flex; gap: 12px; align-items: center;">
            <c:if test="${loginUserId == feed.memberId}">
                <button onclick="deletePost(${feed.postId})" style="background: none; border: none; font-size: 13px; color: #FF6B6B; font-weight: 800; cursor: pointer;">🗑️ 글 삭제</button>
            </c:if>
            <button onclick="closeFeedModal()" style="background: none; border: none; font-size: 24px; color: var(--text-gray); cursor: pointer;">✕</button>
        </div>
    </div>

    <div style="font-size: 15px; line-height: 1.6; color: var(--text-dark); white-space: pre-wrap;">${feed.content}</div>

    <c:if test="${not empty feed.imageUrl}">
        <div style="width: 100%; border-radius: 16px; overflow: hidden; border: 1px solid var(--border-color);">
            <c:set var="images" value="${feed.imageUrl.split(',')}" />
            <img src="${pageContext.request.contextPath}/uploads/feed/${images[0]}" style="width: 100%; max-height: 400px; object-fit: cover; display: block;">
        </div>
    </c:if>

    <div style="display: flex; gap: 16px; align-items: center; border-top: 1px dashed var(--border-color); padding-top: 12px;">
        <button onclick="toggleFeedLike(this, ${feed.postId})" style="background: none; border: none; cursor: pointer; display: flex; align-items: center; gap: 6px; padding: 0;">
            <span class="heart-icon" style="font-size: 20px; color: #FF6B6B;">♡</span> 
            <span class="like-cnt" style="font-size: 14px; font-weight: 800; color: var(--text-dark);">${feed.likeCount}</span>
        </button>
        <span style="font-size: 14px; color: var(--text-gray); font-weight: 800;">💬 댓글 ${comments.size()}</span>
    </div>

    <div style="background: #f8fafc; border-radius: 12px; padding: 16px; margin-top: 4px;">
        <div style="max-height: 250px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; padding-right: 8px;">
            <c:choose>
                <c:when test="${empty comments}">
                    <div style="text-align: center; color: var(--text-gray); font-size: 13px; padding: 20px 0;">아직 댓글이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="comment" items="${comments}">
                        <div style="display: flex; gap: 10px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px;">
                            <img src="${not empty comment.profileImage ? pageContext.request.contextPath += '/uploads/profile/' += comment.profileImage : pageContext.request.contextPath += '/dist/images/default.png'}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;">
                            <div style="flex: 1;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                    <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">${comment.nickname}</span>
                                    
                                    <div style="display: flex; gap: 8px; align-items: center;">
                                        <span style="font-size: 11px; color: var(--text-gray);">${comment.createdAt}</span>
                                        <c:if test="${loginUserId == comment.memberId}">
                                            <span style="font-size: 11px; color: #FF6B6B; font-weight: 800; cursor: pointer;" onclick="deleteFeedComment(${comment.commentId}, ${feed.postId})">삭제</span>
                                        </c:if>
                                    </div>
                                </div>
                                <div style="font-size: 13px; color: var(--text-black); line-height: 1.4;">${comment.content}</div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>