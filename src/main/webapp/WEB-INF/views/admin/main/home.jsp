<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TripanSuper — Dashboard</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    /* ── Grid layouts ── */
    .kpi-grid     { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 22px; }
    .chart-grid   { display: grid; grid-template-columns: 1fr 1fr 1fr;   gap: 18px; margin-bottom: 22px; }
    .bottom-grid  { display: grid; grid-template-columns: 1fr 1fr 1fr;   gap: 18px; }

    /* ── KPI card ── */
    .kpi-card { padding: 24px 22px; }
    .kpi-label { font-size: 11px; font-weight: 700; color: var(--muted); letter-spacing: .4px; text-transform: uppercase; margin-bottom: 10px; }
    .kpi-value { font-family: var(--font-display); font-size: 28px; font-weight: 800; letter-spacing: -.5px; margin-bottom: 8px; }
    .kpi-footer { display: flex; align-items: center; gap: 8px; }
    .kpi-icon {
      width: 40px; height: 40px; border-radius: 12px; display: flex; align-items: center;
      justify-content: center; font-size: 18px; float: right; margin: -4px 0 0 12px;
    }
    .kpi-icon-blue   { background: var(--primary-10); }
    .kpi-icon-purple { background: rgba(139,92,246,.10); }
    .kpi-icon-green  { background: rgba(16,185,129,.10); }
    .kpi-icon-amber  { background: rgba(245,158,11,.10); }

    /* ── Chart card ── */
    .chart-card { padding: 22px 22px 18px; }
    .chart-wrap { height: 255px; }

    /* ── Bottom widgets ── */
    .bottom-card { padding: 20px 22px; }

    /* Ranking list */
    .rank-item {
      display: flex; align-items: center; gap: 12px;
      padding: 12px 0; border-bottom: 1px solid var(--border);
      cursor: pointer; transition: padding-left .18s;
    }
    .rank-item:last-child { border-bottom: none; }
    .rank-item:hover { padding-left: 6px; }
    .rank-num {
      width: 22px; height: 22px; border-radius: 6px; background: var(--bg);
      font-size: 11px; font-weight: 800; display: flex; align-items: center;
      justify-content: center; color: var(--muted); flex-shrink: 0;
    }
    .rank-num.top { background: var(--primary-10); color: var(--primary); }
    .stay-img  { width: 40px; height: 40px; border-radius: 10px; object-fit: cover; flex-shrink: 0; }
    .stay-info { flex: 1; min-width: 0; }
    .stay-info h4 { font-size: 13px; font-weight: 700; margin-bottom: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .stay-info p  { font-size: 11px; color: var(--muted); }
    .stay-cnt  { font-family: var(--font-display); font-size: 14px; font-weight: 800; flex-shrink: 0; }

    /* Inquiry list */
    .inq-item { padding: 14px 0; border-bottom: 1px solid var(--border); }
    .inq-item:last-child { border-bottom: none; }
    .inq-meta { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
    .inq-title { font-size: 13px; font-weight: 700; margin-bottom: 3px; }
    .inq-sub   { font-size: 11px; color: var(--muted); }

    /* API status */
    .api-row {
      display: flex; justify-content: space-between; align-items: center;
      padding: 13px 0; border-bottom: 1px dashed var(--border);
    }
    .api-row:last-child { border-bottom: none; }
    .api-row h4 { font-size: 13px; font-weight: 700; margin-bottom: 2px; }
    .api-row p  { font-size: 11px; color: var(--muted); }
    .api-ok  { display: flex; align-items: center; font-size: 12px; font-weight: 700; color: var(--success); }

    @media (max-width: 1380px) { .chart-grid, .bottom-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 900px)  { .kpi-grid, .chart-grid, .bottom-grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>

<jsp:include page="../layout/header.jsp">
  <jsp:param name="activePage" value="dashboard"/>
</jsp:include>

<main class="main-content">

  <div class="page-header fade-up">
    <div>
      <h1>Platform Overview</h1>
      <p>실시간 플랫폼 운영 상태와 핵심 지표를 확인하세요.</p>
    </div>
    <button class="btn btn-ghost btn-sm">🕐 실시간 갱신 중</button>
  </div>

  <!-- KPI row -->
  <div class="kpi-grid">
    <div class="card kpi-card fade-up fade-up-1">
      <div class="kpi-icon kpi-icon-blue">💰</div>
      <div class="kpi-label">Total GMV (총 거래액)</div>
      <div class="kpi-value">₩1.24B</div>
      <div class="kpi-footer">
        <span class="trend trend-up">↑ 28%</span>
        <span style="color:var(--muted);font-size:11px;">vs 지난달</span>
      </div>
    </div>
    <div class="card kpi-card fade-up fade-up-2">
      <div class="kpi-icon kpi-icon-purple">📋</div>
      <div class="kpi-label">Total Order (총 예약건)</div>
      <div class="kpi-value">12,430건</div>
      <div class="kpi-footer">
        <span class="trend trend-down">↓ 2%</span>
        <span style="color:var(--muted);font-size:11px;">vs 지난달</span>
      </div>
    </div>
    <div class="card kpi-card fade-up fade-up-3">
      <div class="kpi-icon kpi-icon-green">📈</div>
      <div class="kpi-label">Total Revenue (수익)</div>
      <div class="kpi-value">₩112M</div>
      <div class="kpi-footer">
        <span class="trend trend-up">↑ 15%</span>
        <span style="color:var(--muted);font-size:11px;">vs 지난달</span>
      </div>
    </div>
    <div class="card kpi-card fade-up fade-up-4">
      <div class="kpi-icon kpi-icon-amber">👥</div>
      <div class="kpi-label">Active Users (사용자)</div>
      <div class="kpi-value">45.1K</div>
      <div class="kpi-footer">
        <span class="trend trend-up">↑ 8%</span>
        <span style="color:var(--muted);font-size:11px;">vs 지난달</span>
      </div>
    </div>
  </div>


  <div class="chart-grid fade-up">
    <div class="card chart-card">
      <div class="w-header"><h2>📈 월별 매출 추이</h2></div>
      <div class="chart-wrap"><canvas id="lineChart"></canvas></div>
    </div>
    <div class="card chart-card">
      <div class="w-header"><h2>🗺️ 인기 지역 TOP 5</h2></div>
      <div class="chart-wrap"><canvas id="barChart"></canvas></div>
    </div>
    <div class="card chart-card">
      <div class="w-header"><h2>🎯 예약 상태 (Earnings)</h2></div>
      <div class="chart-wrap"><canvas id="pieChart"></canvas></div>
    </div>
  </div>

  <div class="bottom-grid fade-up">

    <div class="card bottom-card">
      <div class="w-header"><h2>🔥 실시간 숙소 랭킹</h2></div>
      <div class="rank-item">
        <div class="rank-num top">1</div>
        <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=100" class="stay-img" alt="">
        <div class="stay-info"><h4>아만 스위트 리저브</h4><p>제주특별자치도</p></div>
        <div class="stay-cnt">124건</div>
      </div>
      <div class="rank-item">
        <div class="rank-num top">2</div>
        <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=100" class="stay-img" alt="">
        <div class="stay-info"><h4>신라 더 파크 호텔</h4><p>서울특별시 중구</p></div>
        <div class="stay-cnt">98건</div>
      </div>
      <div class="rank-item">
        <div class="rank-num">3</div>
        <img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=100" class="stay-img" alt="">
        <div class="stay-info"><h4>루나 오션 펜션</h4><p>강원도 강릉시</p></div>
        <div class="stay-cnt">76건</div>
      </div>
    </div>

    <div class="card bottom-card">
      <div class="w-header">
        <h2>🚨 미답변 문의</h2>
        <span class="badge badge-danger">3건 대기</span>
      </div>
      <div class="inq-item">
        <div class="inq-meta">
          <span class="badge badge-danger">결제/환불</span>
          <button class="btn btn-primary btn-sm">Reply ↗</button>
        </div>
        <div class="inq-title">예약 취소 환불 문의</div>
        <div class="inq-sub">user_1234 · 10분 전</div>
      </div>
      <div class="inq-item">
        <div class="inq-meta">
          <span class="badge badge-wait">이용 문의</span>
          <button class="btn btn-primary btn-sm">Reply ↗</button>
        </div>
        <div class="inq-title">체크인 시간 변경 가능한가요?</div>
        <div class="inq-sub">user_5678 · 32분 전</div>
      </div>
    </div>

    <div class="card bottom-card">
      <div class="w-header"><h2>⚙️ API 상태 모니터링</h2></div>
      <div class="api-row">
        <div><h4>Main DB Server</h4><p>Latency: 12ms</p></div>
        <div class="api-ok"><span class="status-dot dot-success"></span>정상</div>
      </div>
      <div class="api-row">
        <div><h4>Kakao Map API</h4><p>Latency: 45ms</p></div>
        <div class="api-ok"><span class="status-dot dot-success"></span>정상</div>
      </div>
      <div class="api-row">
        <div><h4>Payment Gateway</h4><p>Latency: 88ms</p></div>
        <div class="api-ok"><span class="status-dot dot-success"></span>정상</div>
      </div>
      <div class="api-row">
        <div><h4>SMS / Email API</h4><p>Latency: 210ms</p></div>
        <div style="display:flex;align-items:center;font-size:12px;font-weight:700;color:var(--warning)">
          <span class="status-dot dot-warning"></span>지연
        </div>
      </div>
    </div>

  </div>
</main>

<script>
Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
Chart.defaults.font.size = 11;
Chart.defaults.color = '#8B92A5';

const charts = [];

function mk(id, cfg) {
  const c = new Chart(document.getElementById(id).getContext('2d'), cfg);
  charts.push(c);
}

document.addEventListener('DOMContentLoaded', () => {

  // Line chart
  mk('lineChart', {
    type: 'line',
    data: {
      labels: ['11월','12월','1월','2월','3월'],
      datasets: [{
        data: [80, 110, 150, 140, 200],
        borderColor: '#3B6EF8',
        backgroundColor: (ctx) => {
          const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 260);
          g.addColorStop(0, 'rgba(59,110,248,.18)');
          g.addColorStop(1, 'rgba(59,110,248,.00)');
          return g;
        },
        fill: true, tension: .45, borderWidth: 2.5,
        pointBackgroundColor: '#3B6EF8', pointRadius: 4, pointHoverRadius: 6
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,.05)' }, ticks: { maxTicksLimit: 5 } },
        x: { grid: { display: false } }
      }
    }
  });

  // Bar chart
  mk('barChart', {
    type: 'bar',
    data: {
      labels: ['제주','서울','부산','강릉','경주'],
      datasets: [{
        data: [200, 140, 110, 90, 70],
        backgroundColor: ['#3B6EF8','#8B5CF6','#10B981','#F59E0B','#EF4444'],
        borderRadius: 8, borderSkipped: false
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,.05)' } },
        x: { grid: { display: false } }
      }
    }
  });

  // Doughnut
  mk('pieChart', {
    type: 'doughnut',
    data: {
      labels: ['예약 완료','결제 대기','취소/환불'],
      datasets: [{
        data: [70, 20, 10],
        backgroundColor: ['#10B981','#8B5CF6','#F59E0B'],
        borderWidth: 0, hoverOffset: 6
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false, cutout: '68%',
      plugins: { legend: { position: 'bottom', labels: { padding: 14, usePointStyle: true, pointStyleWidth: 8 } } }
    }
  });

});

window.addEventListener('resize', () => charts.forEach(c => c.resize()));
</script>
</body>
</html>
