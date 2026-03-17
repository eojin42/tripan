<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripan Partner — 파트너 센터</title>
  
  <jsp:include page="/WEB-INF/views/partner/layout/headerResources.jsp" />
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    .admin-layout { display: flex; height: 100vh; width: 100vw; overflow: hidden; }
    .sidebar { width: 260px; background: var(--surface); border-right: 1px solid var(--border); display: flex; flex-direction: column; z-index: 1000; box-shadow: var(--shadow-sm); }
    .sidebar-header { height: 72px; display: flex; align-items: center; padding: 0 20px; }
    .sidebar-menu { flex: 1; padding: 20px 12px; display: flex; flex-direction: column; gap: 4px; }
    .menu-label { margin-top: 16px; margin-bottom: 8px; padding-left: 16px; font-size: 11px; font-weight: 800; color: var(--muted); text-transform: uppercase; }
    .menu-item { display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: var(--radius-md); font-size: 13px; font-weight: 700; color: var(--muted); transition: all 0.2s; cursor: pointer; }
    .menu-item:hover { background: rgba(0,0,0,0.04); color: var(--text); }
    .menu-item.active { background: var(--primary); color: white; }
    .menu-icon { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .main-wrapper { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
    .main-content { flex: 1; overflow-y: auto; padding: 32px 40px; width: 100%; max-width: 1400px; margin: 0 auto; }
    .page-header { margin-bottom: 26px; }
    .page-header h1 { font-family: var(--font-display); font-size: 24px; font-weight: 800; margin-bottom: 6px; }
    .page-header p { color: var(--muted); font-size: 13px; }

    .page-section { display: none; animation: fadeUp .45s ease both; }
    .page-section.active { display: block; }
    @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }

    .card { background: var(--surface); border-radius: var(--radius-xl); box-shadow: var(--shadow-sm); border: 1px solid rgba(255,255,255,.8); padding: 24px; margin-bottom: 24px; }
    .w-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
    .w-header h2 { font-size: 15px; font-weight: 800; }
    
    .badge { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; display: inline-flex; align-items: center; gap: 4px; }
    .badge-wait { background: #FEF3C7; color: #D97706; }
    .badge-done { background: #ECFDF5; color: var(--success); }
    .badge-danger { background: #FFE4E6; color: var(--danger); }
    
    .btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: var(--radius-full); font-size: 13px; font-weight: 700; transition: all .2s; cursor: pointer; border: none; }
    .btn-primary { background: var(--text); color: white; }
    .btn-primary:hover { opacity: .85; transform: translateY(-1px); }
    .btn-ghost { background: rgba(0,0,0,.05); color: var(--text); }
    .btn-ghost:hover { background: rgba(0,0,0,.09); }
    .btn-danger { background: #FEF2F2; color: var(--danger); border: 1px solid #FECACA; }
    .btn-danger:hover { background: var(--danger); color: white; }
    .btn-sm { padding: 6px 14px; font-size: 12px; border-radius: var(--radius-md); }

    table { width: 100%; border-collapse: collapse; }
    th { padding: 14px 16px; font-size: 12px; font-weight: 700; color: var(--muted); border-bottom: 2px solid var(--border); text-align: left; }
    td { padding: 16px; border-bottom: 1px dashed var(--border); vertical-align: middle; font-size: 13px; font-weight: 600; }
    tbody tr:hover td { background: rgba(59,110,248,.03); }

    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
    .kpi-card { padding: 24px; }
    .kpi-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
    .kpi-label { font-size: 12px; font-weight: 700; color: var(--muted); letter-spacing: .4px; text-transform: uppercase; margin-bottom: 8px; }
    .kpi-value { font-family: var(--font-display); font-size: 28px; font-weight: 900; letter-spacing: -.5px; color: var(--text); }
    .kpi-icon-wrap { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; background: var(--primary-10); }

    .modal-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(4px); display: none; justify-content: center; align-items: center; z-index: 9999; }
    .modal-overlay.open { display: flex; }
    .modal-content { background: var(--surface); width: 460px; border-radius: var(--radius-xl); padding: 32px; box-shadow: var(--shadow-lg); animation: fadeUp .3s ease; }
    .modal-header h2 { font-size: 18px; font-weight: 800; margin-bottom: 20px; }
    .modal-body textarea { width: 100%; height: 100px; padding: 12px; border: 1px solid var(--border); border-radius: var(--radius-md); font-family: var(--font-body); resize: none; margin-bottom: 20px; outline:none; }
  </style>
</head>
<body>

<div class="admin-layout">
  
  <jsp:include page="/WEB-INF/views/partner/layout/sidebar.jsp" />

  <div class="main-wrapper">
    <jsp:include page="/WEB-INF/views/partner/layout/header.jsp" />

    <main class="main-content">
      
      <div id="tab-dashboard" class="page-section ${activeTab == 'dashboard' ? 'active' : ''}">
        <div class="page-header">
          <h1>Dashboard</h1>
          <p>오늘의 숙소 현황과 알림을 확인하세요.</p>
        </div>
        <div class="kpi-grid">
          <div class="card kpi-card">
            <div class="kpi-top">
              <div><div class="kpi-label">오늘 체크인</div><div class="kpi-value">3건</div></div>
              <div class="kpi-icon-wrap">🔑</div>
            </div>
          </div>
          <div class="card kpi-card">
            <div class="kpi-top">
              <div><div class="kpi-label">오늘 체크아웃</div><div class="kpi-value">2건</div></div>
              <div class="kpi-icon-wrap" style="background:rgba(139,92,246,.10)">👋</div>
            </div>
          </div>
          <div class="card kpi-card">
            <div class="kpi-top">
              <div><div class="kpi-label">신규 예약 대기</div><div class="kpi-value" style="color:var(--danger)">5건</div></div>
              <div class="kpi-icon-wrap" style="background:#FFE4E6">🚨</div>
            </div>
          </div>
          <div class="card kpi-card">
            <div class="kpi-top">
              <div><div class="kpi-label">이번 달 누적 매출</div><div class="kpi-value" style="color:var(--primary)">₩4.25M</div></div>
              <div class="kpi-icon-wrap" style="background:rgba(16,185,129,.10)">💳</div>
            </div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
          <div class="card">
            <div class="w-header"><h2>📈 주간 예약 추이</h2></div>
            <div style="height: 250px;"><canvas id="chartMockup"></canvas></div>
          </div>
          <div class="card">
            <div class="w-header"><h2>🔔 최근 알림</h2></div>
            <ul style="display:flex; flex-direction:column; gap:12px; padding:0;">
              <li style="padding-bottom:12px; border-bottom:1px dashed var(--border);">
                <span class="badge badge-wait">리뷰</span><br>
                <span style="font-weight:700;">미답변 리뷰가 2건 있습니다.</span>
              </li>
              <li style="padding-bottom:12px; border-bottom:1px dashed var(--border);">
                <span class="badge badge-done">시스템</span><br>
                <span style="font-weight:700;">10월분 정산 명세서가 발행되었습니다.</span>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div id="tab-room" class="page-section ${activeTab == 'room' ? 'active' : ''}">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
          <div><h1>숙소 및 객실 관리</h1><p>객실 타입, 침대 옵션 및 기본 요금을 설정합니다.</p></div>
          <button class="btn btn-primary">+ 새 객실 등록</button>
        </div>
        <div class="card" style="display: flex; gap: 24px; align-items: center;">
          <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=200&q=80" style="width: 160px; height: 120px; border-radius: 12px; object-fit: cover;">
          <div style="flex: 1;">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 8px;">오션뷰 스위트 (Ocean Suite)</h3>
            <p style="color: var(--muted); margin-bottom: 4px;">👥 인원: 기준 2명 / 최대 4명</p>
            <p style="color: var(--muted); margin-bottom: 12px;">🛏️ 침대 옵션: 퀸사이즈 1, 싱글 1</p>
            <p style="font-family: var(--font-display); font-size: 16px; font-weight: 900; color: var(--text);">💰 기본 요금: 150,000원</p>
          </div>
          <div>
            <button class="btn btn-ghost btn-sm">수정</button>
            <button class="btn btn-danger btn-sm">삭제</button>
          </div>
        </div>
      </div>

      <div id="tab-booking" class="page-section ${activeTab == 'booking' ? 'active' : ''}">
        <div class="page-header"><h1>예약 관리</h1><p>예약 내역을 확인하고 필요시 강제 취소할 수 있습니다.</p></div>
        <div class="card table-card">
          <table>
            <thead>
              <tr><th>예약번호</th><th>예약자</th><th>객실명</th><th>체크인~아웃</th><th>결제금액</th><th>상태</th><th>고객요청사항</th><th style="text-align:center;">관리</th></tr>
            </thead>
            <tbody>
              <tr>
                <td>R-1001</td><td>김철수</td><td>오션뷰 스위트</td><td>26.10.12 ~ 26.10.13</td><td>₩ 150,000</td>
                <td><span class="badge badge-done">예약확정</span></td>
                <td style="color:var(--muted)">수건 넉넉히 부탁드려요</td>
                <td style="text-align:center;"><button class="btn btn-ghost btn-sm">상세</button></td>
              </tr>
              <tr>
                <td>R-1002</td><td>이영희</td><td>스탠다드 더블</td><td>26.10.15 ~ 26.10.16</td><td>₩ 100,000</td>
                <td><span class="badge badge-wait">결제완료</span></td>
                <td style="color:var(--muted)">고층으로 배정해주세요</td>
                <td style="text-align:center;"><button class="btn btn-danger btn-sm" onclick="openCancelModal('R-1002')">강제취소</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div id="tab-review" class="page-section ${activeTab == 'review' ? 'active' : ''}">
        <div class="page-header"><h1>리뷰 관리</h1><p>고객의 소리에 답글을 달거나 악성 리뷰를 신고하세요.</p></div>
        
        <div class="card" style="margin-bottom: 16px;">
          <div style="display:flex; justify-content:space-between; margin-bottom: 8px;">
            <strong style="font-size: 15px;">⭐⭐⭐⭐⭐ 김철수 님</strong><span style="font-size: 12px; color: var(--muted);">2026-10-10</span>
          </div>
          <p style="font-size: 14px; margin-bottom: 16px;">방이 너무 깨끗하고 뷰가 정말 좋았어요! 다음에 또 올게요~</p>
          <div style="background: var(--bg); padding: 16px; border-radius: 8px; border-left: 3px solid var(--primary);">
            <strong style="color: var(--primary); font-size: 12px;">사장님 답글</strong>
            <p style="margin-top: 6px; font-size: 13px;">철수님 소중한 리뷰 감사합니다! 항상 청결을 유지하겠습니다 :)</p>
          </div>
        </div>

        <div class="card">
          <div style="display:flex; justify-content:space-between; margin-bottom: 8px;">
            <strong style="font-size: 15px;">⭐ 악성유저</strong><span style="font-size: 12px; color: var(--muted);">2026-10-09</span>
          </div>
          <p style="font-size: 14px; margin-bottom: 16px;">가지마세요 개스레기임 벌레나옴 환불해내라</p>
          <div style="display: flex; gap: 8px;">
            <button class="btn btn-ghost btn-sm">답글 달기</button>
            <button class="btn btn-danger btn-sm" onclick="alert('최고 관리자에게 해당 리뷰 블라인드를 요청했습니다.')">🚨 블라인드 신고 (요청)</button>
          </div>
        </div>
      </div>

      <div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
        <div class="page-header"><h1>정산 내역</h1><p>월별 수수료 차감 내역 및 실 지급액을 확인합니다.</p></div>
        <div class="card table-card">
          <table>
            <thead>
              <tr><th>정산월</th><th>총 결제액 (GMV)</th><th>플랫폼 수수료 (10%)</th><th>실 지급액 (Net)</th><th>상태</th><th>명세서</th></tr>
            </thead>
            <tbody>
              <tr>
                <td style="font-weight:700;">2026년 09월</td><td>₩ 5,000,000</td><td style="color:var(--danger)">- ₩ 500,000</td>
                <td style="color:var(--primary); font-family:var(--font-display); font-weight:900;">₩ 4,500,000</td>
                <td><span class="badge badge-done">지급완료</span></td>
                <td><button class="btn btn-ghost btn-sm">PDF 다운</button></td>
              </tr>
              <tr>
                <td style="font-weight:700;">2026년 10월</td><td>₩ 4,250,000</td><td style="color:var(--danger)">- ₩ 425,000</td>
                <td style="color:var(--primary); font-family:var(--font-display); font-weight:900;">₩ 3,825,000</td>
                <td><span class="badge badge-wait">정산 대기</span></td>
                <td>-</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</div>

<div class="modal-overlay" id="cancelModal">
  <div class="modal-content">
    <div class="modal-header">
      <h2 style="color: var(--danger); margin-top: 0;">🚨 예약 강제 취소</h2>
      <p style="font-size: 13px; color: var(--muted); margin-bottom: 20px;">오버부킹 또는 내부 사정으로 인한 취소 시,<br>고객에게 안내될 <strong>취소 사유를 반드시 입력</strong>해야 합니다.</p>
    </div>
    <div class="modal-body">
      <textarea id="cancelReason" placeholder="예: 시스템 오류로 인한 오버부킹 발생으로 부득이하게 취소 처리되었습니다. 죄송합니다."></textarea>
      <div style="display: flex; gap: 10px; justify-content: flex-end;">
        <button class="btn btn-ghost" onclick="closeCancelModal()">닫기</button>
        <button class="btn btn-danger" onclick="submitCancel()">취소 확정</button>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/partner/layout/footerResources.jsp" />

<script>
  function openCancelModal(resId) {
    document.getElementById('cancelModal').classList.add('open');
  }
  function closeCancelModal() {
    document.getElementById('cancelModal').classList.remove('open');
    document.getElementById('cancelReason').value = '';
  }
  function submitCancel() {
    const reason = document.getElementById('cancelReason').value;
    if(!reason.trim()) { alert("취소 사유를 입력해주세요!"); return; }
    alert("취소 사유가 등록되며 예약이 강제 취소되었습니다.\\n사유: " + reason);
    closeCancelModal();
  }

  document.addEventListener('DOMContentLoaded', () => {
    if(document.getElementById('chartMockup')) {
      Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
      const ctx = document.getElementById('chartMockup').getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['월', '화', '수', '목', '금', '토', '일'],
          datasets: [{
            label: '예약 건수',
            data: [2, 3, 1, 5, 8, 12, 10],
            borderColor: '#3B6EF8',
            backgroundColor: 'rgba(59,110,248,0.1)',
            fill: true, tension: 0.4, borderWidth: 3
          }]
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
      });
    }
  });
</script>

</body>
</html>