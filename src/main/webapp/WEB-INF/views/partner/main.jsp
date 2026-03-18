<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
       레이아웃 및 공통 스타일
    ========================================================= */
    .admin-layout { display: flex; height: 100vh; width: 100vw; overflow: hidden; background: #F0F2F8; }
    .main-wrapper { flex: 1; display: flex; flex-direction: column; min-width: 0; position: relative; }
    .top-header { position: relative !important; width: 100% !important; left: 0 !important; background: #FFF; border-bottom: 1px solid rgba(0,0,0,0.07); height: 72px; display: flex; align-items: center; padding: 0 40px; z-index: 1000; }
    .main-content { flex: 1; overflow-y: auto; padding: 32px 40px; }
    
    .page-section { display: none; animation: fadeUp .45s ease both; }
    .page-section.active { display: block; }
    @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }

    .card { background: #FFF; border-radius: 24px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid rgba(255,255,255,0.8); }
    .page-header { margin-bottom: 26px; }
    .page-header h1 { font-family: 'Sora', sans-serif; font-size: 24px; font-weight: 800; margin-bottom: 6px; }
    .page-header p { color: #8B92A5; font-size: 13px; }

    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
    .kpi-label { font-size: 12px; font-weight: 700; color: #8B92A5; margin-bottom: 8px; text-transform: uppercase; }
    .kpi-value { font-family: 'Sora', sans-serif; font-size: 28px; font-weight: 900; color: #0D1117; }
    .kpi-icon-wrap { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; background: rgba(59,110,248,0.1); }

    table { width: 100%; border-collapse: collapse; }
    th { padding: 14px 16px; font-size: 12px; font-weight: 700; color: #8B92A5; border-bottom: 2px solid rgba(0,0,0,0.07); text-align: left; }
    td { padding: 16px; border-bottom: 1px dashed rgba(0,0,0,0.07); font-size: 13px; font-weight: 600; }
    
    .badge { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; display: inline-flex; align-items: center; gap: 4px; }
    .badge-done { background: #ECFDF5; color: #10B981; }
    .badge-wait { background: #FEF3C7; color: #D97706; }

    .btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 100px; font-size: 13px; font-weight: 700; cursor: pointer; border: none; transition: 0.2s; }
    .btn-primary { background: #0D1117; color: white; }
    .btn-ghost { background: rgba(0,0,0,0.05); color: #0D1117; }
	
	 /* 세션만료 토스트알람 */     
    #toast-container {
      position: fixed;
      bottom: 24px;
      right: 24px;
      z-index: 99999;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .toast-msg {
      background: #0D1117; 
      color: #FFF;
      padding: 14px 24px;
      border-radius: 12px;
      font-size: 14px;
      font-weight: 700;
      box-shadow: 0 10px 25px rgba(0,0,0,0.15);
      opacity: 0;
      transform: translateY(20px);
      transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55); 
    }
    .toast-msg.show {
      opacity: 1;
      transform: translateY(0);
    }
    .toast-msg.error { background: #EF4444; } 
    .toast-msg.success { background: #10B981; } 
    
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
                  <%-- 임시 썸네일 (추후 객실별 이미지 업로드 구현 시 교체) --%>
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

      <div id="tab-calendar" class="page-section ${activeTab == 'calendar' ? 'active' : ''}">
        <div class="page-header">
          <h1>예약 캘린더</h1>
          <p>날짜별 객실 예약 현황을 한눈에 보고 판매를 관리하세요.</p>
        </div>
        <div class="card" style="text-align: center; padding: 60px;">
          <div style="font-size: 40px; margin-bottom: 20px;">📅</div>
          <h2 style="font-size: 18px; font-weight: 800; margin-bottom: 10px;">캘린더 기능 준비 중입니다</h2>
          <p style="color: var(--muted); font-size: 14px;">FullCalendar 라이브러리 연동 후 오픈될 예정입니다.</p>
        </div>
      </div>

	  <div id="tab-info" class="page-section ${activeTab == 'info' ? 'active' : ''}">
	    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
	      <div>
	        <h1>파트너 정보 관리</h1>
	        <p>플랫폼에 노출되는 숙소 소개글과 매월 정산받을 계좌 정보를 관리합니다.</p>
	      </div>
	      <button class="btn btn-primary" onclick="savePartnerInfo()">변경사항 저장</button>
	    </div>

	    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
	      
	      <div class="card" style="margin-bottom: 0;">
	        <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">👤 담당자 및 사업자 정보</h2>
	        
	        <div style="margin-bottom: 16px;">
	          <label>사업장명 (수정 불가)</label>
	          <input type="text" class="form-control" value="${partnerInfo.partnerName}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
	        </div>
	        
	        <div style="margin-bottom: 16px;">
	          <label>사업자등록번호 (수정 불가)</label>
	          <input type="text" class="form-control" value="${partnerInfo.businessNumber}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
	        </div>

	        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px;">
	          <div>
	            <label>담당자 이름</label>
	            <input type="text" id="contactName" class="form-control" value="${partnerInfo.contactName}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
	          </div>
	          <div>
	            <label>담당자 연락처</label>
	            <input type="text" id="contactPhone" class="form-control" value="${partnerInfo.contactPhone}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
	          </div>
	        </div>
	        
	        <div style="padding-top: 16px; border-top: 1px dashed var(--border);">
	          <h3 style="font-size: 14px; font-weight: 800; margin-bottom: 12px; color: var(--primary);">💰 정산 계좌 정보</h3>
	          <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 12px;">
	            <div>
	              <label>은행명</label>
				  <select id="bankName" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline: none;">
				    <option value="" disabled ${empty partnerInfo.bankName ? 'selected' : ''}>은행을 선택해주세요</option>
				    
				    <option value="국민" ${partnerInfo.bankName == '국민' ? 'selected' : ''}>KB국민은행</option>
				    <option value="신한" ${partnerInfo.bankName == '신한' ? 'selected' : ''}>신한은행</option>
				    <option value="우리" ${partnerInfo.bankName == '우리' ? 'selected' : ''}>우리은행</option>
				    <option value="하나" ${partnerInfo.bankName == '하나' ? 'selected' : ''}>하나은행</option>
				    <option value="농협" ${partnerInfo.bankName == '농협' ? 'selected' : ''}>NH농협은행</option>
				    <option value="기업" ${partnerInfo.bankName == '기업' ? 'selected' : ''}>IBK기업은행</option>
				    <option value="SC제일" ${partnerInfo.bankName == 'SC제일' ? 'selected' : ''}>SC제일은행</option>
				    <option value="씨티" ${partnerInfo.bankName == '씨티' ? 'selected' : ''}>한국씨티은행</option>
				    <option value="수협" ${partnerInfo.bankName == '수협' ? 'selected' : ''}>Sh수협은행</option>
				    
				    <option value="카카오뱅크" ${partnerInfo.bankName == '카카오뱅크' ? 'selected' : ''}>카카오뱅크</option>
				    <option value="토스뱅크" ${partnerInfo.bankName == '토스뱅크' ? 'selected' : ''}>토스뱅크</option>
				    <option value="케이뱅크" ${partnerInfo.bankName == '케이뱅크' ? 'selected' : ''}>케이뱅크</option>

				    <option value="대구" ${partnerInfo.bankName == '대구' ? 'selected' : ''}>DGB대구은행</option>
				    <option value="부산" ${partnerInfo.bankName == '부산' ? 'selected' : ''}>BNK부산은행</option>
				    <option value="경남" ${partnerInfo.bankName == '경남' ? 'selected' : ''}>BNK경남은행</option>
				    <option value="광주" ${partnerInfo.bankName == '광주' ? 'selected' : ''}>광주은행</option>
				    <option value="전북" ${partnerInfo.bankName == '전북' ? 'selected' : ''}>전북은행</option>
				    <option value="제주" ${partnerInfo.bankName == '제주' ? 'selected' : ''}>제주은행</option>
				    
				    <option value="새마을" ${partnerInfo.bankName == '새마을' ? 'selected' : ''}>새마을금고</option>
				    <option value="우체국" ${partnerInfo.bankName == '우체국' ? 'selected' : ''}>우체국예금</option>
				    <option value="신협" ${partnerInfo.bankName == '신협' ? 'selected' : ''}>신협</option>
				    <option value="저축은행" ${partnerInfo.bankName == '저축은행' ? 'selected' : ''}>저축은행</option>
				  </select>
	            </div>
	            <div>
	              <label>계좌번호 ( - 제외)</label>
	              <input type="text" id="accountNumber" class="form-control" value="${partnerInfo.accountNumber}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
	            </div>
	          </div>
	        </div>
	      </div>

	      <div class="card" style="margin-bottom: 0;">
	        <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">📢 숙소 소개글 (플랫폼 노출)</h2>
	        <div>
	          <label>공간 소개 및 컨셉</label>
	          <textarea id="partnerIntro" class="form-control" style="width:100%; height:300px; padding:12px; border:1px solid var(--border); border-radius:8px; resize:none;">${partnerInfo.partnerIntro}</textarea>
	        </div>
	      </div>

	    </div>
	  </div>

      <div id="tab-booking" class="page-section ${activeTab == 'booking' ? 'active' : ''}">
        <div class="page-header">
          <h1>예약 내역 관리</h1>
          <p>실시간 예약 현황을 확인하고 예약을 확정/취소합니다.</p>
        </div>
        <div class="card" style="padding: 0; overflow: hidden;">
          <table>
            <thead style="background: #F8FAFC;">
              <tr><th style="padding-left:24px;">예약번호</th><th>예약자</th><th>객실명</th><th>상태</th></tr>
            </thead>
            <tbody>
              <tr>
                <td style="padding-left:24px; font-weight:700;">RES-20261015-01</td>
                <td>김철수</td><td>오션뷰 프리미엄</td>
                <td><span class="badge badge-done">예약확정</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div id="tab-chat" class="page-section ${activeTab == 'chat' ? 'active' : ''}">
        <div class="page-header">
          <h1>고객 채팅</h1>
          <p>예약 고객과 실시간으로 1:1 메시지를 주고받을 수 있습니다.</p>
        </div>
        <div class="card" style="text-align: center; padding: 60px;">
          <div style="font-size: 40px; margin-bottom: 20px;">💬</div>
          <h2 style="font-size: 18px; font-weight: 800; margin-bottom: 10px;">채팅 시스템 준비 중입니다</h2>
          <p style="color: var(--muted); font-size: 14px;">WebSocket 연동 완료 후 활성화됩니다.</p>
        </div>
      </div>

      <div id="tab-review" class="page-section ${activeTab == 'review' ? 'active' : ''}">
        <div class="page-header"><h1>리뷰 관리</h1><p>고객님이 남겨주신 소중한 리뷰에 답글을 달아보세요.</p></div>
        <div class="card">
          <div style="display:flex; justify-content:space-between; margin-bottom:10px;">
            <span style="font-weight:800; color:#F59E0B;">★★★★★ 이영희 님</span>
          </div>
          <p style="font-size:14px; line-height:1.6;">정말 깨끗하고 뷰가 환상적이었어요!</p>
          <div style="margin-top:15px; background:#F8FAFC; padding:15px; border-radius:12px; border-left: 3px solid var(--primary);">
            <strong style="color:var(--primary); font-size:13px;">사장님 답변 완료</strong>
          </div>
        </div>
      </div>

	  <div id="tab-coupon" class="page-section ${activeTab == 'coupon' ? 'active' : ''}">
	          <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
	            <div>
	              <h1>쿠폰 마케팅</h1>
	              <p>우리 숙소 전용 할인 쿠폰을 직접 발행하고 관리하여 예약률을 높여보세요.</p>
	            </div>
	            <button class="btn btn-primary" onclick="openCouponModal()">+ 새 쿠폰 발행</button>
	          </div>

	          <div class="kpi-grid" style="grid-template-columns: repeat(3, 1fr);">
	            <div class="card" style="padding: 20px; margin-bottom: 0;">
	              <div class="kpi-label">발급 진행 중인 쿠폰</div>
	              <div class="kpi-value" style="color: var(--primary);">2건</div>
	            </div>
	            <div class="card" style="padding: 20px; margin-bottom: 0;">
	              <div class="kpi-label">이번 달 누적 다운로드</div>
	              <div class="kpi-value">145건</div>
	            </div>
	            <div class="card" style="padding: 20px; margin-bottom: 0;">
	              <div class="kpi-label">이번 달 실제 사용(결제)</div>
	              <div class="kpi-value" style="color: #10B981;">32건</div>
	            </div>
	          </div>

	          <div class="card" style="padding: 0; overflow: hidden; margin-top: 24px;">
	            <table>
	              <thead style="background: #F8FAFC;">
	                <tr>
	                  <th style="padding-left: 24px;">쿠폰명</th>
	                  <th>할인 혜택</th>
	                  <th>사용 조건</th>
	                  <th>유효 기간</th>
	                  <th>상태</th>
	                  <th style="text-align: center; padding-right: 24px;">관리</th>
	                </tr>
	              </thead>
	              <tbody>
	                <tr>
	                  <td style="padding-left: 24px; font-weight: 800;">🍂 가을 맞이 깜짝 할인</td>
	                  <td><span style="color: var(--danger); font-weight: 900; font-family:'Sora', sans-serif;">₩ 5,000</span></td>
	                  <td style="color: var(--muted); font-size: 12px;">50,000원 이상 결제 시</td>
	                  <td style="font-size: 12px; font-weight: 700;">26.09.01 ~ 26.10.31</td>
	                  <td><span class="badge badge-done">발급중</span></td>
	                  <td style="text-align: center; padding-right: 24px;">
	                    <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px;">발급 중지</button>
	                  </td>
	                </tr>
	                
	                <tr>
	                  <td style="padding-left: 24px; font-weight: 800;">🌊 오션뷰 객실 프로모션</td>
	                  <td>
	                    <span style="color: var(--danger); font-weight: 900; font-family:'Sora', sans-serif;">10%</span> 
	                    <span style="font-size:11px; color:var(--muted);">(최대 2만원)</span>
	                  </td>
	                  <td style="color: var(--muted); font-size: 12px;">조건 없음</td>
	                  <td style="font-size: 12px; font-weight: 700;">26.10.01 ~ 26.12.31</td>
	                  <td><span class="badge badge-done">발급중</span></td>
	                  <td style="text-align: center; padding-right: 24px;">
	                    <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px;">발급 중지</button>
	                  </td>
	                </tr>

	                <tr>
	                  <td style="padding-left: 24px; font-weight: 700; color: var(--muted);">🏖️ 여름 성수기 얼리버드</td>
	                  <td style="color: var(--muted); font-family:'Sora', sans-serif;">₩ 10,000</td>
	                  <td style="color: var(--muted); font-size: 12px;">100,000원 이상 결제 시</td>
	                  <td style="color: var(--muted); font-size: 12px;">26.06.01 ~ 26.08.31</td>
	                  <td><span class="badge" style="background:#F1F5F9; color:#64748B;">기간만료</span></td>
	                  <td style="text-align: center; padding-right: 24px;">
	                    <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px; text-decoration: line-through;" disabled>종료됨</button>
	                  </td>
	                </tr>
	              </tbody>
	            </table>
	          </div>
	        </div>

      <div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
        <div class="page-header"><h1>정산 내역</h1><p>매월 발생한 매출과 정산 금액을 확인합니다.</p></div>
        <div class="card" style="padding:0; overflow:hidden;">
          <table>
            <thead>
              <tr><th style="padding-left:24px;">정산월</th><th>총 매출</th><th>실 지급액</th><th>상태</th></tr>
            </thead>
            <tbody>
              <tr>
                <td style="padding-left:24px;">2026년 09월</td><td>₩ 5,000,000</td><td style="font-weight:900;">₩ 4,500,000</td>
                <td><span class="badge badge-done">지급완료</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <div id="tab-stats" class="page-section ${activeTab == 'stats' ? 'active' : ''}">
        <div class="page-header"><h1>매출 통계</h1><p>기간별, 객실별 매출 데이터를 상세하게 분석합니다.</p></div>
        <div class="card" style="text-align: center; padding: 60px;">
          <h2 style="font-size: 18px; font-weight: 800;">통계 분석 준비 중입니다</h2>
        </div>
      </div>

      <div id="tab-tax" class="page-section ${activeTab == 'tax' ? 'active' : ''}">
        <div class="page-header"><h1>세무 자료 관리</h1><p>부가세 신고 및 세금계산서 발행 내역을 관리합니다.</p></div>
        <div class="card" style="text-align: center; padding: 60px;">
          <h2 style="font-size: 18px; font-weight: 800;">세무 기능 준비 중입니다</h2>
        </div>
      </div>

      <div id="tab-notice" class="page-section ${activeTab == 'notice' ? 'active' : ''}">
        <div class="page-header"><h1>공지사항</h1><p>Tripan 플랫폼의 중요 정책 및 업데이트 소식을 확인하세요.</p></div>
        <div class="card">
          <h2 style="font-size: 16px; font-weight: 800; margin-bottom:10px;">[안내] 10월 파트너스 데이 진행 안내</h2>
          <p style="color:var(--muted); font-size:13px;">2026.09.25 등록됨</p>
        </div>
      </div>

      <div id="tab-settings" class="page-section ${activeTab == 'settings' ? 'active' : ''}">
        <div class="page-header"><h1>계정 설정</h1><p>파트너 로그인 계정 및 알림 설정을 변경합니다.</p></div>
        <div class="card">
          <button class="btn btn-ghost" style="color: var(--danger);">파트너 탈퇴 요청</button>
        </div>
      </div>

    </main>
  </div>
</div>

<div class="modal-overlay" id="roomModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(2px); z-index: 9999; display: none; align-items: center; justify-content: center;">
  <div class="modal-content" style="width: 600px; max-height: 90vh; overflow-y: auto; background: white; border-radius: 16px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
    <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
      <div>
        <h2 style="margin: 0; font-size: 20px; font-weight: 800;">🛏️ 새 객실 등록</h2>
        <p style="font-size: 13px; color: var(--muted); margin: 4px 0 0;">판매하실 객실의 상세 정보를 입력해주세요.</p>
      </div>
      <button onclick="closeRoomModal()" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #8B92A5;">✕</button>
    </div>
    
    <div class="modal-body">
      <form id="roomForm">
        <div style="margin-bottom: 16px;">
          <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">객실 이름 (room_name)</label>
          <input type="text" class="form-control" placeholder="예: 오션뷰 스위트룸" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
        </div>
        
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 16px;">
          <div>
            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">기준 인원 (roombasecount)</label>
            <input type="number" class="form-control" value="2" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
          </div>
          <div>
            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">최대 인원 (max_capacity)</label>
            <input type="number" class="form-control" value="4" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
          </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 24px;">
          <div>
            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">보유 객실 수 (room_count)</label>
            <input type="number" class="form-control" value="10" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
          </div>
          <div>
            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">기본 요금 (amount)</label>
            <input type="number" class="form-control" placeholder="예: 150000" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
          </div>
        </div>

        <div style="margin-bottom: 24px;">
          <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">객실 소개 (roomintro)</label>
          <textarea class="form-control" style="width:100%; height:80px; padding:10px; border:1px solid var(--border); border-radius:8px; resize:none; outline:none;"></textarea>
        </div>

        <div style="display: flex; gap: 10px; justify-content: flex-end;">
          <button type="button" class="btn btn-ghost" onclick="closeRoomModal()">취소</button>
          <button type="button" class="btn btn-primary" onclick="saveRoom()">저장하기</button>
        </div>
      </form>
    </div>
  </div>
</div>

<div class="modal-overlay" id="cancelModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(2px); z-index: 9999; display: none; align-items: center; justify-content: center;">
  <div class="modal-content" style="width: 400px; background: white; border-radius: 16px; padding: 24px;">
    <h2 style="margin: 0 0 10px 0; font-size: 18px; color: var(--danger);">🚨 예약 강제 취소</h2>
    <p style="font-size: 13px; color: var(--muted); margin-bottom: 20px;">부득이한 사유로 예약을 취소합니다. 고객에게 알림이 발송됩니다.</p>
    <textarea id="cancelReason" class="form-control" placeholder="취소 사유를 입력해주세요." style="width: 100%; height: 80px; padding: 10px; border: 1px solid var(--border); border-radius: 8px; resize: none; outline: none; margin-bottom: 20px;"></textarea>
    <div style="display: flex; gap: 10px; justify-content: flex-end;">
      <button class="btn btn-ghost" onclick="closeCancelModal()">닫기</button>
      <button class="btn btn-primary" style="background: var(--danger);" onclick="submitCancel()">취소 확정</button>
    </div>
  </div>
</div>
	
	<div class="modal-overlay" id="couponModal">
	  <div class="modal-content" style="width: 500px;">
	    <div class="modal-header">
	      <h2 style="margin-top: 0;">🎫 새 쿠폰 발행</h2>
	      <p style="font-size: 13px; color: var(--muted); margin-bottom: 24px;">우리 숙소 고객들에게 제공할 혜택을 설정하세요.</p>
	    </div>
	    <div class="modal-body">
	      <form id="couponForm">
	        <div style="margin-bottom: 16px;">
	          <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">쿠폰 이름 (coupon_name)</label>
	          <input type="text" class="form-control" placeholder="예: 겨울 맞이 5천원 할인" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	        </div>
	        
	        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 16px;">
	          <div>
	            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">할인 유형 (discount_type)</label>
	            <select class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	              <option value="FIXED">정액 할인 (원)</option>
	              <option value="PERCENT">정률 할인 (%)</option>
	            </select>
	          </div>
	          <div>
	            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">할인 금액/비율</label>
	            <input type="number" class="form-control" placeholder="예: 5000 또는 10" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	          </div>
	        </div>

	        <div style="margin-bottom: 16px;">
	          <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">최소 결제 금액 (min_order_amount)</label>
	          <input type="number" class="form-control" placeholder="예: 50000 (조건 없을 시 0)" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	        </div>

	        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 24px;">
	          <div>
	            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">발급 시작일 (valid_from)</label>
	            <input type="date" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	          </div>
	          <div>
	            <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">발급 종료일 (valid_until)</label>
	            <input type="date" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
	          </div>
	        </div>

	        <div style="display: flex; gap: 10px; justify-content: flex-end;">
	          <button type="button" class="btn btn-ghost" onclick="closeCouponModal()">취소</button>
	          <button type="button" class="btn btn-primary" onclick="alert('쿠폰이 성공적으로 발행되었습니다!'); closeCouponModal();">발행하기</button>
	        </div>
	      </form>
	    </div>
	  </div>
	</div>

</body>
</html>