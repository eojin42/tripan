<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- ── 채팅 FAB 버튼 ── --%>
<button class="chat-fab" id="chatFab" onclick="toggleChat()" title="동행자 채팅">
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
  </svg>
  <span class="chat-fab__badge" id="chatUnreadBadge" style="display:none"></span>
</button>

<%-- ── 채팅 모달 ── --%>
<div class="chat-modal" id="chatModal">

  <div class="chat-modal__header">
    <div class="chat-modal__header-left">
      <%-- 말풍선 + 스파클 조합 아이콘 --%>
      <div class="chat-modal__icon-wrap">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M20 2H4C2.9 2 2 2.9 2 4V22L6 18H20C21.1 18 22 17.1 22 16V4C22 2.9 21.1 2 20 2Z" fill="url(#chatIconGrad)" stroke="none"/>
          <circle cx="8" cy="10" r="1.2" fill="#fff" fill-opacity="0.9"/>
          <circle cx="12" cy="10" r="1.2" fill="#fff" fill-opacity="0.9"/>
          <circle cx="16" cy="10" r="1.2" fill="#fff" fill-opacity="0.9"/>
          <defs>
            <linearGradient id="chatIconGrad" x1="2" y1="2" x2="22" y2="22" gradientUnits="userSpaceOnUse">
              <stop stop-color="#89CFF0"/>
              <stop offset="1" stop-color="#C2B8D9"/>
            </linearGradient>
          </defs>
        </svg>
      </div>
      <div class="chat-modal__title-wrap">
        <span class="chat-modal__title">${fn:escapeXml(tripDto.tripName)}</span>
        <span class="chat-modal__subtitle">동행자 채팅</span>
      </div>
    </div>
    <button class="chat-modal__close" onclick="toggleChat()" title="닫기">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </button>
  </div>

  <div class="chat-modal__members">
    <c:set var="acceptedCount" value="0"/>
    <c:forEach var="m" items="${tripDto.members}" varStatus="st">
      <c:if test="${m.invitationStatus == 'ACCEPTED'}">
        <c:set var="acceptedCount" value="${acceptedCount + 1}"/>
        <div class="chat-mem-avatar<c:if test='${m.memberId == myMemberId}'> chat-mem-avatar--me</c:if>"
             data-member-id="${m.memberId}"
             title="${fn:escapeXml(m.nickname)}">
          <c:choose>
            <c:when test="${not empty m.profileImage}">
              <img src="${pageContext.request.contextPath}${m.profileImage}"
                   alt="${fn:escapeXml(m.nickname)}"
                   style="width:100%;height:100%;object-fit:cover;border-radius:50%;display:block"
                   onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
              <span style="display:none;width:100%;height:100%;align-items:center;justify-content:center">${fn:substring(m.nickname,0,2)}</span>
            </c:when>
            <c:otherwise>
              <span style="display:flex;width:100%;height:100%;align-items:center;justify-content:center">${fn:substring(m.nickname,0,2)}</span>
            </c:otherwise>
          </c:choose>
        </div>
      </c:if>
    </c:forEach>
    <span class="chat-modal__member-count">${acceptedCount}명</span>
  </div>

  <div class="chat-modal__messages" id="chatMessageList" onscroll="_onChatScroll(this)">
  </div>

  <div class="chat-modal__input-area">
    <textarea
      class="chat-input" id="chatInput"
      placeholder="메시지 입력... (Enter 전송, Shift+Enter 줄바꿈)"
      rows="1"
      oninput="onChatInputChange(this)"
      onkeydown="onChatInputKeydown(event)"
    ></textarea>
    <button class="chat-send-btn" id="chatSendBtn" onclick="sendChatMessage()" title="전송">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="22" y1="2" x2="11" y2="13"/>
        <polygon points="22 2 15 22 11 13 2 9 22 2"/>
      </svg>
    </button>
  </div>

</div>

<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.chat.js?v=20260322"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // 아바타 색상은 WS 연결과 무관하게 즉시 주입
    _initAvatarColors();

    // initChat은 WS 연결 완료 후 실행
    var _chatInitTimer = setInterval(function() {
      if (window._wsConnected) {
        clearInterval(_chatInitTimer);
        initChat();
      }
    }, 300);
    setTimeout(function() {
      clearInterval(_chatInitTimer);
      initChat();
    }, 5000);
  });
</script>
