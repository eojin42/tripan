<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<style>
  .btn-status-toggle { background: #FF6B6B; color: white; border: none; padding: 6px 14px; border-radius: 8px; font-size: 13px; font-weight: 800; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 10px rgba(255, 107, 107, 0.2); }
  .btn-status-toggle:hover { background: #fa5252; transform: translateY(-2px); box-shadow: 0 6px 12px rgba(255, 107, 107, 0.3); }
  .btn-status-toggle.closed { background: var(--text-dark); box-shadow: 0 4px 10px rgba(74, 85, 104, 0.2); }
  .btn-status-toggle.closed:hover { background: var(--sky-blue); box-shadow: 0 6px 12px rgba(137, 207, 240, 0.3); }

  .pm-status { background: #E6FFFA; color: #00A88F; padding: 6px 12px; border-radius: 8px; font-size: 13px; font-weight: 800; display: inline-block; box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
  .pm-status.closed { background: #EDF2F7; color: #A0AEC0; }
</style>

<div class="glass-card" style="padding: 30px; animation: fadeIn 0.3s ease;">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--border-color); padding-bottom: 16px; margin-bottom: 20px;">
        <button onclick="restorePreviousState()" style="background:none; border:none; color:var(--text-gray); font-size:15px; font-weight:800; cursor:pointer; display: flex; align-items: center; gap: 6px; transition: 0.2s;" onmouseover="this.style.color='var(--sky-blue)'" onmouseout="this.style.color='var(--text-gray)'">
            ❮ 돌아가기
        </button>
        
        <c:choose>
            <c:when test="${loginUserId == mate.memberId}">
                <button class="btn-status-toggle ${mate.status == 'CLOSED' ? 'closed' : ''}" 
                        onclick="toggleMateStatus(${mate.mateId}, '${mate.status == 'OPEN' ? 'CLOSED' : 'OPEN'}')">
                    ${mate.status == 'OPEN' ? '마감하기' : '모집재개'}
                </button>
            </c:when>
            <c:otherwise>
                <span class="pm-status ${mate.status == 'CLOSED' ? 'closed' : ''}">
                    ${mate.status == 'CLOSED' ? '⚪ 모집마감' : '🟢 모집중'}
                </span>
            </c:otherwise>
        </c:choose>
    </div>

    <h2 style="margin: 0 0 16px; font-size: 24px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px;">
        ${mate.title}
    </h2>
    
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <img src="${not empty mate.profilePhoto ? pageContext.request.contextPath += '/uploads/profile/' += mate.profilePhoto : pageContext.request.contextPath += '/dist/images/default.png'}" 
                 style="width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color); cursor: pointer;"
                 onclick="loadUserProfile('${mate.memberId}')">
            <div>
                <div style="font-weight: 800; color: var(--text-dark); font-size: 15px;">${mate.nickname}</div>
                <div style="font-size: 12px; color: var(--text-gray); margin-top: 2px;">
                    ${mate.createdAt} · 👀 조회수 ${mate.viewCount}
                </div>
            </div>
        </div>
        
		<c:choose>
            <c:when test="${loginUserId == mate.memberId}">
                <button onclick="deleteMatePost(${mate.mateId})" style="padding: 6px 12px; border-radius: 8px; border: 1px solid #FF6B6B; background: white; color: #FF6B6B; font-weight: 700; cursor: pointer; transition: 0.2s;" onmouseover="this.style.background='#FFF5F5'" onmouseout="this.style.background='white'">🗑️ 글 삭제</button>
            </c:when>
            <c:otherwise>
                <button onclick="openReportModal('MATE', ${mate.mateId}, ${mate.memberId})" style="padding: 6px 12px; border-radius: 8px; border: 1px solid #cbd5e1; background: white; color: var(--text-gray); font-weight: 700; cursor: pointer; transition: 0.2s;" onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='white'">🚨 글 신고</button>
            </c:otherwise>
        </c:choose>
    </div>

    <div style="background: linear-gradient(145deg, #F8FAFC, #F0F8FF); border: 1px solid rgba(137,207,240,0.3); border-radius: 16px; padding: 20px; margin-bottom: 28px; display: flex; gap: 32px; flex-wrap: wrap; box-shadow: inset 0 2px 4px rgba(255,255,255,0.8);">
        <div>
            <span style="font-size: 12px; color: var(--sky-blue); font-weight: 800; display: block; margin-bottom: 6px;">📍 여행 지역</span>
            <span style="font-size: 16px; font-weight: 900; color: var(--text-black);">${mate.sidoName}</span>
        </div>
        <div>
            <span style="font-size: 12px; color: var(--sky-blue); font-weight: 800; display: block; margin-bottom: 6px;">📅 여행 일정</span>
            <span style="font-size: 16px; font-weight: 900; color: var(--text-black);">${mate.startDate} ~ ${mate.endDate}</span>
        </div>
        <div>
            <span style="font-size: 12px; color: var(--sky-blue); font-weight: 800; display: block; margin-bottom: 6px;">👥 모집 인원</span>
            <span style="font-size: 16px; font-weight: 900; color: var(--text-black);">${mate.targetCount}명</span>
        </div>
    </div>

    <div style="font-size: 16px; line-height: 1.8; color: var(--text-dark); white-space: pre-wrap; margin-bottom: 30px; min-height: 120px;">${mate.content}</div>

    <c:if test="${not empty mate.tags}">
        <div style="margin-bottom: 32px; display: flex; gap: 8px; flex-wrap: wrap;">
            <c:set var="tagArray" value="${mate.tags.split(' ')}" />
            <c:forEach var="t" items="${tagArray}">
                <c:if test="${not empty t}">
                    <span style="background: rgba(137, 207, 240, 0.1); color: var(--sky-blue); font-weight: 800; font-size: 13px; padding: 6px 12px; border-radius: 20px;">${t}</span>
                </c:if>
            </c:forEach>
        </div>
    </c:if>

	<div style="border-top: 1px dashed rgba(137, 207, 240, 0.5); padding-top: 24px;">
	        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 16px;">
	            <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: var(--text-dark);">
	                💬 댓글 <span id="comment-count-${mate.mateId}" style="color:var(--sky-blue);">0</span>
	            </h3>
	            <button class="btn-apply" onclick="window.startPrivateChat(${mate.memberId}, '${mate.nickname}')">✉️ 작성자에게 톡 보내기</button>
	        </div>
	        
	        <div class="comment-list" id="comment-list-${mate.mateId}" style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 16px;">
	            <div style="text-align: center; color: var(--text-gray); font-size: 13px; padding: 20px 0;">댓글을 불러오는 중입니다... ⏳</div>
	        </div>

	        <div style="display: flex; gap: 8px;">
	            <input type="text" id="comment-input-${mate.mateId}" class="lounge-input-style" placeholder="동행에 대해 궁금한 점을 남겨보세요!" style="flex: 1; padding: 10px 14px; border-radius: 20px;">
	            <button class="btn-submit-lounge" style="padding: 10px 24px; border-radius: 20px;" onclick="window.submitMateComment(${mate.mateId})">등록</button>
	        </div>
	    </div>
	</div> 
	
	<script>
	    if(typeof window.loadMateComments === 'function') {
	        window.loadMateComments(${mate.mateId}, false); 
	    }
	</script>