<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="reqAdult" value="${empty param.adult ? 1 : param.adult}" />
<c:set var="reqChild" value="${empty param.child ? 0 : param.child}" />
<c:set var="totalReq" value="${reqAdult + reqChild}" />

<c:if test="${not empty param.checkin and not empty param.checkout}">
    <fmt:parseDate value="${param.checkin}" var="inDate" pattern="yyyy-MM-dd"/>
    <fmt:parseDate value="${param.checkout}" var="outDate" pattern="yyyy-MM-dd"/>
    
    <fmt:formatDate value="${inDate}" var="inBoxStr" pattern="M.d."/>
    <fmt:formatDate value="${outDate}" var="outBoxStr" pattern="M.d."/>
    
    <c:set var="diffTime" value="${outDate.time - inDate.time}" />
    <c:set var="nights" value="${diffTime / (1000 * 60 * 60 * 24)}" />
    <fmt:parseNumber var="nightCnt" value="${nights}" integerOnly="true" />
</c:if>

<c:set var="calcNights" value="${empty nightCnt ? 1 : nightCnt}" />

<jsp:include page="../layout/header.jsp" />

<style>
  .detail-page-wrapper {
    background-color: var(--bg-white, #ffffff);
    padding-top: 100px; padding-bottom: 120px;
    font-family: var(--font-sans);
  }

  .detail-container { max-width: 1100px; margin: 0 auto; padding: 0 20px; }

  /* --- 1. 이미지 캐러셀 --- */
  .carousel-wrapper { position: relative; width: 100%; height: 500px; overflow: hidden; border-radius: 8px; margin-bottom: 50px; background: #eee; }
  .carousel-track { display: flex; transition: transform 0.4s ease-in-out; height: 100%; }
  .carousel-slide { min-width: 100%; height: 100%; object-fit: cover; }
  
  .carousel-btn { position: absolute; top: 50%; transform: translateY(-50%); background: rgba(0,0,0,0.3); color: white; border: none; width: 48px; height: 48px; border-radius: 50%; cursor: pointer; display: flex; justify-content: center; align-items: center; font-size: 20px; transition: background 0.2s; z-index: 10; }
  .carousel-btn:hover { background: rgba(0,0,0,0.6); }
  .carousel-prev { left: 20px; }
  .carousel-next { right: 20px; }

  .carousel-counter { position: absolute; bottom: 20px; right: 20px; background: rgba(0,0,0,0.6); color: white; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 700; z-index: 10; letter-spacing: 2px; }

  /* --- 2. 2단 분할 레이아웃 --- */
  .content-split { display: flex; gap: 60px; align-items: flex-start; }
  .main-content { flex: 1; min-width: 0; }
  
  /* --- 3. 좌측 메인 정보 헤더 (업그레이드) --- */
  .title-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; }
  .title-left { display: flex; flex-direction: column; }
  .acc-title { font-size: 32px; font-weight: 900; color: var(--text-black); margin-bottom: 8px; line-height: 1.2; }
  .acc-location { font-size: 15px; color: var(--text-gray); font-weight: 600; margin-bottom: 12px; }
  
  /* 🌟 총 북마크 & 리뷰 개수 라인 */
  .acc-stats { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 700; color: var(--text-black); }
  .acc-stats .stat-item { display: flex; align-items: center; gap: 4px; }
  .review-link { text-decoration: underline; text-underline-offset: 4px; cursor: pointer; transition: color 0.2s; color: var(--text-black); }
  .review-link:hover { color: var(--point-blue); }

  /* 공유 & 찜 아이콘 우측 정렬 */
  .action-icons { display: flex; gap: 16px; align-items: center; }
  .icon-btn { display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text-black); transition: transform 0.2s; }
  .icon-btn:hover { transform: translateY(-2px); }

  /* --- 🌟 스티키 네비게이션 (클래스명 충돌 방지: .detail-tab) --- */
  .sticky-nav { position: sticky; top: 70px; background: rgba(255,255,255,0.95); backdrop-filter: blur(5px); z-index: 50; display: flex; gap: 24px; border-bottom: 1px solid var(--border-light, #E2E8F0); padding: 16px 0 0; margin-bottom: 40px; }
  /* 헤더와 겹치지 않게 배경 transparent, 패딩 수정 */
  .sticky-nav a.detail-tab { text-decoration: none; color: var(--text-gray); font-size: 15px; font-weight: 600; padding: 0 4px 14px; transition: color 0.2s; background: transparent; border-radius: 0; }
  .sticky-nav a.detail-tab:hover { color: var(--text-black); background: transparent; }
  .sticky-nav a.detail-tab.active { color: var(--text-black); font-weight: 800; border-bottom: 2px solid var(--text-black); margin-bottom: -1px; }

  /* 섹션 공통 스타일 */
  .scroll-section { padding-top: 90px; margin-top: -50px; margin-bottom: 60px; }
  .section-title { font-size: 22px; font-weight: 800; color: var(--text-black); margin-bottom: 24px; }
  .intro-text { font-size: 15px; line-height: 1.6; color: var(--text-dark); margin-bottom: 24px; }

  /* 객실 리스트 카드 */
  .room-info-card { display: flex; gap: 24px; padding: 24px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; margin-bottom: 16px; transition: box-shadow 0.2s; }
  .room-info-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
  .room-info-img { width: 220px; height: 150px; border-radius: 8px; object-fit: cover; flex-shrink: 0; }
  .room-info-text { flex: 1; display: flex; flex-direction: column; justify-content: center; }
  .ri-name { font-size: 20px; font-weight: 800; color: var(--text-black); margin-bottom: 8px; }
  .ri-capa { font-size: 14px; color: var(--text-gray); margin-bottom: 12px; }
  .ri-price { font-size: 18px; font-weight: 800; color: var(--point-blue); margin-top: auto; }
  .btn-select-room { align-self: flex-end; padding: 8px 16px; background: var(--text-black); color: white; border: none; border-radius: 4px; font-size: 14px; font-weight: 700; cursor: pointer; }

  /* --- 4. 우측 스티키 예약 박스 --- */
  .sticky-sidebar { width: 380px; flex-shrink: 0; position: sticky; top: 100px; }
  .reserve-box { border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; padding: 32px 24px; background: white; box-shadow: 0 10px 30px rgba(0,0,0,0.03); }
  
  .reserve-tabs { display: flex; border: 1px solid var(--border-light, #E2E8F0); border-radius: 4px; margin-bottom: 24px; }
  .reserve-tab { flex: 1; text-align: center; padding: 14px 0; font-size: 15px; font-weight: 700; color: var(--text-dark); cursor: pointer; display: flex; justify-content: center; align-items: center; gap: 8px; }
  .reserve-tab:first-child { border-right: 1px solid var(--border-light, #E2E8F0); }
  .reserve-tab:hover { background: #F8F9FA; }

  /* 선택된 객실 표시 트리거 */
  .sel-room-trigger { display: flex; align-items: center; gap: 16px; padding: 16px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 4px; cursor: pointer; margin-bottom: 24px; transition: border 0.2s; }
  .sel-room-trigger:hover { border-color: var(--text-black); }
  .sel-room-img { width: 56px; height: 56px; border-radius: 4px; object-fit: cover; background: #eee; }
  .sel-room-text { flex: 1; }
  .sel-room-name { font-size: 16px; font-weight: 800; color: var(--text-black); margin-bottom: 4px; }
  .sel-room-capa { font-size: 13px; color: var(--text-gray); }
  .sel-room-arrow { color: var(--text-gray); font-size: 20px; font-weight: 300; }

  /* 가격 계산 영역 */
  .calc-area { background: #F8F9FA; border-radius: 4px; padding: 20px; margin-bottom: 24px; }
  .calc-row { display: flex; justify-content: space-between; font-size: 14px; color: var(--text-dark); margin-bottom: 16px; }
  .calc-row:last-child { margin-bottom: 0; border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 16px; font-weight: 800; color: var(--text-black); }
  .calc-total-val { font-size: 20px; font-weight: 900; }

  .btn-reserve-submit { width: 100%; background: var(--text-black); color: white; border: none; padding: 18px 0; font-size: 16px; font-weight: 800; border-radius: 4px; cursor: pointer; transition: background 0.3s; }
  .btn-reserve-submit:hover { background: var(--point-blue); }

  /* --- 5. 객실 선택 모달 (유지) --- */
  .rm-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9990; opacity: 0; visibility: hidden; transition: all 0.3s; }
  .rm-overlay.open { opacity: 1; visibility: visible; }
  .rm-modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -40%); width: 100%; max-width: 500px; background: white; border-radius: 12px; z-index: 9999; opacity: 0; visibility: hidden; transition: all 0.3s; display: flex; flex-direction: column; max-height: 80vh; }
  .rm-modal.open { transform: translate(-50%, -50%); opacity: 1; visibility: visible; }
  .rm-header { padding: 20px 24px; border-bottom: 1px solid var(--border-light, #E2E8F0); display: flex; justify-content: space-between; align-items: center; font-size: 18px; font-weight: 800; }
  .rm-close { cursor: pointer; font-size: 24px; color: var(--text-gray); }
  .rm-body { padding: 20px 24px; overflow-y: auto; display: flex; flex-direction: column; gap: 16px; }
  .rm-item { display: flex; gap: 16px; padding: 16px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; cursor: pointer; transition: all 0.2s; }
  .rm-item:hover, .rm-item.selected { border-color: var(--text-black); background: #F8F9FA; }
  .rm-item img { width: 80px; height: 80px; border-radius: 4px; object-fit: cover; }
  .rm-item-info { display: flex; flex-direction: column; justify-content: center; flex: 1; }
  .rm-i-name { font-size: 16px; font-weight: 800; color: var(--text-black); margin-bottom: 4px; }
  .rm-i-capa { font-size: 13px; color: var(--text-gray); margin-bottom: 8px; }
  .rm-i-price { font-size: 15px; font-weight: 800; color: var(--point-blue); }
  
  /* 🌟 태그 스타일 */
  .acc-tags { display: flex; gap: 8px; margin-bottom: 32px; }
  .acc-tag { background: #F5F7FA; color: var(--text-dark); padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 600; }

  /* 🌟 쿠폰 영역 스타일 */
  .coupon-section {
      display: flex; justify-content: space-between; align-items: center;
      padding: 20px 0; margin-bottom: 40px;
      border-top: 1px solid var(--border-light, #E2E8F0);
      border-bottom: 1px solid var(--border-light, #E2E8F0);
  }
  .coupon-info { display: flex; align-items: center; gap: 40px; }
  .coupon-label { font-size: 15px; font-weight: 800; color: var(--text-black); }
  .coupon-desc { font-size: 14px; font-weight: 500; color: var(--text-dark); }
  
  .btn-download-coupon {
      display: flex; align-items: center;
      background: var(--text-black); color: white;
      border: none; padding: 10px 16px; border-radius: 4px;
      font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.2s;
  }
  .btn-download-coupon:hover { background: var(--point-blue); transform: translateY(-2px); }

  @media (max-width: 992px) {
    .content-split { flex-direction: column; }
    .sticky-sidebar { width: 100%; position: static; }
  }
  
  /* 편의시설 그리드 스타일 추가 */
  .facility-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-top: 16px; }
  .facility-item { display: flex; align-items: center; gap: 10px; font-size: 15px; color: var(--text-black); }
  .facility-item i { font-size: 20px; color: var(--text-gray); width: 24px; text-align: center; }
  .fac-emoji { font-size: 22px; }

  /* 주변 상권 요약 박스 스타일 */
  .nearby-summary-box { background: #F8F9FA; padding: 16px 20px; border-radius: 8px; margin-top: 16px; display: flex; align-items: center; gap: 12px; font-size: 14px; font-weight: 600; color: var(--point-blue); border: 1px solid #E6F4FF; }
  
  @media (max-width: 768px) {
    .facility-grid { grid-template-columns: repeat(2, 1fr); }
  }
</style>

<div class="detail-page-wrapper">
  <div class="detail-container">

    <div class="carousel-wrapper">
      <div class="carousel-track" id="carouselTrack">
        
        <c:if test="${not empty detail.imageUrl}">
            <c:set var="mainImgStr" value="${fn:startsWith(detail.imageUrl, 'http') ? detail.imageUrl : pageContext.request.contextPath += detail.imageUrl}" />
            <img src="${mainImgStr}" class="carousel-slide" alt="메인 썸네일 이미지" onerror="this.src='https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1100'">
        </c:if>

        <c:if test="${not empty detail.images}">
            <c:forEach var="img" items="${detail.images}">
                <c:if test="${img ne detail.imageUrl}">
                    <c:set var="finalImgStr" value="${fn:startsWith(img, 'http') ? img : pageContext.request.contextPath += img}" />
                    <img src="${finalImgStr}" class="carousel-slide" alt="숙소 상세 이미지" onerror="this.src='https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1100'">
                </c:if>
            </c:forEach>
        </c:if>

      </div>
      
      <button class="carousel-btn carousel-prev" id="c-btn-prev" onclick="moveCarousel(-1)">&#10094;</button>
      <button class="carousel-btn carousel-next" id="c-btn-next" onclick="moveCarousel(1)">&#10095;</button>
      
      <div class="carousel-counter"><span id="c-curr">1</span> / <span id="c-total">1</span></div>
    </div>

    <div class="content-split">
      
      <div class="main-content">
        
        <div class="title-header">
          <div class="title-left">
            <h1 class="acc-title">${detail.name}</h1>
            <p class="acc-location">${detail.region}</p>
            
            <div class="acc-stats">
              <span class="stat-item">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path></svg>
                5,744
              </span>
              <a href="#sec-reviews" class="review-link detail-tab">후기 10개</a>
            </div>
          </div>

          <div class="action-icons">
            <div class="icon-btn" onclick="copyShareUrl()" title="공유하기">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path><polyline points="16 6 12 2 8 6"></polyline><line x1="12" y1="2" x2="12" y2="15"></line></svg>
            </div>
            <c:set var="svgFill" value="${detail.isBookmarked > 0 ? '#4A44F2' : 'none'}" />
            <c:set var="svgStroke" value="${detail.isBookmarked > 0 ? '#4A44F2' : 'currentColor'}" />
            <div class="icon-btn" onclick="toggleBookmark(event, ${detail.placeId}, this)" title="북마크">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="${svgFill}" stroke="${svgStroke}" stroke-width="2">
                    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
          </div>
        </div>
        
        <div class="acc-tags">
            <span class="acc-tag">사색</span>
            <span class="acc-tag">도심 속 휴식</span>
        </div>

        <div class="coupon-section">
            <div class="coupon-info">
                <span class="coupon-label">쿠폰</span>
                <span class="coupon-desc">1개 쿠폰 사용 가능</span>
            </div>
            <button class="btn-download-coupon" onclick="downloadCoupon()">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:6px;">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line>
                </svg>
                쿠폰 받기
            </button>
        </div>

        <div class="sticky-nav" id="stickyNav">
            <a href="#sec-intro" class="detail-tab active">스테이 소개</a>
            <a href="#sec-rooms" class="detail-tab">객실 선택</a>
            <a href="#sec-reviews" class="detail-tab">리뷰</a>
            <a href="#sec-info" class="detail-tab">위치 및 정보</a>
            <a href="#sec-notice" class="detail-tab">안내사항</a>
        </div>

        <div id="sec-intro" class="scroll-section">
            <h3 class="section-title">${detail.description != null ? detail.description : '숙소에 대한 설명이 없습니다.'}</h3>
        </div>
        
        <div id="sec-facilities" class="scroll-section">
		    <h3 class="section-title">편의시설</h3>
		    <div class="facility-grid">
		        <c:if test="${detail.fitness == 1}">
		            <div class="facility-item"><span class="fac-emoji">🏋️‍♂️</span> 체력단련장</div>
		        </c:if>
		        <c:if test="${detail.chkcooking == 1}">
		            <div class="facility-item"><span class="fac-emoji">🍳</span> 취사 가능</div>
		        </c:if>
		        <c:if test="${detail.barbecue == 1}">
		            <div class="facility-item"><span class="fac-emoji">🍖</span> 바비큐</div>
		        </c:if>
		        <c:if test="${detail.beverage == 1}">
		            <div class="facility-item"><span class="fac-emoji">☕</span> 식음료/조식</div>
		        </c:if>
		        <c:if test="${detail.karaoke == 1}">
		            <div class="facility-item"><span class="fac-emoji">🎤</span> 노래방</div>
		        </c:if>
		        <c:if test="${detail.publicpc == 1}">
		            <div class="facility-item"><span class="fac-emoji">💻</span> 공용 PC</div>
		        </c:if>
		        <c:if test="${detail.sauna == 1}">
		            <div class="facility-item"><span class="fac-emoji">♨️</span> 사우나</div>
		        </c:if>
		    </div>
		</div>

        <div id="sec-rooms" class="scroll-section">
            <h3 class="section-title">객실 선택</h3>
            <div class="room-list">
              <c:forEach var="room" items="${detail.rooms}">
                
                <c:set var="extraGuest" value="${totalReq - room.roomBaseCount}" />
                <c:if test="${extraGuest < 0}"><c:set var="extraGuest" value="0" /></c:if>
                <c:set var="finalPrice" value="${room.amount + (extraGuest * 20000)}" />
                <c:set var="totalPrice" value="${finalPrice * calcNights}" />
                <c:set var="imgUrl" value="${not empty room.roomImageUrl ? room.roomImageUrl : 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'}" />

                <c:set var="isCapacityExceeded" value="${totalReq > room.maxCapacity}" />

				<div class="room-info-card" 
				     <c:if test="${room.available and !isCapacityExceeded}">
				        onclick="selectRoom('${room.roomId}', '${fn:escapeXml(room.roomName)}', '${imgUrl}', '${room.roomBaseCount}', '${room.maxCapacity}', '<fmt:formatNumber value="${finalPrice}"/>', '<fmt:formatNumber value="${totalPrice}"/>')"
				     </c:if>
				     <c:if test="${!room.available}">
				        style="opacity: 0.6; cursor: not-allowed; background-color: #f8f9fa;" title="선택하신 날짜에는 예약이 마감된 객실입니다."
				     </c:if>
				     <c:if test="${room.available and isCapacityExceeded}">
				        style="opacity: 0.6; cursor: not-allowed; background-color: #f8f9fa;" title="최대 수용 인원을 초과하여 선택할 수 없습니다."
				     </c:if>>
				  
				  <img src="${imgUrl}" class="room-info-img" alt="${room.roomName}">
				  <div class="room-info-text">
				    <h4 class="ri-name">${room.roomName}</h4>
				    <p class="ri-capa">
				        기준 ${room.roomBaseCount}명 / 최대 ${room.maxCapacity}명 
				        <c:choose>
				            <c:when test="${not empty param.checkin and not empty param.checkout}">
				                <span style="color:#E53E3E; font-weight:800; margin-left:8px;">(남은 객실: ${room.remainingCount}개)</span>
				            </c:when>
				            <c:otherwise>
				                <span style="color:var(--text-gray); margin-left:8px;">(총 객실: ${room.roomCount}개)</span>
				            </c:otherwise>
				        </c:choose>
				    </p>
				    <div class="ri-price">₩<fmt:formatNumber value="${finalPrice}" pattern="#,###"/>~ <span style="font-size:13px; font-weight:500; color:#718096;">/박</span></div>
				  </div>
				  
				  <c:choose>
				    <c:when test="${!room.available}">
				        <button class="btn-select-room" style="background:#A0AEC0; cursor:not-allowed;" disabled>예약 마감</button>
				    </c:when>
				    <c:when test="${isCapacityExceeded}">
				        <button class="btn-select-room" style="background:#F56565; color:white; cursor:not-allowed;" disabled>인원 초과</button>
				    </c:when>
				    <c:otherwise>
				        <button class="btn-select-room">객실 선택</button>
				    </c:otherwise>
				  </c:choose>
				</div>
              </c:forEach>
            </div>
        </div>

        <div id="sec-reviews" class="scroll-section">
            <h3 class="section-title">방문자 리뷰</h3>
            <p class="intro-text" style="color:var(--text-gray);">아직 작성된 리뷰가 없습니다. 첫 리뷰의 주인공이 되어보세요!</p>
        </div>

        <div id="sec-info" class="scroll-section">
		    <h3 class="section-title">위치 및 정보</h3>
		    <p class="intro-text" style="margin-bottom:12px;">📍 ${detail.region}</p>
		    
		    <div id="map" style="width:100%; height:350px; border-radius:8px; margin-bottom:16px;"></div>
		    <div id="nearbySummary" class="nearby-summary-box">
		        <div class="spinner-border spinner-border-sm text-primary" role="status"></div>
		        <span>주변 편의시설 정보를 불러오는 중입니다...</span>
		    </div>
		</div>

        <div id="sec-notice" class="scroll-section">
            <h3 class="section-title">안내사항</h3>
            <p class="intro-text">
               🕒 체크인: ${detail.checkinTime} <br>
               🕛 체크아웃: ${detail.checkoutTime} <br>
               🚗 주차 : ${detail.parkinglodging} <br>
               ⚠️ 객실 내 흡연 및 반려동물 동반은 엄격히 금지되어 있습니다.
            </p>
        </div>

      </div>

      <div class="sticky-sidebar">
        <div class="reserve-box">
          <div class="reserve-tabs">
            <div class="reserve-tab" onclick="openModal('date')">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right:4px;"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              <c:choose>
                <c:when test="${not empty param.checkin}">${inBoxStr} - ${outBoxStr}</c:when>
                <c:otherwise>일정 수정</c:otherwise>
              </c:choose>
            </div>
            <div class="reserve-tab" onclick="openModal('guest')">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right:4px;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              인원 ${totalReq}명
            </div>
          </div>

          <div class="sel-room-trigger" onclick="openRoomModal()">
            <img src="" id="s-room-img" class="sel-room-img" style="display:none;">
            <div class="sel-room-text">
              <div id="s-room-name" class="sel-room-name" style="font-size:18px;">객실을 선택해주세요</div>
              <div id="s-room-capa" class="sel-room-capa"></div> 
            </div>
            <div class="sel-room-arrow">∨</div>
          </div>

          <div class="calc-area">
            <div class="calc-row">
              <span>객실 요금</span>
              <span id="s-price-calc">₩0 * <fmt:formatNumber value="${calcNights}" maxFractionDigits="0"/>박</span>
            </div>
            <div class="calc-row">
              <span>총액</span>
              <span class="calc-total-val" id="s-price-total">₩0</span>
            </div>
          </div>

          <button class="btn-reserve-submit" onclick="submitReservation()">예약하기</button>
        </div>
      </div>

    </div>
  </div>
</div>

<div class="rm-overlay" id="rmOverlay" onclick="closeRoomModal()"></div>
<div class="rm-modal" id="rmModal">
  <div class="rm-header">
    객실 선택
    <span class="rm-close" onclick="closeRoomModal()">✕</span>
  </div>
  <div class="rm-body" id="rmBody">
    <c:forEach var="room" items="${detail.rooms}">
      <c:set var="extraGuest" value="${totalReq - room.roomBaseCount}" />
      <c:if test="${extraGuest < 0}"><c:set var="extraGuest" value="0" /></c:if>
      <c:set var="finalPrice" value="${room.amount + (extraGuest * 20000)}" />
      <c:set var="totalPrice" value="${finalPrice * calcNights}" />
      <c:set var="imgUrl" value="${not empty room.roomImageUrl ? room.roomImageUrl : 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'}" />

      <div class="rm-item" id="rm-item-${room.roomId}" 
	     <c:if test="${room.available}">
	        onclick="selectRoom('${room.roomId}', '${fn:escapeXml(room.roomName)}', '${imgUrl}', '${room.roomBaseCount}', '${room.maxCapacity}', '<fmt:formatNumber value="${finalPrice}"/>', '<fmt:formatNumber value="${totalPrice}"/>')"
	     </c:if>
	     <c:if test="${!room.available}">
	        style="opacity: 0.5; pointer-events: none; background-color: #f8f9fa;"
	     </c:if>>
	     
	  <img src="${imgUrl}" alt="${room.roomName}">
	  <div class="rm-item-info">
	    <div class="rm-i-name">${room.roomName}</div>
	    <div class="rm-i-capa">
	        기준 ${room.roomBaseCount}명 (최대 ${room.maxCapacity}명)
	        <c:choose>
	            <c:when test="${not empty param.checkin and not empty param.checkout}">
	                <span style="color:#E53E3E; font-weight:800; margin-left:4px;">| 남은 객실: ${room.remainingCount}개</span>
	            </c:when>
	            <c:otherwise>
	                <span style="color:var(--text-gray); margin-left:4px;">| 총 객실: ${room.roomCount}개</span>
	            </c:otherwise>
	        </c:choose>
	    </div>
	    <div class="rm-i-price">₩<fmt:formatNumber value="${finalPrice}" pattern="#,###"/>~ <span style="font-size:12px; font-weight:500; color:var(--text-gray);">/박</span></div>
	  </div>
	  
	  <c:if test="${!room.available}">
	      <span style="color:#E53E3E; font-size:14px; font-weight:800; align-self:center; margin-left:auto; padding-right:10px;">마감</span>
	  </c:if>
	</div>
    </c:forEach>
  </div>
</div>

<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoApiKey}&libraries=services"></script>

<script type="text/javascript">
// 마감 날짜 => JS 배열
window.disabledDates = [
    <c:forEach var="date" items="${bookedDates}" varStatus="status">
        '${date}'${!status.last ? ',' : ''}
    </c:forEach>
];

//--- 1. 슬라이더 (캐러셀) 자바스크립트 ---
let currentSlide = 0;
let slides = [];
let totalSlides = 0;

document.addEventListener("DOMContentLoaded", () => {
    slides = document.querySelectorAll('.carousel-slide');
    totalSlides = slides.length;
    
    document.getElementById('c-total').innerText = totalSlides;
    
    if (totalSlides <= 1) {
        document.getElementById('c-btn-prev').style.display = 'none';
        document.getElementById('c-btn-next').style.display = 'none';
    }
});

function moveCarousel(direction) {
    if(totalSlides <= 1) return;
    
    currentSlide += direction;
    if (currentSlide < 0) currentSlide = totalSlides - 1;
    if (currentSlide >= totalSlides) currentSlide = 0;
    
    document.getElementById('carouselTrack').style.transform = `translateX(-\${currentSlide * 100}%)`;
    document.getElementById('c-curr').innerText = currentSlide + 1;
}

// --- 2. 스크롤 스파이 (네비게이션 연동) 
window.addEventListener('scroll', () => {
    let current = '';
    const sections = document.querySelectorAll('.scroll-section');
    const navLinks = document.querySelectorAll('.detail-tab'); 
    
    sections.forEach(sec => {
        const sectionTop = sec.offsetTop;
        if (pageYOffset >= sectionTop - 150) {
            current = sec.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href').includes(current)) {
            link.classList.add('active');
        }
    });
});

// 스무스 스크롤 (클릭 시 부드럽게 이동)
document.querySelectorAll('.detail-tab').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const targetId = this.getAttribute('href');
        const targetSection = document.querySelector(targetId);
        window.scrollTo({
            top: targetSection.offsetTop - 80,
            behavior: 'smooth'
        });
    });
});

// --- 🌟 링크 복사(공유) 기능 ---
function copyShareUrl() {
    navigator.clipboard.writeText(window.location.href).then(() => {
        alert('숙소 링크가 복사되었습니다!');
    }).catch(err => {
        console.error('링크 복사 실패:', err);
    });
}

// --- 3. 북마크 비동기 통신 ---
window.toggleBookmark = function(event, placeId, btnElement) {
    event.stopPropagation(); 
    const isLoggedIn = ${not empty sessionScope.loginUser};
    if (!isLoggedIn) {
        alert("로그인이 필요한 서비스입니다.");
        location.href = '${pageContext.request.contextPath}/member/login';
        return; 
    }
    fetch('${pageContext.request.contextPath}/accommodation/bookmark', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ placeId: placeId })
    })
    .then(res => res.json())
    .then(data => {
        if (!data.success) { alert(data.message); return; }
        const svg = btnElement.querySelector('svg');
        if (data.isBookmarked) {
            svg.setAttribute('fill', '#4A44F2'); svg.setAttribute('stroke', '#4A44F2');
        } else {
            svg.setAttribute('fill', 'none'); svg.setAttribute('stroke', 'currentColor'); 
        }
    }).catch(err => console.error(err));
};

// --- 4. 우측 객실 선택 로직 ---
let currentSelectedRoomId = null;

function openRoomModal() {
    document.getElementById('rmOverlay').classList.add('open');
    document.getElementById('rmModal').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeRoomModal() {
    document.getElementById('rmOverlay').classList.remove('open');
    document.getElementById('rmModal').classList.remove('open');
    document.body.style.overflow = '';
}

function selectRoom(roomId, name, img, baseCapa, maxCapa, priceStr, totalStr) {
    currentSelectedRoomId = roomId;

    const imgEl = document.getElementById('s-room-img');
    imgEl.src = img;
    imgEl.style.display = 'block';
    
    document.getElementById('s-room-name').innerText = name;
    
    if(baseCapa && maxCapa) {
        document.getElementById('s-room-capa').innerText = `기준 \${baseCapa}명 (최대 \${maxCapa}명)`;
    }
    
    const nights = Math.floor(${calcNights});
    document.getElementById('s-price-calc').innerText = `₩\${priceStr} * \${nights}박`;
    document.getElementById('s-price-total').innerText = `₩\${totalStr}`;

    closeRoomModal();
}

document.addEventListener("DOMContentLoaded", () => {
    const firstRoom = document.querySelector('.rm-item');
    if (firstRoom) firstRoom.click(); 
});

// --- 5. 예약하기 로직 ---
function submitReservation() {
    if (!currentSelectedRoomId) {
        alert("객실을 먼저 선택해주세요.");
        return openRoomModal();
    }
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

    fetch('${pageContext.request.contextPath}/accommodation/check-lock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ roomId: currentSelectedRoomId, checkin: checkin, checkout: checkout })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            location.href = `${pageContext.request.contextPath}/accommodation/reservation?roomId=` + currentSelectedRoomId 
                          + `&checkin=` + checkin + `&checkout=` + checkout 
                          + `&adult=` + adult + `&child=` + child;
        } else {
            alert(data.message);
        }
    }).catch(err => alert("서버 통신 오류가 발생했습니다."));
}

function downloadCoupon() {
    const isLoggedIn = ${not empty sessionScope.loginUser};
    if (!isLoggedIn) {
        alert("로그인이 필요한 서비스입니다.");
        location.href = '${pageContext.request.contextPath}/member/login';
        return; 
    }
    
    // 2. 추후 백엔드(Fetch API)와 연결할 부분
    // 백엔드 쿠폰 테이블에 INSERT 처리 후 성공하면 알림을 띄우는 로직이 들어갑니다.
    alert("쿠폰이 발급되었습니다! 예약 결제 시 사용 가능합니다. 🎉");
}

document.addEventListener("DOMContentLoaded", () => {
    const lat = ${detail.latitude};
    const lng = ${detail.longitude};
    
    if (lat && lng) {
        const mapContainer = document.getElementById('map');
        const locPosition = new kakao.maps.LatLng(lat, lng);
        
        const mapOption = { 
            center: locPosition, 
            level: 4 // 확대 레벨
        };

        // 지도 생성 및 마커 표시
        const map = new kakao.maps.Map(mapContainer, mapOption);
        const marker = new kakao.maps.Marker({ position: locPosition });
        marker.setMap(map);

        // 장소 검색 객체 생성
        const ps = new kakao.maps.services.Places(map); 

        // 검색할 카테고리: 편의점(CS2), 약국(PM9), 대형마트(MT1)
        const searchCategories = ['CS2', 'PM9', 'MT1'];
        const categoryNames = { 'CS2': '편의점', 'PM9': '약국', 'MT1': '대형마트' };
        let results = [];
        let completedReqs = 0;

        searchCategories.forEach(code => {
            ps.categorySearch(code, function(data, status, pagination) {
                if (status === kakao.maps.services.Status.OK) {
                    if (pagination.totalCount > 0) {
                        results.push(`\${categoryNames[code]} \${pagination.totalCount}개`);
                    }
                }
                
                completedReqs++;
                
                // 3가지 검색이 모두 끝났을 때 텍스트 렌더링
                if (completedReqs === searchCategories.length) {
                    const summaryEl = document.getElementById('nearbySummary');
                    if (results.length > 0) {
                        summaryEl.innerHTML = `<i class="bi bi-info-circle-fill"></i> 도보 5분(500m) 거리 내 <strong>\${results.join(', ')}</strong>가 있습니다.`;
                    } else {
                        summaryEl.innerHTML = `<i class="bi bi-info-circle"></i> 반경 500m 내에 검색된 주요 편의시설이 없습니다.`;
                    }
                }
            }, {
                location: locPosition,
                radius: 500 // 반경 500m
            });
        });
    } else {
        document.getElementById('map').style.display = 'none';
        document.getElementById('nearbySummary').style.display = 'none';
    }
});

//최근 본 숙소 localStorage 저장
function saveRecentAccom() {
    try {
        const recent = {
            accommodationId: '${detail.placeId}',
            accommodationName: '${detail.name}',
            address: '${detail.region}',
            thumbnailUrl: '${detail.imageUrl}',
            viewedAt: new Date().toISOString()
        };

        const raw = localStorage.getItem('tripan_recent_stays');
        let list = raw ? JSON.parse(raw) : [];

        // 중복 제거
        list = list.filter(x => x.accommodationId != recent.accommodationId);
        // 맨 앞에 추가
        list.unshift(recent);
        // 최대 10개만 유지
        if (list.length > 10) list = list.slice(0, 10);

        localStorage.setItem('tripan_recent_stays', JSON.stringify(list));
    } catch(e) {}
}
saveRecentAccom();
</script>

<jsp:include page="../accommodation/searchModal.jsp">
    <jsp:param name="hideRegion" value="true" />
</jsp:include>

<jsp:include page="../layout/footer.jsp" />