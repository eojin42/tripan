<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 회원 상세 정보</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

  <style>
    /* 1. 상단 프로필 영역 개선 */
    .profile-header-card { display: flex; gap: 32px; padding: 40px; align-items: center; background: #fff; border-radius: 24px; box-shadow: var(--shadow-sm); }
    .profile-img-lg { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg); box-shadow: var(--shadow-sm); flex-shrink: 0; }
    .profile-main-info h2 { font-size: 26px; font-weight: 900; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; }
    .profile-bio { color: var(--muted); font-size: 15px; margin-bottom: 24px; line-height: 1.6; }
    
    /* 통계 지표 클릭 영역 */
    .stat-badges { display: flex; gap: 32px; }
    .stat-item { display: flex; flex-direction: column; gap: 6px; cursor: pointer; padding: 10px; border-radius: 12px; transition: all 0.2s; margin-left: -10px; }
    .stat-item:hover { background: var(--bg); transform: translateY(-2px); }
    .stat-item .label { font-size: 12px; font-weight: 800; color: var(--muted); text-transform: uppercase; }
    .stat-item .value { font-size: 20px; font-weight: 900; font-family: var(--font-display); color: var(--text); }

    /* 2. 하단 2단 그리드 레이아웃 교정 */
    .detail-grid { display: grid; grid-template-columns: 360px 1fr; gap: 24px; margin-top: 24px; }
    @media (max-width: 1200px) { .detail-grid { grid-template-columns: 1fr; } }
    
    .card-pad { padding: 32px; background: #fff; border-radius: 24px; box-shadow: var(--shadow-sm); }
    .info-list { display: flex; flex-direction: column; gap: 20px; }
    .info-row dt { font-size: 12px; font-weight: 800; color: var(--muted); margin-bottom: 6px; }
    .info-row dd { font-size: 15px; font-weight: 700; color: var(--text); }

    /* 3. 🚨 예약 내역 검색 필터바 (이미지 레이아웃과 일치화) */
    .res-filter-container {
      display: flex; gap: 12px; margin-bottom: 24px; align-items: center; 
      background: #F8FAFC; padding: 16px 20px; border-radius: 16px; border: 1px solid var(--border);
    }
    .res-filter-container input[type="date"], 
    .res-filter-container select, 
    .res-filter-container input[type="text"] {
      height: 42px; border: 1px solid var(--border); border-radius: 10px; padding: 0 14px;
      font-size: 14px; font-weight: 600; background: #fff; outline: none; transition: border-color 0.2s;
    }
    .res-filter-container input:focus, .res-filter-container select:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .search-btn-black {
      height: 42px; padding: 0 24px; background: #000; color: #fff; border-radius: 10px; 
      font-weight: 800; border: none; cursor: pointer; transition: opacity 0.2s;
    }
    .search-btn-black:hover { opacity: 0.8; }

    /* 4. 🚨 예약 상세(영수증) 모달 디자인 가독성 강화 */
    .modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(8px); display: none; justify-content: center; align-items: center; z-index: 3000; }
    .modal-content { background: #fff; width: 780px; border-radius: 28px; box-shadow: var(--shadow-lg); overflow: hidden; animation: modalUp 0.4s cubic-bezier(0.16, 1, 0.3, 1); }
    @keyframes modalUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

    .receipt-body { padding: 48px; }
    .receipt-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 2px solid #000; }
    .receipt-header h2 { font-size: 26px; font-weight: 900; }
    
    .receipt-main { display: grid; grid-template-columns: 1.2fr 1fr; gap: 40px; }
    .r-section h4 { font-size: 14px; font-weight: 900; color: var(--muted); margin-bottom: 18px; text-transform: uppercase; letter-spacing: 1px; }
    
    .price-table { background: #F8FAFC; padding: 24px; border-radius: 16px; border: 1px solid var(--border); }
    .price-row { display: flex; justify-content: space-between; margin-bottom: 12px; font-weight: 700; color: var(--muted); }
    .price-total { display: flex; justify-content: space-between; margin-top: 16px; padding-top: 16px; border-top: 1px dashed var(--border); font-size: 18px; font-weight: 900; color: var(--primary); }
    
    .modal-actions { padding: 24px 48px; background: #fff; border-top: 1px solid var(--border); display: flex; gap: 12px; }
    .btn-full { flex: 1; height: 52px; border-radius: 14px; font-weight: 800; font-size: 15px; border: none; transition: transform 0.1s; }
    .btn-full:active { transform: scale(0.98); }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="members"/></jsp:include>
  
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">
      <div class="page-header fade-up">
        <div>
          <button class="btn btn-ghost btn-sm" onclick="history.back()" style="margin-bottom: 12px;">&larr; 목록으로 돌아가기</button>
          <h1>회원 상세 정보</h1>
        </div>
        <div class="header-actions">
          <button class="btn btn-primary" style="background:var(--danger)">🚨 즉시 활동 정지</button>
        </div>
      </div>

      <div class="card profile-header-card fade-up">
        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200" class="profile-img-lg">
        <div class="profile-main-info">
          <h2>취소왕박길동 <span class="badge" style="background:var(--bg); color:var(--text)">USER</span> <span class="badge badge-done">정상 활동</span></h2>
          <p class="profile-bio">"여행을 좋아하지만 귀찮아서 자꾸 취소하는 편입니다. 맛집 탐방을 제일 좋아해요!"</p>
          
          <div class="stat-badges">
            <div class="stat-item" onclick="openStatModal('follower')"><span class="label">팔로워 ↗</span><span class="value">128</span></div>
            <div class="stat-item" onclick="openStatModal('following')"><span class="label">팔로잉 ↗</span><span class="value">45</span></div>
            <div class="stat-item" onclick="openStatModal('badge')"><span class="label">획득 뱃지 ↗</span><span class="value">3개</span></div>
            <div class="stat-item" onclick="openStatModal('report')"><span class="label" style="color:var(--danger)">신고 누적 🚨</span><span class="value" style="color:var(--danger)">3회</span></div>
          </div>
        </div>
      </div>

      <div class="detail-grid fade-up">
        <div class="card-pad">
          <div class="w-header"><h2>👤 기본 정보</h2></div>
          <dl class="info-list">
            <div class="info-row"><dt>사용자 ID (이메일)</dt><dd>bad_user@naver.com</dd></div>
            <div class="info-row"><dt>전화번호</dt><dd>010-5555-6666</dd></div>
            <div class="info-row"><dt>선호 지역</dt><dd>제주특별자치도, 부산광역시</dd></div>
            <hr style="border:0; height:1px; background:var(--border); margin:10px 0;">
            <div class="info-row"><dt>가입 일시</dt><dd>2025-03-01 14:22:10</dd></div>
            <div class="info-row"><dt>마지막 수정 일시</dt><dd>2025-04-12 09:11:00</dd></div>
            <div class="info-row"><dt>최근 로그인 기록</dt><dd>2026-03-04 11:30 (IP: 121.1xx.xx.xx)</dd></div>
          </dl>
        </div>

        <div class="card-pad">
          <div class="w-header" style="margin-bottom: 20px;">
            <h2>🗓️ 전체 예약 내역</h2>
            <span style="font-size:13px; color:var(--muted)" id="resCount">총 8건 (취소 6건)</span>
          </div>

          <div class="res-filter-container">
            <input type="date" id="resStartDate" value="2026-03-05">
            <span style="color:var(--muted); font-weight:800;">~</span>
            <input type="date" id="resEndDate" value="2026-03-03">
            <select id="resSearchType">
              <option value="name">숙소명</option>
              <option value="id">예약번호</option>
            </select>
            <input type="text" id="resKeyword" placeholder="검색어 입력..." style="flex:1;">
            <button class="search-btn-black" onclick="filterReservations()">검색</button>
          </div>

          <div class="table-responsive">
            <table>
              <thead>
                <tr><th>예약 번호</th><th>숙소명</th><th>체크인/아웃</th><th>결제 금액</th><th>상태</th></tr>
              </thead>
              <tbody id="resTableBody">
              <c:forEach var="accom" items="${accomList}">
	                <tr style="cursor:pointer;" onclick="openResModal('${accom.resId}', '${accom.roomName}', '${accom.checkIn} ~ ${accom.checkOut}', '${accom.totalPrice}', '${accom.status}')" 
       					 data-status="${accom.status}" data-name="${accom.roomName}">
       					 
	                  <td style="color:var(--muted); font-weight:700;">#${accom.resId}</td>
	                  <td><strong>${accom.roomName}</strong></td>
	                  <td>${accom.checkIn} ~ ${accom.checkOut}</td>
	                  <td class="num">₩ ${accom.totalPrice}</td>
	                  <c:choose>
			            <c:when test="${accom.status == '예약 확정'}">
			                <span class="badge badge-done">${accom.status}</span>
			            </c:when>
			            <c:when test="${accom.status == '예약 취소'}">
			                <span class="badge badge-danger">${accom.status}</span>
			            </c:when>
			            <c:otherwise>
			                <span class="badge badge-wait">${accom.status}</span>
			            </c:otherwise>
			        </c:choose>
	                </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<div class="modal-overlay" id="resModal">
  <div class="modal-content">
    <div id="receiptArea" class="receipt-body">
      <div class="receipt-header">
        <div>
          <h2>예약 상세 정보</h2>
          <p style="color:var(--muted); font-size:15px; margin-top:8px;" id="md_orderId">주문번호: #BK-9921</p>
        </div>
        <span class="badge badge-done" id="md_status" style="padding: 8px 16px; font-size: 14px;">예약 확정</span>
      </div>
      
      <div class="receipt-main">
        <div class="r-section">
          <h4>🏨 예약 기본 정보</h4>
          <dl class="info-list" style="gap:16px;">
            <div class="info-row"><dt>숙소 및 객실명</dt><dd id="md_name">아만 스위트 리저브 - 오션뷰 스위트</dd></div>
            <div class="info-row"><dt>체크인 ~ 체크아웃</dt><dd id="md_date">2026-05-01 (15:00) ~ 2026-05-03 (11:00)</dd></div>
            <div class="info-row"><dt>숙박 인원</dt><dd>성인 2명 (guest_count: 2)</dd></div>
            <div class="info-row">
              <dt>고객 요청사항</dt>
              <dd style="background:#fff; border:1px solid var(--border); padding:12px; border-radius:8px; font-size:13px;">"결혼 기념일 여행입니다. 고층 객실로 배정 부탁드려요."</dd>
            </div>
          </dl>
        </div>

        <div class="r-section">
          <h4>💳 결제 상세 내역</h4>
          <div class="price-table">
            <div class="price-row"><span>총 예약 금액 (원가)</span><strong id="md_price">1,200,000 원</strong></div>
            <div class="price-row" style="color:var(--danger);"><span>쿠폰 할인액</span><strong>- 50,000 원</strong></div>
            <div class="price-total"><span>실제 결제 금액</span><strong id="md_realPrice">1,150,000 원</strong></div>
          </div>
          <dl class="info-list" style="gap:12px; margin-top:24px;">
            <div class="info-row"><dt>결제 수단</dt><dd>카카오페이 (pg_provider)</dd></div>
            <div class="info-row"><dt>결제 일시</dt><dd>2026-04-10 14:32:05</dd></div>
          </dl>
        </div>
      </div>
    </div>

    <div class="modal-actions">
      <button class="btn-full" style="background:var(--bg); color:var(--text);" onclick="closeResModal()">닫기</button>
      <button class="btn-full" style="background:#000; color:#fff;" onclick="downloadReceipt()">
        💾 결제 영수증 다운로드
      </button>
    </div>
  </div>
</div>

<script>
  // 모달 제어
  function openResModal(id, name, date, price, status) {
    document.getElementById('md_orderId').innerText = "주문번호: #" + id;
    document.getElementById('md_name').innerText = name;
    document.getElementById('md_date').innerText = date;
    document.getElementById('md_price').innerText = price + " 원";
    document.getElementById('md_status').innerText = status;
    document.getElementById('resModal').style.display = 'flex';
  }

  function closeResModal() { document.getElementById('resModal').style.display = 'none'; }

  // 📸 영수증 다운로드 (html2canvas 활용)
  function downloadReceipt() {
    const target = document.getElementById('receiptArea');
    html2canvas(target, { scale: 2, backgroundColor: '#ffffff' }).then(canvas => {
      const link = document.createElement('a');
      link.download = 'Tripan_영수증_' + new Date().getTime() + '.png';
      link.href = canvas.toDataURL('image/png');
      link.click();
    });
  }

  // 🔍 실시간 필터링 기능
  function filterReservations() {
    const keyword = document.getElementById('resKeyword').value.toLowerCase();
    const rows = document.querySelectorAll('#resTableBody tr');
    let count = 0;

    rows.forEach(row => {
      const name = row.getAttribute('data-name').toLowerCase();
      if (name.includes(keyword)) {
        row.style.display = '';
        count++;
      } else {
        row.style.display = 'none';
      }
    });
    document.getElementById('resCount').innerText = "검색 결과: " + count + "건";
  }

  // 모달 바깥 클릭 시 닫기
  window.onclick = function(e) { if(e.target.classList.contains('modal-overlay')) closeResModal(); }
</script>

</body>
</html>