<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="reqAdult" value="${empty param.adult ? 1 : param.adult}" />
<c:set var="reqChild" value="${empty param.child ? 0 : param.child}" />
<c:set var="totalReq" value="${reqAdult + reqChild}" />

<c:if test="${not empty param.checkin and not empty param.checkout}">
    <fmt:parseDate value="${param.checkin}" var="inDate" pattern="yyyy-MM-dd"/>
    <fmt:parseDate value="${param.checkout}" var="outDate" pattern="yyyy-MM-dd"/>
    <fmt:formatDate value="${inDate}" var="inStr" pattern="yyyy.MM.dd(E)"/>
    <fmt:formatDate value="${outDate}" var="outStr" pattern="yyyy.MM.dd(E)"/>
    
    <c:set var="diffTime" value="${outDate.time - inDate.time}" />
    <c:set var="nights" value="${diffTime / (1000 * 60 * 60 * 24)}" />
    <fmt:parseNumber var="nightCnt" value="${nights}" integerOnly="true" />
</c:if>

<jsp:include page="../layout/header.jsp" />

<style>
  /* 🌟 main.css의 회색 배경을 덮어쓰기 위해 컨테이너에 흰색 배경 적용 */
  .detail-page-wrapper {
    background-color: var(--bg-white, #ffffff);
    padding-top: 100px; /* 헤더 높이 확보 */
    padding-bottom: 100px;
    font-family: var(--font-sans);
  }

  .detail-container {
    max-width: 1060px;
    margin: 0 auto;
    padding: 0 20px;
  }
  
  /* 1. 상단 날짜/인원 요약바 */
  .top-summary-bar {
    display: flex; gap: 12px; margin-bottom: 24px; justify-content: flex-start;
  }
  .summary-badge {
    border: 1px solid var(--border-light, #E2E8F0);
    border-radius: 8px; padding: 12px 24px; font-size: 15px; font-weight: 700;
    color: var(--text-black); display: flex; align-items: center; gap: 8px; cursor: pointer;
  }
  .summary-badge .nights { color: #4A44F2; background: #EEEDFF; padding: 2px 6px; border-radius: 4px; font-size: 13px; font-weight: 800; }

  /* 2. 5분할 갤러리 (야놀자 스타일 비율) */
  .gallery-grid {
    display: grid; grid-template-columns: 2fr 1fr 1fr; grid-template-rows: 210px 210px; gap: 8px;
    border-radius: 16px; overflow: hidden; position: relative; margin-bottom: 40px;
  }
  .gallery-item { width: 100%; height: 100%; object-fit: cover; cursor: pointer; }
  .gallery-item:nth-child(1) { grid-row: 1 / span 2; }
  .btn-all-photos {
    position: absolute; bottom: 16px; right: 16px; background: rgba(255,255,255,0.9);
    border: 1px solid var(--border-light, #E2E8F0); padding: 8px 16px; border-radius: 8px;
    font-size: 14px; font-weight: 800; display: flex; align-items: center; gap: 6px; cursor: pointer;
  }

  /* 3. 2단 레이아웃 (좌측 정보 / 우측 쿠폰) */
  .info-layout { display: flex; gap: 40px; margin-bottom: 40px; align-items: flex-start; }
  .main-info { flex: 1; min-width: 0; }
  .side-info { width: 320px; flex-shrink: 0; }

  /* 타이틀 영역 */
  .title-area { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
  .acc-title { font-size: 28px; font-weight: 900; color: var(--text-black); margin-bottom: 8px; letter-spacing: -0.5px; }
  .acc-location { font-size: 15px; color: var(--text-dark); font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 4px; }
  .action-icons { display: flex; gap: 16px; font-size: 24px; color: var(--text-black); cursor: pointer; }

  /* 리뷰 박스 */
  .review-box { border: 1px solid var(--border-light, #E2E8F0); border-radius: 16px; padding: 24px; }
  .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
  .review-score { font-size: 22px; font-weight: 900; color: var(--text-black); }
  .review-score span { color: #FFA900; }
  .review-count { font-size: 15px; font-weight: 600; color: var(--text-gray); }
  
  .review-cards { display: flex; gap: 12px; overflow-x: auto; padding-bottom: 8px; }
  .review-cards::-webkit-scrollbar { display: none; }
  .r-card { background: #F8F9FA; border-radius: 12px; padding: 16px; min-width: 260px; }
  .r-stars { color: #FFA900; font-size: 13px; margin-bottom: 8px; display: flex; justify-content: space-between; }
  .r-date { color: var(--text-gray); font-size: 12px; }
  .r-text { font-size: 14px; color: var(--text-dark); line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }

  /* 사이드 쿠폰 박스 */
  .coupon-header { display: flex; justify-content: space-between; padding: 16px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 12px; font-weight: 800; font-size: 15px; margin-bottom: 12px; cursor: pointer; }
  .c-box { background: #FFF0F5; border-radius: 12px; padding: 16px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
  .c-box.beige { background: #FFF5EE; }
  .c-text { font-size: 14px; font-weight: 800; color: var(--text-black); }
  .btn-down { background: white; border: 1px solid #E2E8F0; border-radius: 6px; padding: 6px 10px; font-size: 12px; font-weight: 700; color: #4A44F2; cursor: pointer; }

  /* 4. 스티키 네비게이션 */
  .nav-tabs { 
    display: flex; gap: 24px; border-bottom: 1px solid var(--border-light, #E2E8F0); 
    position: sticky; top: 70px; background: var(--bg-white); z-index: 10; padding: 16px 0 0; margin-bottom: 32px;
  }
  .nav-tab { font-size: 16px; font-weight: 700; color: var(--text-gray); padding-bottom: 14px; cursor: pointer; }
  .nav-tab.active { color: #4A44F2; border-bottom: 2px solid #4A44F2; }

  /* 5. 객실 리스트 카드 (야놀자 완벽 구현) */
  .room-card { display: flex; gap: 24px; padding: 24px 0; border-bottom: 1px solid var(--border-light, #E2E8F0); }
  .room-img-box { width: 320px; height: 210px; border-radius: 12px; overflow: hidden; position: relative; flex-shrink: 0; }
  .room-img-badge { position: absolute; bottom: 8px; right: 8px; background: rgba(0,0,0,0.6); color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 700; }
  
  .room-details { flex: 1; display: flex; flex-direction: column; justify-content: space-between; }
  .room-name { font-size: 22px; font-weight: 900; color: var(--text-black); margin-bottom: 6px; }
  .room-desc { font-size: 14px; color: var(--text-dark); margin-bottom: 4px; }
  .room-capa { font-size: 13px; color: var(--text-gray); display: flex; align-items: center; gap: 4px; }
  
  .room-action-box { display: flex; justify-content: space-between; align-items: flex-end; border: 1px solid var(--border-light, #E2E8F0); border-radius: 12px; padding: 20px; margin-top: 16px; }
  .ra-left { display: flex; flex-direction: column; gap: 8px; }
  .ra-label { font-size: 15px; font-weight: 800; color: var(--text-black); }
  .ra-time { font-size: 14px; color: var(--text-dark); }
  .badge-special { background: #FFF0F5; color: #E53E3E; font-size: 11px; font-weight: 800; padding: 2px 6px; border-radius: 4px; display: inline-block; width: fit-content; }
  
  .ra-right { text-align: right; }
  .price-origin { font-size: 14px; color: var(--text-gray); text-decoration: line-through; margin-bottom: 2px; }
  .price-discount { font-size: 18px; font-weight: 900; color: #E53E3E; margin-right: 4px; }
  .price-final { font-size: 24px; font-weight: 900; color: var(--text-black); }
  .reward-text { font-size: 12px; color: var(--text-gray); margin: 4px 0 12px; }
  .reward-text span { color: #E53E3E; font-weight: 700; }
  
  .btn-group { display: flex; gap: 8px; justify-content: flex-end; }
  .btn-cart { width: 44px; height: 44px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; display: flex; justify-content: center; align-items: center; background: white; cursor: pointer; }
  .btn-reserve { background: #4A44F2; color: white; border: none; border-radius: 8px; padding: 0 32px; font-size: 16px; font-weight: 800; cursor: pointer; transition: background 0.2s; }
  .btn-reserve:hover { background: #3B36C2; }
  .cancel-info { font-size: 12px; color: var(--text-gray); margin-top: 8px; display: flex; align-items: center; gap: 4px; justify-content: flex-end; }
</style>

<div class="detail-page-wrapper">
  <div class="detail-container">

    <div class="top-summary-bar">
      <div class="summary-badge" onclick="openModal('date')">
        📅 
        <c:choose>
          <c:when test="${not empty param.checkin}">
            ${inStr} <span class="nights">${nightCnt}박</span> ${outStr}
          </c:when>
          <c:otherwise>
            일정을 선택해주세요
          </c:otherwise>
        </c:choose>
      </div>
      
      <div class="summary-badge" onclick="openModal('guest')">
        👤 성인 ${reqAdult}, 아동 ${reqChild}
      </div>
    </div>

    <div class="gallery-grid">
      <c:forEach var="img" items="${detail.images}" varStatus="status">
        <c:if test="${status.index < 5}">
          <img src="${img}" class="gallery-item" alt="숙소 이미지">
        </c:if>
      </c:forEach>
      <button class="btn-all-photos">📸 전체 사진 (116)</button>
    </div>

    <div class="info-layout">
      
      <div class="main-info">
        <div class="title-area">
          <div>
            <h1 class="acc-title">${detail.name}</h1>
            <div class="acc-location">📍 숙소 위치보기 > </div>
          </div>
          <div class="action-icons">
            <c:set var="svgFill" value="${detail.isBookmarked > 0 ? '#4A44F2' : 'none'}" />
            <c:set var="svgStroke" value="${detail.isBookmarked > 0 ? '#4A44F2' : 'currentColor'}" />
            
            <div class="wish-btn" onclick="toggleBookmark(event, ${detail.placeId}, this)" style="display:flex; align-items:center; cursor:pointer;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="${svgFill}" stroke="${svgStroke}" stroke-width="2">
                    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
            <span style="display:flex; align-items:center;">🔗</span>
          </div>
        </div>

        <div class="review-box">
          <div class="review-header">
            <div class="review-score"><span>★</span> 4.6 <span class="review-count">(70) 숙소답변(65)</span></div>
            <a style="font-size: 14px; font-weight: 700; color: var(--text-dark); text-decoration: underline; cursor:pointer;">전체보기</a>
          </div>
          
          <div class="review-cards">
            <div class="r-card">
              <div class="r-stars">★★★★★ <span class="r-date">2025.07.29</span></div>
              <div class="r-text">남친이랑 다녀갑니다. 숙소가 깔끔하고 사장님이 친절하셨어요~ 수영장 물은 깨끗했고 어메니티가 다...</div>
            </div>
            <div class="r-card">
              <div class="r-stars">★★★★★ <span class="r-date">2025.10.29</span></div>
              <div class="r-text">엄마 모시고 가는거라 수영장도 좋지만 스파 있는 곳을 찾았는데 릴리브 딱이더라구요!! 저는 스위밍풀...</div>
            </div>
            <div class="r-card">
              <div class="r-stars">★★★★★ <span class="r-date">2025.12.15</span></div>
              <div class="r-text">집기나 식기류가 잘 갖춰져 있어서 요리하기 편했어요. 저녁먹는데 펜션 뷰가 너무 예뻐서 힐링 제대로...</div>
            </div>
          </div>
        </div>
      </div>

      <div class="side-info">
        <div class="coupon-header">
          <span>🎫 쿠폰 마감</span>
          <span>></span>
        </div>
        <div class="c-box">
          <span class="c-text">봄 감성 펜션 특가 + 20% 쿠폰</span>
          <button class="btn-down">↓ 쿠폰받기</button>
        </div>
        <div class="c-box beige">
          <div>
            <div class="c-text">국내숙소 4만원 쿠폰 2장 제공!</div>
            <div style="font-size: 11px; color: var(--text-gray); margin-top:2px;">NOL 카드 이벤트</div>
          </div>
          <button class="btn-down">↓ 쿠폰받기</button>
        </div>
      </div>

    </div> <div class="nav-tabs">
      <div class="nav-tab active">객실선택</div>
      <div class="nav-tab">위치/교통</div>
      <div class="nav-tab">후기요약</div>
      <div class="nav-tab">숙소소개</div>
      <div class="nav-tab">시설/서비스</div>
      <div class="nav-tab">이용안내</div>
      <div class="nav-tab">예약공지</div>
    </div>

    <div>
      <c:forEach var="room" items="${detail.rooms}" varStatus="rStatus">
        
        <c:if test="${totalReq <= room.maxCapacity}">
          
          <c:set var="extraGuest" value="${totalReq - room.roomBaseCount}" />
          <c:if test="${extraGuest < 0}">
              <c:set var="extraGuest" value="0" />
          </c:if>
          <c:set var="finalPrice" value="${room.amount + (extraGuest * 20000)}" />
          
          <c:set var="originPrice" value="${finalPrice + 51900}" />

          <div class="room-card">
            <div class="room-img-box">
              <c:choose>
                <c:when test="${not empty room.roomImageUrl}">
                  <img src="${room.roomImageUrl}" alt="${room.roomName}" style="width:100%; height:100%; object-fit:cover;">
                </c:when>
                <c:otherwise>
                  <img src="https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600" alt="객실 기본이미지" style="width:100%; height:100%; object-fit:cover; filter: grayscale(80%);">
                </c:otherwise>
              </c:choose>
            </div>
            
            <div class="room-details">
              <div>
                <h3 class="room-name">${room.roomName}</h3>
                <p class="room-desc">복층/스위밍&제트스파/개별바베큐/2베드</p>
                <p class="room-capa">👤 기준 ${room.roomBaseCount}인 / 최대 ${room.maxCapacity}인</p>
              </div>
              
              <div class="room-action-box">
                <div class="ra-left">
                  <span class="ra-label">숙박 <span style="font-size:13px; font-weight:600; color:var(--text-gray); cursor:pointer; margin-left:8px;">상세보기 ></span></span>
                  <span class="ra-time">체크인 ${detail.checkinTime} ~ 체크아웃 ${detail.checkoutTime}</span>
                  <span class="badge-special">반짝특가</span>
                </div>
                
                <div class="ra-right">
                  <div class="price-origin">
                    <span class="price-discount">32%</span>
                    <fmt:formatNumber value="${originPrice}" pattern="#,###"/>원
                  </div>
                  <div class="price-final"><fmt:formatNumber value="${finalPrice}" pattern="#,###"/>원 ⓘ</div>
                  <div class="reward-text">NOL 머니 결제 시 <span>최대 2,142P 적립</span></div>
                  
                  <div class="btn-group">
                    <button class="btn-cart">
                      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
                    </button>
                    <button class="btn-reserve" onclick="goToReserve('${room.roomId}')">예약하기</button>
                  </div>
                  <div class="cancel-info">취소 및 환불 불가 ⓘ</div>
                </div>
              </div>
              
            </div>
          </div>

        </c:if>
      </c:forEach>
    </div>

  </div>
</div>

<script type="text/javascript">
window.toggleBookmark = function(event, placeId, btnElement) {
    event.stopPropagation(); 
    
    const isLoggedIn = ${not empty sessionScope.loginUser};
    if (!isLoggedIn) {
        alert("로그인이 필요한 서비스입니다.");
        location.href = '${pageContext.request.contextPath}/member/login';
        return; 
    }

    fetch('${pageContext.request.contextPath}/accommodation/bookmark', {
        method: 'POST', 
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ placeId: placeId })
    })
    .then(res => res.json())
    .then(data => {
        if (!data.success) {
            alert(data.message); return;
        }
        
        const svg = btnElement.querySelector('svg');
        if (data.isBookmarked) {
            svg.setAttribute('fill', '#4A44F2'); 
            svg.setAttribute('stroke', '#4A44F2');
        } else {
            svg.setAttribute('fill', 'none'); 
            svg.setAttribute('stroke', 'currentColor'); // 디테일은 검정색(currentColor) 유지
        }
    })
    .catch(err => console.error(err));
};

function goToReserve(roomId) {
    
    // JSP(JSTL)를 활용해 현재 로그인 유저가 있는지 브라우저 단에서 즉시 확인!
    const isLoggedIn = ${not empty sessionScope.loginUser};
    
    if (!isLoggedIn) {
        alert("로그인이 필요한 서비스입니다.");
        location.href = '${pageContext.request.contextPath}/member/login';
        return; 
    }

    const urlParams = new URLSearchParams(window.location.search);
    const checkin = urlParams.get('checkin') || '';
    const checkout = urlParams.get('checkout') || '';
    const adult = urlParams.get('adult') || '1';
    const child = urlParams.get('child') || '0';

    if (!checkin || !checkout) {
      alert("체크인 / 체크아웃 날짜를 먼저 선택해주세요!");
      return;
    }

    // 서버에 "나 이 방 5분만 잠가도 돼?" 하고 물어봄
    fetch('${pageContext.request.contextPath}/accommodation/check-lock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ roomId: roomId, checkin: checkin })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            // 락 허락 받으면 예약 폼으로 이동
            location.href = `${pageContext.request.contextPath}/accommodation/reservation?roomId=` + roomId 
                          + `&checkin=` + checkin + `&checkout=` + checkout 
                          + `&adult=` + adult + `&child=` + child;
        } else {
            // 락 거절 당하면 알림창
            alert(data.message);
        }
    })
    .catch(err => alert("서버 통신 오류가 발생했습니다."));
}
</script>

<jsp:include page="../accommodation/searchModal.jsp" />

<jsp:include page="../layout/footer.jsp" />