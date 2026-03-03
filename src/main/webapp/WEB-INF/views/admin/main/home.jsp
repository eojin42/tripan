<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper - 대시보드</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  
  <style>
    /* --- 모던 대시보드 컬러 & 변수 --- */
    :root {
      --bg-body: #F4F7FE; /* 부드러운 연회색 배경 */
      --bg-card: #FFFFFF;
      --text-main: #2B3674; /* 짙은 네이비 (제목용) */
      --text-muted: #A3AED0; /* 연한 회색 (설명용) */
      --primary: #4318FF; /* 레퍼런스 이미지의 보라/파랑 포인트 컬러 */
      --secondary: #89CFF0; /* Tripan 기존 블루 */
      --success: #05CD99;
      --warning: #FFCE20;
      --danger: #EE5D50;
      --radius: 20px;
      --shadow: 0px 18px 40px rgba(112, 144, 176, 0.12);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background-color: var(--bg-body); font-family: 'Pretendard', sans-serif; color: var(--text-main); }
    a { text-decoration: none; color: inherit; }
    ul { list-style: none; }

    /* --- 레이아웃 --- */
    .app-container { display: flex; min-height: 100vh; }

    /* --- 화이트 사이드바 (레퍼런스 스타일) --- */
    .sidebar {
      width: 280px; background-color: var(--bg-card); padding: 30px 20px; flex-shrink: 0;
      border-right: 1px solid #E9EDF7;
    }
    .brand { font-size: 26px; font-weight: 900; color: var(--text-main); margin-bottom: 40px; padding-left: 10px; display: flex; align-items: center; gap: 8px;}
    .brand span { color: var(--primary); }
    
    .menu-title { font-size: 12px; font-weight: 700; color: var(--text-muted); margin: 20px 0 10px 10px; text-transform: uppercase; }
    .nav-item { display: flex; align-items: center; padding: 14px 16px; color: var(--text-muted); font-weight: 600; border-radius: 12px; margin-bottom: 4px; transition: 0.2s; cursor: pointer; }
    .nav-item:hover { background-color: #F4F7FE; color: var(--text-main); }
    .nav-item.active { background-color: var(--primary); color: white; box-shadow: 0 4px 12px rgba(67, 24, 255, 0.3); }
    .nav-icon { margin-right: 12px; font-size: 18px; }

    /* --- 메인 콘텐츠 --- */
    .main-content { flex: 1; padding: 40px; overflow-y: auto; }
    
    /* 상단 헤더 */
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .header-left h1 { font-size: 32px; font-weight: 800; }
    .header-left p { color: var(--text-muted); font-size: 15px; font-weight: 500; margin-top: 4px; }
    .header-right { display: flex; align-items: center; gap: 20px; background: white; padding: 8px 16px; border-radius: 30px; box-shadow: var(--shadow); }
    .admin-profile { display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 14px; }
    .avatar { width: 36px; height: 36px; background: var(--secondary); border-radius: 50%; display: flex; justify-content: center; align-items: center; color: white; }

    /* --- KPI 카드 (Overview) --- */
    .overview-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
    .stat-card { background: var(--bg-card); padding: 24px; border-radius: var(--radius); box-shadow: var(--shadow); display: flex; align-items: center; gap: 20px; }
    .stat-icon-box { width: 56px; height: 56px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 24px; }
    .stat-info p { color: var(--text-muted); font-size: 14px; font-weight: 600; margin-bottom: 4px; }
    .stat-info h3 { font-size: 24px; font-weight: 800; }
    .stat-info span { font-size: 12px; font-weight: 700; color: var(--success); }

    /* --- 중간 위젯 그리드 --- */
    .widget-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
    .widget-card { background: var(--bg-card); padding: 24px; border-radius: var(--radius); box-shadow: var(--shadow); }
    .widget-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .widget-header h2 { font-size: 18px; font-weight: 800; }
    .btn-more { font-size: 13px; color: var(--primary); font-weight: 700; background: none; border: none; cursor: pointer; }

    /* 실시간 예약 순위 리스트 */
    .ranking-list li { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #F4F7FE; }
    .ranking-list li:last-child { border-bottom: none; }
    .rank-info { display: flex; align-items: center; gap: 12px; }
    .rank-num { font-size: 16px; font-weight: 900; color: var(--text-muted); width: 20px; }
    .rank-num.top { color: var(--primary); }
    .stay-name { font-size: 15px; font-weight: 700; }
    .stay-loc { font-size: 12px; color: var(--text-muted); }
    .booking-cnt { font-size: 14px; font-weight: 800; color: var(--success); background: #E6FFFA; padding: 4px 10px; border-radius: 8px; }

    /* 미답변 문의 리스트 */
    .cs-list li { padding: 14px 0; border-bottom: 1px solid #F4F7FE; display: flex; justify-content: space-between; align-items: center; }
    .cs-list li:last-child { border-bottom: none; padding-bottom: 0; }
    .cs-tag { font-size: 11px; font-weight: 800; background: #FFF5F5; color: var(--danger); padding: 4px 8px; border-radius: 6px; margin-bottom: 6px; display: inline-block; }
    .cs-tag.normal { background: #F4F7FE; color: var(--text-muted); }
    .cs-title { font-size: 14px; font-weight: 700; margin-bottom: 4px; }
    .cs-meta { font-size: 12px; color: var(--text-muted); }
    .btn-reply { background: var(--primary); color: white; border: none; padding: 8px 14px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; }
    .btn-reply:hover { background: #3210b3; }

    /* --- 하단 데이터 테이블 --- */
    .table-container { width: 100%; overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; text-align: left; }
    th { color: var(--text-muted); font-size: 13px; font-weight: 600; padding: 16px 12px; border-bottom: 1px solid #E9EDF7; }
    td { padding: 16px 12px; font-size: 14px; font-weight: 600; border-bottom: 1px solid #F4F7FE; }
    .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
    .status-badge.done { background: #E6FFFA; color: var(--success); }
    .status-badge.error { background: #FFF5F5; color: var(--danger); }
  </style>
</head>
<body>

<div class="app-container">
  
  <aside class="sidebar">
    <div class="brand">🚀 Tripan<span>Super</span></div>
    
    <div class="menu-title">Overview</div>
    <ul>
      <li class="nav-item active"><span class="nav-icon">📊</span> 대시보드</li>
      <li class="nav-item"><span class="nav-icon">📈</span> 통계 및 정산</li>
    </ul>

    <div class="menu-title">Management</div>
    <ul>
      <li class="nav-item"><span class="nav-icon">👥</span> 전체 회원 관리</li>
      <li class="nav-item"><span class="nav-icon">🏢</span> 파트너사 심사</li>
      <li class="nav-item"><span class="nav-icon">💳</span> 예약 및 결제 내역</li>
    </ul>

    <div class="menu-title">Service & CS</div>
    <ul>
      <li class="nav-item"><span class="nav-icon">💬</span> 1:1 문의 관리 (New)</li>
      <li class="nav-item"><span class="nav-icon">🚨</span> 커뮤니티 신고 관리</li>
      <li class="nav-item"><span class="nav-icon">⚙️</span> 시스템 API 상태</li>
    </ul>
  </aside>

  <main class="main-content">
    
    <div class="header">
      <div class="header-left">
        <h1>Overview</h1>
        <p>실시간 플랫폼 운영 상태와 핵심 지표를 확인하세요.</p>
      </div>
      <div class="header-right">
        <span style="font-size: 20px; cursor: pointer;">🔔<span style="color:var(--danger); font-size: 24px; line-height:0; position:relative; top:-5px;">.</span></span>
        <div class="admin-profile">
          <div class="avatar">M</div>
          Master Admin ▼
        </div>
      </div>
    </div>

    <div class="overview-grid">
      <div class="stat-card">
        <div class="stat-icon-box" style="background: #EBF4FF; color: var(--primary);">💰</div>
        <div class="stat-info">
          <p>총 거래액 (Total GMV)</p>
          <h3>₩ 125,400,000</h3>
          <span>+12.5% this month</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon-box" style="background: #E6FFFA; color: var(--success);">📈</div>
        <div class="stat-info">
          <p>총 영업이익 (수수료 수익)</p>
          <h3>₩ 11,286,000</h3>
          <span>+8.2% this month</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon-box" style="background: #FFF5F5; color: var(--danger);">🔥</div>
        <div class="stat-info">
          <p>월간 활성 사용자 (MAU)</p>
          <h3>45,120 명</h3>
          <span>+2.4% this month</span>
        </div>
      </div>
    </div>

    <div class="widget-grid">
      
      <div class="widget-card">
        <div class="widget-header">
          <h2>🔥 실시간 숙소 예약 랭킹</h2>
          <button class="btn-more">전체보기</button>
        </div>
        <ul class="ranking-list">
          <li>
            <div class="rank-info">
              <span class="rank-num top">1</span>
              <div>
                <div class="stay-name">아만 스위트 리저브</div>
                <div class="stay-loc">제주특별자치도</div>
              </div>
            </div>
            <div class="booking-cnt">124건 예약</div>
          </li>
          <li>
            <div class="rank-info">
              <span class="rank-num top">2</span>
              <div>
                <div class="stay-name">신라 더 파크 호텔</div>
                <div class="stay-loc">서울특별시 중구</div>
              </div>
            </div>
            <div class="booking-cnt">98건 예약</div>
          </li>
          <li>
            <div class="rank-info">
              <span class="rank-num top">3</span>
              <div>
                <div class="stay-name">루나 부티크 펜션</div>
                <div class="stay-loc">경상남도 남해군</div>
              </div>
            </div>
            <div class="booking-cnt">85건 예약</div>
          </li>
          <li>
            <div class="rank-info">
              <span class="rank-num">4</span>
              <div>
                <div class="stay-name">스테이 폴라리스</div>
                <div class="stay-loc">강원특별자치도 강릉시</div>
              </div>
            </div>
            <div class="booking-cnt">62건 예약</div>
          </li>
        </ul>
      </div>

      <div class="widget-card">
        <div class="widget-header">
          <h2>🚨 미답변 1:1 문의 <span style="color:var(--danger);">[3]</span></h2>
          <button class="btn-more">CS 이동</button>
        </div>
        <ul class="cs-list">
          <li>
            <div>
              <span class="cs-tag">결제/환불</span>
              <div class="cs-title">예약 취소했는데 환불이 안 들어왔어요.</div>
              <div class="cs-meta">user_1234 · 10분 전 접수</div>
            </div>
            <button class="btn-reply">답변하기</button>
          </li>
          <li>
            <div>
              <span class="cs-tag">숙소이용</span>
              <div class="cs-title">제주도 숙소 체크인 시간 변경 문의</div>
              <div class="cs-meta">traveler_kim · 45분 전 접수</div>
            </div>
            <button class="btn-reply">답변하기</button>
          </li>
          <li>
            <div>
              <span class="cs-tag normal">서비스개선</span>
              <div class="cs-title">N빵 정산할 때 카카오페이 연동 되나요?</div>
              <div class="cs-meta">happy_trip · 2시간 전 접수</div>
            </div>
            <button class="btn-reply">답변하기</button>
          </li>
        </ul>
      </div>

    </div>

    <div class="widget-card">
      <div class="widget-header">
        <h2>⚙️ API 및 시스템 상태 모니터링</h2>
      </div>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>시스템 명칭</th>
              <th>상태</th>
              <th>응답 속도 (ms)</th>
              <th>최근 점검일시</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Main DB Server (Oracle)</td>
              <td><span class="status-badge done">정상 작동</span></td>
              <td>12 ms</td>
              <td>2026-03-03 08:00</td>
              <td><button class="btn-more">로그확인</button></td>
            </tr>
            <tr>
              <td>Kakao Map API (지도/길찾기)</td>
              <td><span class="status-badge done">정상 작동</span></td>
              <td>45 ms</td>
              <td>2026-03-03 08:00</td>
              <td><button class="btn-more">로그확인</button></td>
            </tr>
            <tr>
              <td>PG 결제 모듈 연동</td>
              <td><span class="status-badge done">정상 작동</span></td>
              <td>120 ms</td>
              <td>2026-03-03 08:00</td>
              <td><button class="btn-more">로그확인</button></td>
            </tr>
            <tr>
              <td>Gemini AI API (일정생성)</td>
              <td><span class="status-badge error">지연 발생</span></td>
              <td>1,450 ms</td>
              <td>2026-03-03 09:01</td>
              <td><button class="btn-more" style="color:var(--danger);">오류해결</button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

  </main>
</div>

</body>
</html>