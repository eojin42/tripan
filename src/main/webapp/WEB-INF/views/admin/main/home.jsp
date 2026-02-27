<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tripan Admin - Super Dashboard</title>
<link rel="preconnect" href="https://cdn.jsdelivr.net">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">

</head>
<body>

<div class="admin-wrapper">
  
  <aside class="admin-sidebar">
    <div class="brand-logo">
      <span class="trip">Tri</span><span class="an">pan</span><span class="brand-badge">Super</span>
    </div>
    
    <ul class="admin-menu">
      <li class="active"><a href="#">📊 KPI 대시보드</a></li>
      
      <div class="menu-section">Member & Partner</div>
      <li><a href="#">👥 전체 회원 및 권한 관리</a></li>
      <li><a href="#">🏢 파트너사 현황 및 심사</a></li>
      
      <div class="menu-section">Commerce</div>
      <li><a href="#">💳 전체 예약 및 결제 관리</a></li>
      <li><a href="#">💰 플랫폼 매출 및 정산</a></li>
      
      <div class="menu-section">Content & Community</div>
      <li><a href="#">🖼️ 배너 및 기획전 설정</a></li>
      <li><a href="#">🚨 커뮤니티 신고 모니터링</a></li>
      <li><a href="#">💬 1:1 문의 / 채팅방 관리</a></li>
      
      <div class="menu-section">System</div>
      <li><a href="#">⚙️ API 및 서버 상태 점검</a></li>
      <li><a href="#">📝 최고 관리자 활동 로그</a></li>
    </ul>
  </aside>

  <main class="admin-main">
    
    <header class="admin-header">
      <div class="admin-title">
        <h2>플랫폼 통합 대시보드 🏆</h2>
        <p>실시간 플랫폼 운영 상태와 핵심 지표를 확인하세요.</p>
      </div>
      <div class="profile-badge">
        <div class="profile-pic"></div>
        <span style="font-weight: 800; font-size: 14px; padding-right: 8px;">Master Admin</span>
      </div>
    </header>

    <div class="kpi-grid">
      <div class="kpi-card">
        <div class="kpi-title">총 거래액 (Total GMV) <span class="kpi-trend up">↑ 12.5%</span></div>
        <div class="kpi-value">₩ 125,400,000</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">총 영업이익 (수수료 수익) <span class="kpi-trend up">↑ 8.2%</span></div>
        <div class="kpi-value">₩ 11,286,000</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">월간 활성 사용자 (MAU) <span class="kpi-trend up">↑ 2.4%</span></div>
        <div class="kpi-value">45,120 <span style="font-size: 14px; color: var(--text-gray);">명</span></div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">평균 예약 취소율 <span class="kpi-trend down">↓ 1.1%</span></div>
        <div class="kpi-value">4.2%</div>
      </div>
    </div>

    <div class="dashboard-grid">
      <div class="dash-panel">
        <div class="panel-header">
          <span class="panel-title">월별 매출 추이 (GMV)</span>
          <button class="btn-more">상세 리포트</button>
        </div>
        <div class="chart-area">
          <div class="bar" style="height: 30%;" data-val="32M"></div>
          <div class="bar" style="height: 50%;" data-val="55M"></div>
          <div class="bar" style="height: 40%;" data-val="48M"></div>
          <div class="bar" style="height: 70%;" data-val="82M"></div>
          <div class="bar" style="height: 85%;" data-val="95M"></div>
          <div class="bar" style="height: 100%; background: var(--point-blue);" data-val="125M"></div>
        </div>
        <div style="display: flex; justify-content: space-between; margin-top: 12px; font-size: 12px; color: var(--text-gray); font-weight: 700;">
          <span>9월</span><span>10월</span><span>11월</span><span>12월</span><span>1월</span><span>이번달</span>
        </div>
      </div>

      <div class="dash-panel">
        <div class="panel-header">
          <span class="panel-title">시스템 API 상태</span>
          <button class="btn-more">로그 보기</button>
        </div>
        <div class="status-list">
          <div class="status-item">
            <div><span class="status-dot green"></span><span style="font-size: 14px; font-weight: 800;">Main DB Server</span></div>
            <span style="font-size: 12px; color: var(--text-gray);">응답: 12ms</span>
          </div>
          <div class="status-item">
            <div><span class="status-dot green"></span><span style="font-size: 14px; font-weight: 800;">Kakao Map API</span></div>
            <span style="font-size: 12px; color: var(--text-gray);">정상 호출중</span>
          </div>
          <div class="status-item" style="background: #FFF5F5; border: 1px solid #FED7D7;">
            <div><span class="status-dot red"></span><span style="font-size: 14px; font-weight: 800; color: var(--point-red);">Google Places API</span></div>
            <span style="font-size: 12px; color: var(--point-red); font-weight: 700;">할당량 초과 경고</span>
          </div>
        </div>
      </div>
    </div>

    <div class="dashboard-grid">
      
      <div class="dash-panel">
        <div class="panel-header">
          <span class="panel-title">신규 파트너 입점 심사 대기</span>
          <button class="btn-more">전체 보기</button>
        </div>
        <table class="data-table">
          <thead>
            <tr>
              <th>업체명(분류)</th>
              <th>신청일</th>
              <th>상태</th>
              <th>계약서 / 관리</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><strong>스테이 오션 파크</strong> <br><span style="font-size: 12px; color: var(--text-gray);">숙박 / 제주</span></td>
              <td>2026-02-25</td>
              <td><span class="status-badge status-wait">검토 대기</span></td>
              <td><button class="btn-more" style="background: white; border: 1px solid var(--border-light);">📄 PDF 열람</button></td>
            </tr>
            <tr>
              <td><strong>바다마을 횟집</strong> <br><span style="font-size: 12px; color: var(--text-gray);">맛집 / 부산</span></td>
              <td>2026-02-26</td>
              <td><span class="status-badge status-info">서류 보완</span></td>
              <td><button class="btn-more">심사 진행</button></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="dash-panel">
        <div class="panel-header">
          <span class="panel-title">실시간 신고 접수 현황</span>
          <button class="btn-more">처리 내역</button>
        </div>
        <table class="data-table">
          <thead>
            <tr>
              <th>신고 위치</th>
              <th>사유</th>
              <th>조치</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><strong style="color: var(--point-blue);">자유게시판</strong></td>
              <td>욕설 및 비방 (누적 3회)</td>
              <td><button class="btn-more" style="background: #FFF5F5; color: var(--point-red);">글 블라인드</button></td>
            </tr>
            <tr>
              <td><strong>제주 채팅방</strong></td>
              <td>도배성 광고 링크</td>
              <td><button class="btn-more">강제 퇴장</button></td>
            </tr>
          </tbody>
        </table>
      </div>

    </div>

  </main>
</div>

</body>
</html>