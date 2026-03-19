<%@ page contentType="text/html; charset=UTF-8" %>
<div id="tab-dashboard" class="page-section active">
  <div class="page-header">
    <h1>Dashboard</h1>
    <p>오늘의 숙소 현황과 주요 지표를 확인하세요.</p>
  </div>
  <div class="kpi-grid">
    <div class="card"><div style="display:flex; justify-content:space-between;"><div><div class="kpi-label">오늘 체크인</div><div class="kpi-value">3건</div></div><div class="kpi-icon-wrap">🔑</div></div></div>
    <div class="card"><div style="display:flex; justify-content:space-between;"><div><div class="kpi-label">오늘 체크아웃</div><div class="kpi-value">2건</div></div><div class="kpi-icon-wrap" style="background:rgba(139,92,246,0.1)">👋</div></div></div>
    <div class="card"><div style="display:flex; justify-content:space-between;"><div><div class="kpi-label">신규 예약 대기</div><div class="kpi-value" style="color:#EF4444">5건</div></div><div class="kpi-icon-wrap" style="background:#FFE4E6">🚨</div></div></div>
    <div class="card"><div style="display:flex; justify-content:space-between;"><div><div class="kpi-label">이번 달 매출</div><div class="kpi-value" style="color:#3B6EF8">₩4.2M</div></div><div class="kpi-icon-wrap" style="background:rgba(16,185,129,0.1)">💰</div></div></div>
  </div>
  <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
    <div class="card">
      <h2 style="font-size:15px; font-weight:800; margin-bottom:16px;">📈 주간 예약 추이</h2>
      <div style="height: 250px;"><canvas id="mainDashboardChart"></canvas></div>
    </div>
    <div class="card">
      <h2 style="font-size:15px; font-weight:800; margin-bottom:16px;">🔔 최근 알림</h2>
      <ul style="list-style:none; padding:0; margin:0;">
        <li style="padding:12px 0; border-bottom:1px dashed #eee;"><span class="badge badge-wait">리뷰</span> 미답변 리뷰가 있습니다.</li>
        <li style="padding:12px 0;"><span class="badge badge-done">정산</span> 9월 정산이 완료되었습니다.</li>
      </ul>
    </div>
  </div>
</div>