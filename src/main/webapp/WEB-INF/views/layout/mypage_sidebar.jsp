<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
  <div class="glass-card profile-widget">
    <div class="profile-avatar">
      <c:choose>
        <c:when test="${not empty sessionScope.loginUser.profilePhoto}">
          <img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.loginUser.profilePhoto}" alt="프로필">
        </c:when>
        <c:otherwise>
          <div class="profile-avatar-default" id="avatar-initial">T</div>
        </c:otherwise>
      </c:choose>
    </div>
    <div class="profile-name">${sessionScope.loginUser.nickname} 님</div>
    <div class="profile-bio">${not empty sessionScope.loginUser.bio ? sessionScope.loginUser.bio : '등록된 소개글이 없습니다.'}</div>
    
    <button class="btn-edit-profile" onclick="location.href='${pageContext.request.contextPath}/member/pwd'">프로필 수정</button>
    
    <div class="profile-stats">
      <div class="stat-box" onclick="openFollowModal('follower')">
        <strong id="stat-follower">-</strong>팔로워
      </div>
      <div class="stat-box" onclick="openFollowModal('following')">
        <strong id="stat-following">-</strong>팔로잉
      </div>
      <div class="stat-box" onclick="openBadgeModal()">
        <strong id="stat-badge">-</strong>배지
      </div>
    </div>
  </div>

  <div class="glass-card">
    <ul class="side-nav">
      <li class="${activeMenu == 'main' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/main">
          <i class="bi bi-bar-chart-line"></i> 여행 대시보드
        </a>
      </li>
      <li class="${activeMenu == 'schedule' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/schedule">
          <i class="bi bi-suitcase-lg"></i> 내 일정 / 예약
        </a>
      </li>
      <li class="${activeMenu == 'bookmark' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/bookmark">
          <i class="bi bi-bookmark-heart"></i> 관심 및 저장(찜)
        </a>
      </li>
      <li class="${activeMenu == 'review' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/review">
          <i class="bi bi-chat-square-text"></i> 나의 리뷰 기록
        </a>
      </li>
      <li class="${activeMenu == 'coupon' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/coupon">
          <i class="bi bi-ticket-perforated"></i> 보유 쿠폰함
        </a>
      </li>
    </ul>
  </div>
</aside>