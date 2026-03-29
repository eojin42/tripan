<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
    /* 🌟 대시보드 전용 스타일 */
    .dash-header-container { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    .dash-title { font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; margin: 0; }
    .dash-subtitle { color: var(--text-gray); margin-top: 8px; font-weight: 500; margin-bottom: 0; }
    
    /* KPI 카드 4개 */
    .dash-kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
    .dash-kpi-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); position: relative; overflow: hidden; }
    .dash-kpi-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
    .dash-kpi-title { font-size: 14px; font-weight: 800; color: #64748B; }
    .dash-kpi-icon { font-size: 24px; width: 48px; height: 48px; display: flex; align-items: center; justify-content: center; border-radius: 12px; }
    .icon-blue { background: #DBEAFE; color: #2563EB; }
    .icon-green { background: #D1FAE5; color: #059669; }
    .icon-red { background: #FEE2E2; color: #DC2626; }
    .icon-purple { background: #EDE9FE; color: #7C3AED; }
    
    .dash-kpi-value { font-size: 28px; font-weight: 900; color: #0F172A; font-family: 'Sora', sans-serif; margin-bottom: 4px; }
    .dash-kpi-desc { font-size: 12px; font-weight: 600; color: #94A3B8; }
    .dash-kpi-desc span { font-weight: 800; }

    /* 프로그레스 바 (가동률용) */
    .progress-bg { width: 100%; height: 6px; background: #E2E8F0; border-radius: 999px; margin-top: 12px; overflow: hidden; }
    .progress-bar { height: 100%; background: #7C3AED; border-radius: 999px; }

    /* 중/하단 그리드 */
    .dash-main-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 24px; }
    .dash-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
    .dash-card-title { font-size: 16px; font-weight: 800; color: #1E293B; margin-top: 0; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
    .dash-card-more { font-size: 12px; color: #6366F1; font-weight: 700; cursor: pointer; text-decoration: none; }
    .dash-card-more:hover { text-decoration: underline; }

    /* To-Do 리스트 */
    .todo-list { list-style: none; padding: 0; margin: 0; }
    .todo-item { display: flex; align-items: center; padding: 16px; border-radius: 12px; border: 1px solid #E2E8F0; margin-bottom: 12px; transition: all 0.2s; cursor: pointer; }
    .todo-item:hover { border-color: #CBD5E1; background: #F8FAFC; transform: translateY(-2px); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
    .todo-item:last-child { margin-bottom: 0; }
    .todo-badge { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; margin-right: 12px; white-space: nowrap; }
    .badge-urgent { background: #FEE2E2; color: #DC2626; }
    .badge-warn { background: #FEF3C7; color: #D97706; }
    .badge-info { background: #E0E7FF; color: #4F46E5; }
    .todo-text { font-size: 14px; font-weight: 700; color: #334155; flex-grow: 1; }
    .todo-arrow { color: #94A3B8; font-weight: 900; }

    /* 미니 차트 컨테이너 */
    .mini-chart-container { position: relative; height: 220px; width: 100%; }

    /* 리뷰 리스트 */
    .review-mini-list { list-style: none; padding: 0; margin: 0; }
    .review-mini-item { padding: 16px 0; border-bottom: 1px dashed #E2E8F0; }
    .review-mini-item:last-child { border-bottom: none; padding-bottom: 0; }
    .review-stars { color: #F59E0B; font-size: 12px; margin-bottom: 4px; letter-spacing: 2px; }
    .review-content { font-size: 13px; color: #475569; font-weight: 600; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
</style>

<div id="tab-dashboard" class="page-section ${activeTab == 'dashboard' ? 'active' : ''}">
    
    <div class="dash-header-container">
        <div>
            <h1 class="dash-title">🏠 대시보드</h1>
            <p class="dash-subtitle">오늘의 숙소 현황과 처리해야 할 업무를 한눈에 확인하세요.</p>
        </div>
        <div style="font-size: 13px; font-weight: 700; color: #64748B; background: white; padding: 8px 16px; border-radius: 999px; border: 1px solid #E2E8F0;">
            기준일시: <span id="currentDashTime" style="color: #0F172A;"></span>
        </div>
    </div>

    <div class="dash-kpi-grid">
        <div class="dash-kpi-card">
            <div class="dash-kpi-header">
                <div class="dash-kpi-title">오늘 체크인 예정</div>
                <div class="dash-kpi-icon icon-blue">📥</div>
            </div>
            <div class="dash-kpi-value">${empty dashData.checkInTotal ? 0 : dashData.checkInTotal} 건</div>
            <div class="dash-kpi-desc">손님 맞을 준비를 해주세요!</div>
        </div>
        
        <div class="dash-kpi-card">
            <div class="dash-kpi-header">
                <div class="dash-kpi-title">오늘 체크아웃 예정</div>
                <div class="dash-kpi-icon icon-red">📤</div>
            </div>
            <div class="dash-kpi-value">${empty dashData.checkOutTotal ? 0 : dashData.checkOutTotal} 건</div>
            <div class="dash-kpi-desc">객실 청소가 필요합니다.</div>
        </div>

        <div class="dash-kpi-card">
            <div class="dash-kpi-header">
                <div class="dash-kpi-title">오늘 들어온 신규 예약</div>
                <div class="dash-kpi-icon icon-green">🎉</div>
            </div>
            <div class="dash-kpi-value">${empty dashData.newReserveTotal ? 0 : dashData.newReserveTotal} 건</div>
            <div class="dash-kpi-desc">오늘도 예약이 들어왔어요!</div>
        </div>

        <div class="dash-kpi-card">
            <div class="dash-kpi-header">
                <div class="dash-kpi-title">오늘 객실 가동률</div>
                <div class="dash-kpi-icon icon-purple">🏨</div>
            </div>
            <div class="dash-kpi-value">100%</div>
            <div class="dash-kpi-desc">만실입니다! 👏</div>
            <div class="progress-bg">
                <div class="progress-bar" style="width: 100%;"></div>
            </div>
        </div>
    </div>

    <div class="dash-main-grid">
        
        <div class="dash-card">
            <div class="dash-card-title">
                🚨 지금 처리해야 할 업무
            </div>
            <ul class="todo-list">
				<li class="todo-item" onclick="location.href='?tab=review'">
                    <span class="todo-badge badge-urgent">리뷰</span>
                    <span class="todo-text">
                        <c:choose>
                            <c:when test="${dashData.unreadReviewCount > 0}">
                                이번 달 새로 등록된 리뷰가 <b style="color:#DC2626;">${dashData.unreadReviewCount}건</b> 있습니다.
                            </c:when>
                            <c:otherwise>
                                이번 달 등록된 신규 리뷰가 없습니다.
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <span class="todo-arrow">❯</span>
                </li>
                
                <li class="todo-item" onclick="location.href='?tab=booking'">
                    <span class="todo-badge badge-warn">예약</span>
                    <span class="todo-text">취소 요청이 접수된 예약이 0건 있습니다.</span>
                    <span class="todo-arrow">❯</span>
                </li>
                <li class="todo-item" onclick="location.href='?tab=coupon'">
                    <span class="todo-badge badge-info">쿠폰</span>
                    <span class="todo-text">진행 중인 할인 쿠폰 내역을 확인하세요.</span>
                    <span class="todo-arrow">❯</span>
                </li>
            </ul>
        </div>

        <div class="dash-card" style="background: #0F172A; border-color: #0F172A;">
            <div class="dash-card-title" style="color: white;">
                💰 이번 달 매출 요약
                <a href="?tab=stats" class="dash-card-more" style="color: #94A3B8;">통계 보기 ❯</a>
            </div>
            
            <div style="margin-bottom: 24px;">
                <div style="font-size: 13px; color: #94A3B8; font-weight: 600; margin-bottom: 4px;">누적 결제 금액</div>
                <div style="font-size: 32px; font-weight: 900; color: white; font-family: 'Sora', sans-serif;">
                    ₩ <fmt:formatNumber value="${empty dashData.thisMonthSales ? 0 : dashData.thisMonthSales}" pattern="#,###"/>
                </div>
                <div style="font-size: 12px; font-weight: 700; color: #10B981; margin-top: 4px;">이번 달도 파이팅입니다! 🔥</div>
            </div>

        </div>

    </div>

    <div class="dash-main-grid">
        
        <div class="dash-card">
            <div class="dash-card-title">
                📈 최근 7일 예약 발생 추이
                <a href="?tab=stats" class="dash-card-more">자세히 보기 ❯</a>
            </div>
            <div class="mini-chart-container">
                <canvas id="dashWeeklyChart"></canvas>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-card-title">
                💬 최근 등록된 리뷰
                <a href="?tab=review" class="dash-card-more">더보기 ❯</a>
            </div>
            <ul class="review-mini-list">
                <li class="review-mini-item">
                    <div style="text-align:center; padding: 20px; color: #94A3B8; font-size: 13px;">
                        가장 최근 리뷰를 불러올 준비 중입니다.
                    </div>
                </li>
            </ul>
        </div>

    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 기준 일시 세팅
        const now = new Date();
        const timeString = now.getFullYear() + '.' + 
                          String(now.getMonth() + 1).padStart(2, '0') + '.' + 
                          String(now.getDate()).padStart(2, '0') + ' ' + 
                          String(now.getHours()).padStart(2, '0') + ':' + 
                          String(now.getMinutes()).padStart(2, '0');
        document.getElementById('currentDashTime').innerText = timeString;

        // 미니 차트 그리기 (가상 데이터)
        renderDashChart();
    });

    function renderDashChart() {
        const ctx = document.getElementById('dashWeeklyChart').getContext('2d');
        
        const labels = ['6일 전', '5일 전', '4일 전', '3일 전', '이틀 전', '어제', '오늘'];
        const data = [3, 5, 2, 8, 12, 15, 8];

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: '예약 건수',
                    data: data,
                    backgroundColor: '#6366F1',
                    borderRadius: 6,
                    barThickness: 24
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 5 } },
                    x: { grid: { display: false } }
                }
            }
        });
    }
</script>