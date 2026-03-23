<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div id="tab-room" class="page-section ${activeTab == 'room' ? 'active' : ''}">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
        <div>
            <h1>숙소 및 객실 관리</h1>
            <p>내 숙소의 기본 정보와 판매할 객실(Room)을 등록하고 관리합니다.</p>
        </div>
        <button class="btn btn-primary" onclick="openRoomModal()">+ 새 객실 등록</button>
    </div>

    <div class="card" style="border-left: 4px solid var(--primary); background: #F8FAFC;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 12px;">
            <h2 style="font-size: 16px; font-weight: 800;">🏢 내 숙소 기본 정보</h2>
            <button class="btn btn-ghost" style="padding: 4px 12px; font-size: 12px;" onclick="location.href='?tab=info';">숙소 정보 관리</button>
        </div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 13px;">
            <div><span style="color:#8B92A5; display:inline-block; width:80px;">숙소명</span> <strong>${partnerInfo.partnerName}</strong></div>
            <div><span style="color:#8B92A5; display:inline-block; width:80px;">카테고리</span> <strong>${not empty accommodation.accommodationType ? accommodation.accommodationType : '숙박'}</strong></div>
        </div>
    </div>

    <h3 style="font-size: 15px; font-weight: 800; margin: 24px 0 16px 0;">🛏️ 등록된 객실 목록</h3>

    <div style="display: flex; flex-direction: column; gap: 16px;">
        <c:choose>
            <c:when test="${not empty roomList}">
                <c:forEach var="room" items="${roomList}">
                    <div class="card" style="display: grid; grid-template-columns: 200px 1fr auto; gap: 24px; align-items: center;">
                        
                        <div style="width: 100%; height: 140px; border-radius: 8px; overflow: hidden; background: #eee;">
                            <c:choose>
                                <c:when test="${not empty room.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${room.imageUrl}" alt="객실 이미지" style="width: 100%; height: 100%; object-fit: cover;">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="이미지 없음" style="width: 100%; height: 100%; object-fit: cover;">
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div>
                            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                <h3 style="font-size:18px; font-weight:700; margin:0;">${room.roomName}</h3>
                                
                                <c:choose>
                                    <c:when test="${room.isActive == 1}">
                                        <span class="badge" style="background-color: #E8F5E9; color: #16A34A; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold;">판매중</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge" style="background-color: #F1F5F9; color: #64748B; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold;">판매중지</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <p style="color:#64748B; font-size:14px; margin:0 0 4px 0;">기준 ${room.roombasecount}인 / 최대 ${room.maxCapacity}인</p>
                            <p style="color:#8B92A5; font-size:13px; margin:0; line-height: 1.4;">${room.roomintro}</p>
                        </div>
                        <div style="text-align: right;">
                            <p style="font-family:'Sora', sans-serif; font-size:20px; font-weight:900; color:var(--text); margin-bottom: 12px;">
                                <fmt:formatNumber value="${room.amount}" pattern="#,###"/> 원
                            </p>
                            <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                <%-- 🌟 수정: data-* 속성으로 데이터 은닉 (따옴표/줄바꿈 에러 방지) --%>
                                <button type="button" class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px;"
                                    data-id="${room.roomId}"
                                    data-name="${room.roomName}"
                                    data-base="${room.roombasecount}"
                                    data-max="${room.maxCapacity}"
                                    data-cnt="${room.roomCount}"
                                    data-amt="${room.amount}"
                                    data-intro="${room.roomintro}"
                                    data-active="${room.isActive}"
                                    onclick="openRoomModalForUpdate(this)">
                                    수정
                                </button>
                                <button type="button" class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px; color: var(--danger);" onclick="deleteRoom('${room.roomId}')">삭제</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>

            <c:otherwise>
                <div class="card" style="text-align: center; padding: 40px;">
                    <div style="font-size: 40px; margin-bottom: 16px;">🛏️</div>
                    <p style="color: var(--muted); font-size: 14px; margin-bottom: 16px;">아직 등록된 객실이 없습니다.</p>
                    <button class="btn btn-primary" onclick="openRoomModal()">첫 번째 객실 등록하기</button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>