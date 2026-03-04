<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TripanSuper — 통계 및 정산</title>
   <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>
<body>
<div class="admin-layout">
<jsp:include page="../layout/sidebar.jsp">
  <jsp:param name="activePage" value="dashboard"/>
</jsp:include>
<div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

<main class="main-content">

  <!-- Header -->
  <div class="page-header fade-up">
    <div>
      <h1>통계 및 정산</h1>
      <p>파트너사 매출 현황과 정산 내역을 관리하세요.</p>
    </div>
    <button class="btn btn-primary">📊 엑셀 다운로드</button>
  </div>

  <!-- KPI row -->
  <div class="kpi-grid">
    <div class="card kpi-card fade-up fade-up-1">
      <div class="kpi-top">
        <div>
          <div class="kpi-label">이번 달 총 거래액 (GMV)</div>
          <div class="kpi-value">₩342.5M</div>
        </div>
        <div class="kpi-icon-wrap" style="background:var(--primary-10)">💳</div>
      </div>
      <span class="trend trend-up">↑ 15.2%</span>
      <span class="kpi-sub" style="margin-left:6px">vs 지난달</span>
    </div>
    <div class="card kpi-card fade-up fade-up-2">
      <div class="kpi-top">
        <div>
          <div class="kpi-label">플랫폼 예상 수익 (수수료)</div>
          <div class="kpi-value" style="color:var(--primary)">₩34.2M</div>
        </div>
        <div class="kpi-icon-wrap" style="background:var(--primary-10)">💹</div>
      </div>
      <span class="trend trend-up">↑ 12.4%</span>
      <span class="kpi-sub" style="margin-left:6px">수수료율 10%</span>
    </div>
    <div class="card kpi-card fade-up fade-up-3">
      <div class="kpi-top">
        <div>
          <div class="kpi-label">정산 대기 금액</div>
          <div class="kpi-value" style="color:var(--warning)">₩125.0M</div>
        </div>
        <div class="kpi-icon-wrap" style="background:rgba(245,158,11,.10)">⏳</div>
      </div>
      <span class="badge badge-wait">12개 파트너사</span>
    </div>
    <div class="card kpi-card fade-up fade-up-4">
      <div class="kpi-top">
        <div>
          <div class="kpi-label">정산 완료 금액</div>
          <div class="kpi-value" style="color:var(--success)">₩183.2M</div>
        </div>
        <div class="kpi-icon-wrap" style="background:rgba(16,185,129,.10)">✅</div>
      </div>
      <span class="badge badge-done">45개 파트너사</span>
    </div>
  </div>

  <!-- Charts -->
  <div class="chart-grid fade-up">
    <div class="card chart-card">
      <div class="w-header"><h2>📈 3월 일별 거래액 추이</h2></div>
      <div class="chart-wrap"><canvas id="lineChart"></canvas></div>
    </div>
    <div class="card chart-card">
      <div class="w-header"><h2>🏆 TOP 파트너사 매출 비중</h2></div>
      <div class="chart-wrap"><canvas id="doughnutChart"></canvas></div>
    </div>
  </div>

  <!-- Filter bar -->
  <div class="filter-bar fade-up">
    <span class="filter-label">🔍 필터</span>
    <select class="filter-select">
      <option>2026년 3월</option>
      <option>2026년 2월</option>
      <option>2026년 1월</option>
    </select>
    <select class="filter-select">
      <option>전체 상태</option>
      <option>정산 대기</option>
      <option>정산 완료</option>
    </select>
    <select class="filter-select">
      <option>전체 파트너사</option>
      <option>아만 스위트 리저브</option>
      <option>신라 더 파크 호텔</option>
    </select>
    <div class="filter-spacer"></div>
    <span style="font-size:12px; color:var(--muted); font-weight:600;">총 57개 파트너사</span>
  </div>

  <!-- Table -->
  <div class="card table-card fade-up">
    <div class="w-header">
      <h2>🧾 파트너사 월별 정산 내역 (2026년 3월)</h2>
    </div>
    <table>
      <thead>
        <tr>
          <th>파트너사</th>
          <th>정산월</th>
          <th>총 결제액 (GMV)</th>
          <th>수수료 (10%)</th>
          <th>최종 지급액 (Net)</th>
          <th>상태</th>
          <th>관리</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>
            <div class="td-partner">
              <span class="partner-avatar">🏝️</span>
              <div class="partner-info"><h4>아만 스위트 리저브</h4><p>#P1001 · 제주</p></div>
            </div>
          </td>
          <td style="color:var(--muted);font-weight:600;">2026-03</td>
          <td><span class="amount">₩45,000,000</span></td>
          <td><span class="amount amount-fee">₩4,500,000</span></td>
          <td><span class="amount amount-net">₩40,500,000</span></td>
          <td><span class="badge badge-wait">정산 대기</span></td>
          <td><button class="btn-approve">정산 승인</button></td>
        </tr>
        <tr>
          <td>
            <div class="td-partner">
              <span class="partner-avatar">🏙️</span>
              <div class="partner-info"><h4>신라 더 파크 호텔</h4><p>#P1002 · 서울</p></div>
            </div>
          </td>
          <td style="color:var(--muted);font-weight:600;">2026-03</td>
          <td><span class="amount">₩38,500,000</span></td>
          <td><span class="amount amount-fee">₩3,850,000</span></td>
          <td><span class="amount amount-net">₩34,650,000</span></td>
          <td><span class="badge badge-done">정산 완료</span></td>
          <td><button class="btn-done">승인완료</button></td>
        </tr>
        <tr>
          <td>
            <div class="td-partner">
              <span class="partner-avatar">🌊</span>
              <div class="partner-info"><h4>루나 오션 펜션</h4><p>#P1003 · 강릉</p></div>
            </div>
          </td>
          <td style="color:var(--muted);font-weight:600;">2026-03</td>
          <td><span class="amount">₩22,000,000</span></td>
          <td><span class="amount amount-fee">₩2,200,000</span></td>
          <td><span class="amount amount-net">₩19,800,000</span></td>
          <td><span class="badge badge-wait">정산 대기</span></td>
          <td><button class="btn-approve">정산 승인</button></td>
        </tr>
        <tr>
          <td>
            <div class="td-partner">
              <span class="partner-avatar">🏖️</span>
              <div class="partner-info"><h4>해운대 비치 리조트</h4><p>#P1004 · 부산</p></div>
            </div>
          </td>
          <td style="color:var(--muted);font-weight:600;">2026-03</td>
          <td><span class="amount">₩18,700,000</span></td>
          <td><span class="amount amount-fee">₩1,870,000</span></td>
          <td><span class="amount amount-net">₩16,830,000</span></td>
          <td><span class="badge badge-done">정산 완료</span></td>
          <td><button class="btn-done">승인완료</button></td>
        </tr>
        <tr>
          <td>
            <div class="td-partner">
              <span class="partner-avatar">🏯</span>
              <div class="partner-info"><h4>경주 한옥 스테이</h4><p>#P1005 · 경주</p></div>
            </div>
          </td>
          <td style="color:var(--muted);font-weight:600;">2026-03</td>
          <td><span class="amount">₩14,200,000</span></td>
          <td><span class="amount amount-fee">₩1,420,000</span></td>
          <td><span class="amount amount-net">₩12,780,000</span></td>
          <td><span class="badge badge-wait">정산 대기</span></td>
          <td><button class="btn-approve">정산 승인</button></td>
        </tr>
      </tbody>
    </table>
  </div>

