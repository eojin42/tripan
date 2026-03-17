<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripan Partner — 파트너 센터</title>
  
  <%-- 공통 리소스 (CSS, JS) --%>
  <jsp:include page="/WEB-INF/views/partner/layout/headerResources.jsp" />
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    /* =========================================================
       레이아웃 및 공통 스타일 (main.jsp에 집중)
    ========================================================= */
    .admin-layout { display: flex; height: 100vh; width: 100vw; overflow: hidden; background: #F0F2F8; }
    
    /* 우측 메인 영역 영역 */
    .main-wrapper { flex: 1; display: flex; flex-direction: column; min-width: 0; position: relative; }
    
    /* 헤더 고정 해제 및 상단 배치 */
    .top-header { position: relative !important; width: 100% !important; left: 0 !important; background: #FFF; border-bottom: 1px solid rgba(0,0,0,0.07); height: 72px; display: flex; align-items: center; padding: 0 40px; z-index: 1000; }
    
    /* 실제 컨텐츠 스크롤 영역 */
    .main-content { flex: 1; overflow-y: auto; padding: 32px 40px; }
    
    /* 탭 섹션 전환 애니메이션 */
    .page-section { display: none; animation: fadeUp .45s ease both; }
    .page-section.active { display: block; }
    @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }

    /* 카드 및 UI 요소 */
    .card { background: #FFF; border-radius: 24px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid rgba(255,255,255,0.8); }
    .page-header { margin-bottom: 26px; }
    .page-header h1 { font-family: 'Sora', sans-serif; font-size: 24px; font-weight: 800; margin-bottom: 6px; }
    .page-header p { color: #8B92A5; font-size: 13px; }

    /* KPI 그리드 */
    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
    .kpi-label { font-size: 12px; font-weight: 700; color: #8B92A5; margin-bottom: 8px; text-transform: uppercase; }
    .kpi-value { font-family: 'Sora', sans-serif; font-size: 28px; font-weight: 900; color: #0D1117; }
    .kpi-icon-wrap { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; background: rgba(59,110,248,0.1); }

    /* 테이블 스타일 */
    table { width: 100%; border-collapse: collapse; }
    th { padding: 14px 16px; font-size: 12px; font-weight: 700; color: #8B92A5; border-bottom: 2px solid rgba(0,0,0,0.07); text-align: left; }
    td { padding: 16px; border-bottom: 1px dashed rgba(0,0,0,0.07); font-size: 13px; font-weight: 600; }
    
    /* 뱃지 */
    .badge { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; display: inline-flex; align-items: center; gap: 4px; }
    .badge-done { background: #ECFDF5; color: #10B981; }
    .badge-wait { background: #FEF3C7; color: #D97706; }

    /* 버튼 */
    .btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 100px; font-size: 13px; font-weight: 700; cursor: pointer; border: none; transition: 0.2s; }
    .btn-primary { background: #0D1117; color: white; }
    .btn-ghost { background: rgba(0,0,0,0.05); color: #0D1117; }
  </style>
</head>
<body>

<div class="admin-layout">
  
  <%-- 1. 사이드바 (사이드 메뉴) --%>
  <jsp:include page="/WEB-INF/views/partner/layout/sidebar.jsp" />

  <div class="main-wrapper">
    
    <%-- 2. 상단 헤더 --%>
    <jsp:include page="/WEB-INF/views/partner/layout/header.jsp" />

    <%-- 3. 본문 영역 --%>
    <main class="main-content">
      
      <div id="tab-dashboard" class="page-section ${activeTab == 'dashboard' ? 'active' : ''}">
        <div class="page-header">
          <h1>Dashboard</h1>
          <p>오늘의 숙소 현황과 주요 지표를 확인하세요.</p>
        </div>
        
        <div class="kpi-grid">
          <div class="card">
            <div style="display:flex; justify-content:space-between;">
              <div><div class="kpi-label">오늘 체크인</div><div class="kpi-value">3건</div></div>
              <div class="kpi-icon-wrap">🔑</div>
            </div>
          </div>
          <div class="card">
            <div style="display:flex; justify-content:space-between;">
              <div><div class="kpi-label">오늘 체크아웃</div><div class="kpi-value">2건</div></div>
              <div class="kpi-icon-wrap" style="background:rgba(139,92,246,0.1)">👋</div>
            </div>
          </div>
          <div class="card">
            <div style="display:flex; justify-content:space-between;">
              <div><div class="kpi-label">신규 예약 대기</div><div class="kpi-value" style="color:#EF4444">5건</div></div>
              <div class="kpi-icon-wrap" style="background:#FFE4E6">🚨</div>
            </div>
          </div>
          <div class="card">
            <div style="display:flex; justify-content:space-between;">
              <div><div class="kpi-label">이번 달 매출</div><div class="kpi-value" style="color:#3B6EF8">₩4.2M</div></div>
              <div class="kpi-icon-wrap" style="background:rgba(16,185,129,0.1)">💳</div>
            </div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
          <div class="card">
            <h2 style="font-size:15px; font-weight:800; margin-bottom:16px;">📈 주간 예약 추이</h2>
            <div style="height: 250px;"><canvas id="mainDashboardChart"></canvas></div>
          </div>
          <div class="card">
            <h2 style="font-size:15px; font-weight:800; margin-bottom:16px;">🔔 최근 알림</h2>
            <ul style="list-style:none; padding:0; margin:0;">
              <li style="padding:12px 0; border-bottom:1px dashed #eee;">
                <span class="badge badge-wait">리뷰</span> 미답변 리뷰가 있습니다.
              </li>
              <li style="padding:12px 0;">
                <span class="badge badge-done">정산</span> 9월 정산이 완료되었습니다.
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div id="tab-room" class="page-section ${activeTab == 'room' ? 'active' : ''}">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
          <div><h1>숙소 및 객실 관리</h1><p>판매 중인 객실 정보와 가격을 관리합니다.</p></div>
          <button class="btn btn-primary">+ 새 객실 등록</button>
        </div>
        <div class="card" style="display:flex; gap:20px; align-items:center;">
          <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=200&q=80" style="width:150px; height:100px; border-radius:12px; object-fit:cover;">
          <div style="flex:1;">
            <h3 style="font-size:16px; font-weight:800;">오션뷰 프리미엄 룸</h3>
            <p style="color:#8B92A5; font-size:13px; margin:4px 0;">기준 2인 / 최대 4인 • 퀸 침대 1개</p>
            <p style="font-weight:900; color:#3B6EF8;">₩ 150,000 ~</p>
          </div>
          <button class="btn btn-ghost">관리</button>
        </div>
      </div>

      <div id="tab-booking" class="page-section ${activeTab == 'booking' ? 'active' : ''}">
        <div class="page-header"><h1>예약 내역 관리</h1><p>실시간 예약 현황을 확인하고 관리하세요.</p></div>
        <div class="card" style="padding:0; overflow:hidden;">
          <table>
            <thead>
              <tr><th>예약번호</th><th>예약자</th><th>객실명</th><th>체크인/아웃</th><th>금액</th><th>상태</th><th>관리</th></tr>
            </thead>
            <tbody>
              <tr>
                <td>BK-20231015</td><td>김철수</td><td>오션뷰 프리미엄</td><td>10.20 ~ 10.21</td><td>150,000원</td>
                <td><span class="badge badge-done">예약확정</span></td>
                <td><button class="btn btn-ghost" style="padding:4px 12px; font-size:11px;">상세</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div id="tab-review" class="page-section ${activeTab == 'review' ? 'active' : ''}">
        <div class="page-header"><h1>리뷰 관리</h1><p>고객님이 남겨주신 소중한 리뷰에 답글을 달아보세요.</p></div>
        <div class="card">
          <div style="display:flex; justify-content:space-between; margin-bottom:10px;">
            <span style="font-weight:800;">⭐⭐⭐⭐⭐ 이영희 님</span>
            <span style="color:#8B92A5; font-size:12px;">2023.10.12</span>
          </div>
          <p style="font-size:14px; line-height:1.6;">정말 깨끗하고 뷰가 환상적이었어요! 사장님도 친절하십니다.</p>
          <div style="margin-top:15px; background:#F8FAFC; padding:15px; border-radius:12px;">
            <p style="font-size:13px; color:#3B6EF8; font-weight:800; margin-bottom:5px;">사장님 답변</p>
            <p style="font-size:13px;">영희님 방문해주셔서 감사합니다! 다음에 또 뵙기를 바랍니다 :)</p>
          </div>
        </div>
      </div>

      <div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
        <div class="page-header"><h1>정산 내역</h1><p>매월 발생한 매출과 정산 금액을 확인합니다.</p></div>
        <div class="card" style="padding:0; overflow:hidden;">
          <table>
            <thead>
              <tr><th>정산월</th><th>총 매출</th><th>수수료(10%)</th><th>최종 지급액</th><th>상태</th></tr>
            </thead>
            <tbody>
              <tr>
                <td>2023년 09월</td><td>₩ 5,000,000</td><td style="color:#EF4444">- ₩ 500,000</td><td style="font-weight:900;">₩ 4,500,000</td>
                <td><span class="badge badge-done">지급완료</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <%-- 나머지 탭들(info, calendar, chat, stats, tax, notice, settings)도 동일한 구조로 추가하시면 됩니다! --%>

    </main>
  </div>
</div>


<script>
  // 대시보드 차트 초기화
  document.addEventListener('DOMContentLoaded', () => {
    const ctx = document.getElementById('mainDashboardChart');
    if (ctx) {
      new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['월', '화', '수', '목', '금', '토', '일'],
          datasets: [{
            label: '예약 건수',
            data: [12, 19, 3, 5, 2, 3, 7],
            borderColor: '#3B6EF8',
            backgroundColor: 'rgba(59,110,248,0.1)',
            fill: true,
            tension: 0.4
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } }
        }
      });
    }
  });
</script>

</body>
</html>