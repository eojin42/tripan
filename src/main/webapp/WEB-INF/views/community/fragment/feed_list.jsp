<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<style>
/* 피드 카드 전용 스타일 */
  .feed-card { padding: 0; overflow: hidden; margin-bottom: 0; }
  .feed-author { display: flex; align-items: center; justify-content: space-between; padding: 24px 28px; border-bottom: 1px solid rgba(0,0,0,0.05); }
  .author-left { display: flex; align-items: center; gap: 14px; }
  .author-left img { width: 44px; height: 44px; border-radius: 50%; }
  .author-left .name { font-weight: 800; font-size: 16px; }
  .author-left .time { font-size: 13px; color: var(--text-gray); margin-top: 2px; }
  
  .btn-follow { padding: 8px 18px; border-radius: 20px; background: var(--bg-page); color: var(--sky-blue); font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: 0.3s; }
  .btn-follow:hover { background: var(--sky-blue); color: white; }

  .feed-img { width: 100%; aspect-ratio: 16/9; max-height: 550px; background: #ddd; position: relative; }
  .feed-img img { width: 100%; height: 100%; object-fit: cover; }
  
  .feed-content { padding: 24px 28px 28px; }
  .feed-text { font-size: 16px; line-height: 1.7; color: var(--text-dark); margin-bottom: 20px; word-break: break-word;overflow-wrap: break-word; }
  .feed-tags { color: var(--sky-blue); font-weight: 700; font-size: 15px; margin-bottom: 24px; }

  .itinerary-snippet { background: rgba(240, 248, 255, 0.5); border: 1px solid rgba(137, 207, 240, 0.3); border-radius: 16px; padding: 20px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
  .iti-info h5 { margin: 0 0 6px 0; font-size: 16px; font-weight: 800; }
  .iti-info p { margin: 0; font-size: 14px; color: var(--text-gray); font-weight: 600; }
  .btn-scrap { background: var(--grad-main); color: white; border: none; padding: 12px 24px; border-radius: 50px; font-weight: 800; font-size: 15px; cursor: pointer; box-shadow: 0 4px 16px rgba(137, 207, 240, 0.4); transition: transform 0.3s var(--bounce); display: flex; align-items: center; gap: 8px; }
  .btn-scrap:hover { transform: translateY(-3px) scale(1.05); }

  .feed-actions { 
    display: flex; gap: 20px; 
    padding-top: 20px; 
    border-top: 1px solid var(--border-color);
    margin-top: 20px; 
  }
  .action-btn { display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700; color: var(--text-gray); cursor: pointer; transition: 0.3s; }
  .action-btn:hover { color: var(--light-pink); }

  .like-btn-area {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    cursor: pointer;
    color: #E8849A; 
    font-size: 15px;
    font-weight: 700;
    user-select: none;
    transition: opacity 0.2s;
  }
  .like-btn-area:hover {
    opacity: 0.7;
  }
  .heart-icon {
    font-size: 16px; 
    line-height: 1;
  }

  .infinite-scroll-trigger {
    padding: 30px; text-align: center; color: var(--sky-blue);
    font-size: 15px; font-weight: 800; margin-bottom: 20px;
    opacity: 0.8; transition: opacity 0.3s;
  }
  
  .author-right { display: flex; align-items: center; gap: 10px; position: relative; }
  
  .kebab-menu { cursor: pointer; padding: 8px; border-radius: 50%; transition: 0.3s; color: var(--text-gray); }
  .kebab-menu:hover { background: rgba(0,0,0,0.05); }
  
  .dropdown-content {
    display: none; position: absolute; right: 0; top: 45px;
    background: white; min-width: 140px; border-radius: 12px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1); z-index: 10; overflow: hidden;
    border: 1px solid rgba(0,0,0,0.05);
  }
  .dropdown-content a {
    display: block; padding: 12px 16px; font-size: 14px; font-weight: 600;
    color: var(--text-dark); transition: 0.2s;
  }
  .dropdown-content a:hover { background: var(--bg-page); color: var(--sky-blue); }
  .dropdown-content a.delete { color: #ff4d4d; }
  
  .show { display: block !important; }

  .btn-follow.following { background: #eee; color: #666; }
  .btn-follow.following::after { content: "중"; } 
  
  .feed-tag-container {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-top: 16px;
    padding: 14px 18px;
    background: #F8FAFC; 
    border-radius: 12px;
    border: 1px dashed rgba(137, 207, 240, 0.6);
  }

  .feed-tag-icon {
    font-size: 18px;
    line-height: 1.2;
    opacity: 0.9;
    padding-top: 8.5px;
  }

  .feed-tag-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .feed-tag-badge {
    color: var(--sky-blue);
    background: white;
    font-size: 14px;
    font-weight: 800;
    padding: 6px 14px;
    border-radius: 20px;
    box-shadow: 0 2px 6px rgba(137, 207, 240, 0.15);
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .feed-tag-badge:hover {
    background: var(--sky-blue);
    color: white;
    transform: translateY(-2px);
  }
  
  .feed-comment-area {
    display: none;
    margin-top: 20px; 
    padding-top: 20px; 
    border-top: 1px solid var(--border-color); 
  }
  .feed-comment-list {
    display: flex; flex-direction: column; gap: 12px; 
    margin-bottom: 16px; max-height: 250px; overflow-y: auto;
  }
  .feed-comment-item {
    display: flex; gap: 10px; align-items: flex-start;
  }
  .feed-comment-item img {
    width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);
  }
  .feed-comment-body {
    background: #F8FAFC; padding: 10px 14px; border-radius: 0 16px 16px 16px; flex: 1;
  }
  .fc-name { font-size: 13px; font-weight: 800; color: var(--text-dark); margin-bottom: 4px; }
  .fc-text { font-size: 13px; color: var(--text-black); line-height: 1.4; word-break: break-all; }
  .fc-time { font-size: 11px; color: var(--text-gray); margin-top: 4px; }
  .comment-input-wrap { display: flex; gap: 8px; }
  .comment-input-wrap input {
    flex: 1; border: 1px solid var(--border-color); border-radius: 20px; padding: 10px 16px; font-family: 'Pretendard', sans-serif; font-size: 13px; outline: none; transition: 0.3s;
  }
  .comment-input-wrap input:focus { border-color: var(--sky-blue); }
  .custom-feed-slider {
    position: relative;
    width: 100%;
    overflow: hidden;
    background-color: #F8FAFC; 
  }

  .slider-track {
    display: flex;
    align-items: center; 
    transition: transform 0.4s ease-in-out;
  }

  .slider-item {
    flex: 0 0 100%; 
    min-width: 0; 
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .slider-item img {
    width: 100%; 
    height: auto; 
    max-height: 600px; 
    object-fit: contain; 
    display: block;
  }

  .s-btn {
    position: absolute;
    top: 50%; transform: translateY(-50%);
    background: rgba(255, 255, 255, 0.6);
    border: none; width: 30px; height: 30px; border-radius: 50%;
    cursor: pointer; z-index: 10; font-size: 14px; transition: 0.3s;
  }
  .s-btn:hover { background: #fff; }
  .s-btn.prev { left: 10px; }
  .s-btn.next { right: 10px; }
  .slider-pagination {
    position: absolute; bottom: 12px; left: 50%; transform: translateX(-50%);
    display: flex; gap: 6px; z-index: 10;
  }
  .s-dot {
    width: 6px; height: 6px; background: rgba(0,0,0,0.3);
    border-radius: 50%; cursor: pointer;
  }
  .s-dot.active { background: #89CFF0; width: 12px; border-radius: 4px; }
  
</style>

<c:if test="${empty targetUser or isMyProfile}">
	<article class="glass-card composer-card" style="padding: 24px; margin-bottom: 24px;">
	  <div style="display: flex; flex-direction: column; width: 100%;">
	    <textarea id="inlineTextarea" placeholder="${not empty sessionScope.loginUser ? sessionScope.loginUser.nickname : '여행자'}님, 어떤 여행을 다녀오셨나요?" 
	          style="width: 100%; min-height: 120px; border: 1px solid var(--border-color); border-radius: 16px; background: rgba(255, 255, 255, 0.8); padding: 18px; box-sizing: border-box; font-family: 'Pretendard', sans-serif; font-size: 16px; resize: none; outline: none; line-height: 1.6; transition: all 0.2s; box-shadow: inset 0 2px 6px rgba(0,0,0,0.02);"
	          onfocus="this.style.borderColor='var(--sky-blue)'; this.style.background='#ffffff';"
	          onblur="this.style.borderColor='var(--border-color)'; this.style.background='rgba(255, 255, 255, 0.8)';"></textarea>
	    
	    <input type="text" id="inlineTags" placeholder="#제주도 #해안도로 (스페이스바로 구분)" 
	           style="width: 100%; border: none; background: transparent; color: var(--sky-blue); font-weight: 700; font-size: 15px; outline: none; margin-top: 12px; padding: 0 4px;">
	
	    <div id="inlinePhotoPreview" style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px;"></div>
	    
	    <div id="inlineSchedulePreview" style="display: none; flex-direction: column; gap: 8px; margin-top: 12px; padding: 16px 20px; background: #F0F8FF; border-radius: 12px; border: 1px dashed var(--sky-blue);">
	      <div style="display: flex; justify-content: space-between; align-items: center;">
	        <span style="font-size: 15px; font-weight: 800; color: var(--text-dark);">
	          📍 <span id="displayScheduleName">선택된 일정 없음</span>
	        </span>
	        <button onclick="removeInlineSchedule()" style="background: none; border: none; color: #FF6B6B; cursor: pointer; font-weight: bold; font-size: 18px; padding: 0 8px;">✕</button>
	      </div>
	      <div style="font-size: 13px; color: var(--text-gray); font-weight: 600; background: rgba(255,255,255,0.7); padding: 8px 12px; border-radius: 8px;">
	        <span id="displayScheduleMeta">일정 정보를 불러오는 중...</span>
	      </div>
	    </div>
	  </div>
	  
	  <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-color); padding-top: 16px; margin-top: 16px;">
	    <div style="display: flex; gap: 12px;">
	      <button type="button" onclick="document.getElementById('inlineFileInput').click()" style="background: #f1f5f9; border: none; padding: 10px 18px; border-radius: 20px; font-weight: 700; color: var(--text-dark); cursor: pointer; display: flex; align-items: center; gap: 6px; transition: 0.2s;">
	        📷 사진 추가
	      </button>
	      <input type="file" id="inlineFileInput" accept="image/*" multiple style="display: none;" onchange="handleInlineFiles(this.files)">
	      
	      <button type="button" onclick="openScheduleModal()" style="background: #f1f5f9; border: none; padding: 10px 18px; border-radius: 20px; font-weight: 700; color: var(--text-dark); cursor: pointer; display: flex; align-items: center; gap: 6px; transition: 0.2s;">
	        📅 일정 추가
	      </button>
	    </div>
	    <button onclick="submitInlinePost()" style="background: var(--sky-blue); color: white; border: none; padding: 10px 28px; border-radius: 20px; font-weight: 800; font-size: 15px; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.3);">
	      게시
	    </button>
	  </div>
	</article>
</c:if>	
<div id="feedListContainer" style="display: flex; flex-direction: column; gap: 24px;">
 <c:forEach var="feed" items="${feedList}" varStatus="status">
  <article class="glass-card feed-card" data-post-id="${feed.postId}" style="${status.index >= 5 ? 'display: none;' : ''}">
 
    <div class="feed-author">
      <div class="author-left" onclick="loadUserProfile('${feed.memberId}')">
        <c:choose>
          <c:when test="${not empty feed.profileImage}">
            <img src="${pageContext.request.contextPath}/uploads/profile/${feed.profileImage}" alt="User">
          </c:when>
          <c:otherwise>
            <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="User">
          </c:otherwise>
        </c:choose>
        <div>
          <div class="name">@${feed.nickname}</div>
          <div class="time" onclick="event.stopPropagation();" style="cursor: default">${feed.createdAt}</div>
        </div>
      </div>

      <div class="author-right">
        <c:if test="${sessionScope.loginUser.memberId != feed.memberId}">
          <button class="btn-follow ${feed.isFollowing == 1 ? 'following' : ''}" 
                  onclick="toggleFollow(this, ${feed.memberId})">
            ${feed.isFollowing == 1 ? '팔로잉' : '팔로우'}
          </button>
        </c:if>

        <div class="kebab-wrapper">
          <div class="kebab-menu" onclick="toggleKebab(this, event)">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
          </div>
          <div class="dropdown-content">
            <c:choose>
              <c:when test="${sessionScope.loginUser.memberId == feed.memberId}">
                <a href="javascript:void(0)" onclick="editPost(${feed.postId})">📝 수정하기</a>
                <a href="javascript:void(0)" class="delete" onclick="deletePost(${feed.postId})">🗑️ 삭제하기</a>
              </c:when>
              <c:otherwise>
                <a href="${pageContext.request.contextPath}/community/myfeed?memberId=${feed.memberId}">👤 프로필 보기</a>
                <a href="javascript:void(0)" onclick="openReportModal('FEED', ${feed.postId}, ${feed.memberId})">🚨 게시글 신고</a>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
    
	<c:if test="${not empty feed.imageUrl}">
	  <c:set var="imgArray" value="${feed.imageUrl.split(',')}" />
	  
	  <div class="custom-feed-slider" id="slider-${feed.postId}">
	    <div class="slider-track">
	      <c:forEach var="imgName" items="${imgArray}">
	        <div class="slider-item">
	          <img src="${pageContext.request.contextPath}/uploads/feed/${imgName.trim()}" alt="Feed Image">
	        </div>
	      </c:forEach>
	    </div>
	
		<c:if test="${fn:length(imgArray) > 1}">
	      <button class="s-btn prev" onclick="moveSlide(${feed.postId}, -1)">❮</button>
	      <button class="s-btn next" onclick="moveSlide(${feed.postId}, 1)">❯</button>
	      
	      <div class="slider-pagination">
	        <c:forEach var="dot" items="${imgArray}" varStatus="vs">
	          <span class="s-dot ${vs.first ? 'active' : ''}" onclick="goSlide(${feed.postId}, ${vs.index})"></span>
	        </c:forEach>
	      </div>
	    </c:if>
	  </div>
	</c:if> 
    
    <div class="feed-content">
      <p class="feed-text" style="white-space: pre-wrap;">${feed.content}</p>
      <br>
      <c:if test="${not empty feed.tripId}">
        <div class="itinerary-snippet">
          <div class="iti-info">
            <h5>📍 ${feed.tripName}</h5>
            <p>예상 경비 ${feed.totalBudget}원</p>
          </div>
          <button class="btn-scrap" onclick="scrapTrip(${feed.tripId})">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 4H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2v-2M16 4h2a2 2 0 012 2v4M21 14H11"></path><path d="M15 10l-4 4-4-4"></path></svg>
            일정 담아오기
          </button>
        </div>
      </c:if>
      
      <div class="feed-actions">
        <div class="like-btn-area" onclick="toggleFeedLike(this, ${feed.postId})">
          <span class="heart-icon">♡</span> 좋아요 <span class="like-cnt">${feed.likeCount}</span>
        </div>
        <div class="action-btn" onclick="openComment(${feed.postId})">💬 댓글</div>
      </div>

      <div class="feed-comment-area" id="feed-comment-area-${feed.postId}">
        <div class="feed-comment-list" id="comment-list-${feed.postId}">
           </div>
        <div class="comment-input-wrap">
           <input type="text" id="comment-input-${feed.postId}" placeholder="따뜻한 댓글을 남겨주세요...">
           <button class="btn-submit-lounge" style="padding: 8px 20px; border-radius: 20px; font-size: 13px;" onclick="submitFeedComment(${feed.postId})">등록</button>
        </div>
      </div>
      
    </div>
    
  </article>
 </c:forEach>
</div>

<div id="infiniteScrollTarget" class="infinite-scroll-trigger">
  아래로 스크롤하여 더 보기...
</div>