</main>
</div>
</div>

<script>
Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
Chart.defaults.font.size = 11;
Chart.defaults.color = '#8B92A5';

const charts = [];

document.addEventListener('DOMContentLoaded', () => {

  // Line
  const ctxL = document.getElementById('lineChart').getContext('2d');
  const gL = ctxL.createLinearGradient(0, 0, 0, 260);
  gL.addColorStop(0, 'rgba(16,185,129,.18)');
  gL.addColorStop(1, 'rgba(16,185,129,.00)');
  charts.push(new Chart(ctxL, {
    type: 'line',
    data: {
      labels: ['1일','2일','3일','4일','5일','6일','7일'],
      datasets: [{
        data: [12, 19, 15, 22, 30, 28, 35],
        borderColor: '#10B981', backgroundColor: gL,
        fill: true, tension: .45, borderWidth: 2.5,
        pointBackgroundColor: '#10B981', pointRadius: 4, pointHoverRadius: 6
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
  }));

  // Doughnut
  charts.push(new Chart(document.getElementById('doughnutChart').getContext('2d'), {
    type: 'doughnut',
    data: {
      labels: ['아만 스위트','신라 호텔','루나 펜션','해운대','기타'],
      datasets: [{
        data: [40, 25, 20, 10, 5],
        backgroundColor: ['#3B6EF8','#8B5CF6','#10B981','#F59E0B','#E5E7EB'],
        borderWidth: 0, hoverOffset: 8
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false, cutout: '66%',
      plugins: { legend: { position: 'bottom', labels: { padding: 14, usePointStyle: true, pointStyleWidth: 8 } } }
    }
  }));

});

window.addEventListener('resize', () => charts.forEach(c => c.resize()));
</script>
</body>
</html>
