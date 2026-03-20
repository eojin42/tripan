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
            <button class="btn btn-ghost" style="padding: 4px 12px; font-size: 12px;" onclick="alert('정보 탭으로 이동합니다.'); location.href='?tab=info';">숙소 정보 관리</button>
        </div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 13px;">
            <div><span style="color:#8B92A5; display:inline-block; width:80px;">숙소명</span> <strong>트리팬 오션 리조트</strong></div>
            <div><span style="color:#8B92A5; display:inline-block; width:80px;">카테고리</span> 호텔/리조트</div>
        </div>
    </div>

    <h3 style="font-size: 15px; font-weight: 800; margin: 24px 0 16px 0;">🛏️ 등록된 객실 목록</h3>

    <div style="display: flex; flex-direction: column; gap: 16px;">
        <c:choose>
            <c:when test="${not empty roomList}">
                <%-- 🌟 컨트롤러에서 넘겨준 roomList를 빙글빙글 돌립니다! --%>
                <c:forEach var="room" items="${roomList}">
                    <div class="card" style="display:flex; gap:20px; align-items:center; margin-bottom: 0; padding: 20px;">
                        <%-- 임시 썸네일 --%>
                        <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=300&q=80" style="width:180px; height:120px; border-radius:12px; object-fit:cover;">

                        <div style="flex:1;">
                            <div style="display:flex; gap:8px; margin-bottom:6px;">
                                <span class="badge badge-done">판매중</span>
                                <span class="badge" style="background:#F1F5F9; color:#475569;">보유 ${room.roomCount}객실</span>
                            </div>
                            <h3 style="font-size:18px; font-weight:800; margin-bottom:8px;">${room.roomName}</h3>
                            <p style="color:#8B92A5; font-size:13px; margin:0 0 4px 0;">👥 기준 ${room.roombasecount}인 / 최대 ${room.maxCapacity}인</p>
                            <p style="color:#8B92A5; font-size:13px; margin:0; line-height: 1.4;">${room.roomintro}</p>
                        </div>

                        <div style="text-align: right;">
                            <%-- 금액에 콤마(,) 찍어주기 --%>
                            <p style="font-family:'Sora', sans-serif; font-size:20px; font-weight:900; color:var(--text); margin-bottom: 12px;">
                                <fmt:formatNumber value="${room.amount}" pattern="#,###"/> 원
                            </p>
                            <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                <button class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px;">수정</button>
                                <button class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px; color: var(--danger);">삭제</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>

            <c:otherwise>
                <%-- 등록된 객실이 없을 때 보여줄 빈 화면 --%>
                <div class="card" style="text-align: center; padding: 40px;">
                    <p style="color: var(--muted); font-size: 14px; margin-bottom: 16px;">아직 등록된 객실이 없습니다.</p>
                    <button class="btn btn-primary" onclick="openRoomModal()">첫 객실 등록하기</button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>