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
  /* (기존 메인 스타일 유지) */
  .detail-page-wrapper { background-color: var(--bg-white, #ffffff); padding-top: 100px; padding-bottom: 120px; font-family: var(--font-sans); }
  .detail-container { max-width: 1100px; margin: 0 auto; padding: 0 20px; }
  
  /* 메인 이미지 캐러셀 */
  .carousel-wrapper { position: relative; width: 100%; height: 500px; overflow: hidden; border-radius: 8px; margin-bottom: 50px; background: #eee; }
  .carousel-track { display: flex; transition: transform 0.4s ease-in-out; height: 100%; }
  .carousel-slide { min-width: 100%; height: 100%; object-fit: cover; cursor: pointer; transition: opacity 0.2s; }
  .carousel-slide:hover { opacity: 0.9; } 
  .carousel-btn { position: absolute; top: 50%; transform: translateY(-50%); background: rgba(0,0,0,0.3); color: white; border: none; width: 48px; height: 48px; border-radius: 50%; cursor: pointer; display: flex; justify-content: center; align-items: center; font-size: 20px; transition: background 0.2s; z-index: 10; }
  .carousel-btn:hover { background: rgba(0,0,0,0.6); }
  .carousel-prev { left: 20px; }
  .carousel-next { right: 20px; }
  .carousel-counter { position: absolute; bottom: 20px; right: 20px; background: rgba(0,0,0,0.6); color: white; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 700; z-index: 10; letter-spacing: 2px; }

  /* 🌟 수정: 전체사진 갤러리 모달 Z-INDEX 상승 (객실 모달 위로 올라오게 20000으로 설정) */
  .photo-modal { display: none; position: fixed; z-index: 20000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.9); }
  .photo-modal.open { display: flex; justify-content: center; align-items: center; flex-direction: column; }
  .photo-modal .modal-content { margin: auto; display: block; width: 100%; max-width: 1000px; max-height: 80vh; object-fit: contain; }
  .photo-modal .close-modal { position: absolute; top: 20px; right: 40px; color: #f1f1f1; font-size: 40px; font-weight: bold; transition: 0.3s; cursor: pointer; z-index: 20010; }
  .photo-modal .prev, .photo-modal .next { cursor: pointer; position: absolute; top: 50%; width: auto; padding: 16px; margin-top: -50px; color: white; font-weight: bold; font-size: 24px; transition: 0.3s ease; user-select: none; z-index: 20010; }
  .photo-modal .prev { left: 40px; }
  .photo-modal .next { right: 40px; }
  .photo-modal .prev:hover, .photo-modal .next:hover { background-color: rgba(0, 0, 0, 0.8); }
  .photo-modal .modal-index { color: white; font-size: 16px; position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%); z-index: 20010; letter-spacing: 2px;}

  /* 레이아웃 & 텍스트 공통 */
  .content-split { display: flex; gap: 60px; align-items: flex-start; }
  .main-content { flex: 1; min-width: 0; }
  .title-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; }
  .title-left { display: flex; flex-direction: column; }
  .acc-title { font-size: 32px; font-weight: 900; color: var(--text-black); margin-bottom: 8px; line-height: 1.2; }
  .acc-location { font-size: 15px; color: var(--text-gray); font-weight: 600; margin-bottom: 12px; }
  .acc-stats { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 700; color: var(--text-black); }
  .acc-stats .stat-item { display: flex; align-items: center; gap: 4px; }
  .review-link { text-decoration: underline; text-underline-offset: 4px; cursor: pointer; transition: color 0.2s; color: var(--text-black); }
  .review-link:hover { color: var(--point-blue); }
  .action-icons { display: flex; gap: 16px; align-items: center; }
  .icon-btn { display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text-black); transition: transform 0.2s; }
  .icon-btn:hover { transform: translateY(-2px); }

  /* 네비게이션 & 섹션 */
  .sticky-nav { position: sticky; top: 70px; background: rgba(255,255,255,0.95); backdrop-filter: blur(5px); z-index: 50; display: flex; gap: 24px; border-bottom: 1px solid var(--border-light, #E2E8F0); padding: 16px 0 0; margin-bottom: 40px; }
  .sticky-nav a.detail-tab { text-decoration: none; color: var(--text-gray); font-size: 15px; font-weight: 600; padding: 0 4px 14px; transition: color 0.2s; background: transparent; border-radius: 0; }
  .sticky-nav a.detail-tab:hover { color: var(--text-black); background: transparent; }
  .sticky-nav a.detail-tab.active { color: var(--text-black); font-weight: 800; border-bottom: 2px solid var(--text-black); margin-bottom: -1px; }
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
  .btn-room-detail-view { background: white; color: var(--text-dark); border: 1px solid #CBD5E0; padding: 8px 16px; border-radius: 4px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s; }
  .btn-room-detail-view:hover { background: #F8F9FA; border-color: var(--text-black); color: var(--text-black); }
  .btn-select-room { padding: 8px 16px; background: var(--text-black); color: white; border: none; border-radius: 4px; font-size: 14px; font-weight: 700; cursor: pointer; }

  /* 🌟 객실 상세보기 모달용 CSS 🌟 */
  .rd-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 10050; opacity: 0; visibility: hidden; transition: all 0.3s; backdrop-filter: blur(2px); }
  .rd-overlay.open { opacity: 1; visibility: visible; }
  .rd-modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -40%); width: 90%; max-width: 600px; background: white; border-radius: 16px; z-index: 10060; opacity: 0; visibility: hidden; transition: all 0.3s; display: flex; flex-direction: column; max-height: 85vh; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
  .rd-modal.open { transform: translate(-50%, -50%); opacity: 1; visibility: visible; }
  .rd-header { padding: 20px 24px; border-bottom: 1px solid #E2E8F0; display: flex; justify-content: space-between; align-items: center; font-size: 18px; font-weight: 800; }
  .rd-close { cursor: pointer; font-size: 24px; color: var(--text-gray); transition: color 0.2s; }
  .rd-close:hover { color: var(--text-black); }
  .rd-body { overflow-y: auto; display: flex; flex-direction: column; }
  
  /* 🌟 객실 상세 모달 캐러셀(슬라이더) 전용 스타일 */
  .rd-img-container { width: 100%; height: 300px; background: #eee; position: relative; overflow: hidden; }
  .rd-carousel-track { display: flex; transition: transform 0.3s ease-in-out; height: 100%; }
  .rd-carousel-slide { min-width: 100%; height: 100%; object-fit: cover; cursor: pointer; transition: opacity 0.2s; }
  .rd-carousel-slide:hover { opacity: 0.9; }
  .rd-carousel-btn { position: absolute; top: 50%; transform: translateY(-50%); background: rgba(0,0,0,0.3); color: white; border: none; width: 36px; height: 36px; border-radius: 50%; cursor: pointer; display: flex; justify-content: center; align-items: center; font-size: 16px; z-index: 10; transition: background 0.2s; }
  .rd-carousel-btn:hover { background: rgba(0,0,0,0.6); }
  .rd-prev { left: 16px; }
  .rd-next { right: 16px; }
  .rd-carousel-counter { position: absolute; bottom: 16px; right: 16px; background: rgba(0,0,0,0.6); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 700; z-index: 10; letter-spacing: 1px; }

  /* 객실 상세 텍스트 */
  .rd-content { padding: 24px; }
  .rd-title { font-size: 22px; font-weight: 900; color: var(--text-black); margin-bottom: 8px; }
  .rd-capa { font-size: 14px; color: var(--text-gray); margin-bottom: 16px; }
  .rd-intro { font-size: 15px; color: var(--text-dark); line-height: 1.6; margin-bottom: 24px; background: #F8F9FA; padding: 16px; border-radius: 8px; }
  .rd-fac-title { font-size: 16px; font-weight: 800; color: var(--text-black); margin-bottom: 16px; padding-bottom: 8px; border-bottom: 2px solid var(--text-black); display: inline-block; }
  .rd-fac-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  .rd-fac-item { display: flex; align-items: center; gap: 8px; font-size: 14px; color: var(--text-dark); font-weight: 600; }
  .rd-fac-icon { font-size: 18px; }

  /* 우측 예약 박스 및 기타 */
  .sticky-sidebar { width: 380px; flex-shrink: 0; position: sticky; top: 100px; }
  .reserve-box { border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; padding: 32px 24px; background: white; box-shadow: 0 10px 30px rgba(0,0,0,0.03); }
  .reserve-tabs { display: flex; border: 1px solid var(--border-light, #E2E8F0); border-radius: 4px; margin-bottom: 24px; }
  .reserve-tab { flex: 1; text-align: center; padding: 14px 0; font-size: 15px; font-weight: 700; color: var(--text-dark); cursor: pointer; display: flex; justify-content: center; align-items: center; gap: 8px; }
  .reserve-tab:first-child { border-right: 1px solid var(--border-light, #E2E8F0); }
  .reserve-tab:hover { background: #F8F9FA; }
  .sel-room-trigger { display: flex; align-items: center; gap: 16px; padding: 16px; border: 1px solid var(--border-light, #E2E8F0); border-radius: 4px; cursor: pointer; margin-bottom: 24px; transition: border 0.2s; }
  .sel-room-trigger:hover { border-color: var(--text-black); }
  .sel-room-img { width: 56px; height: 56px; border-radius: 4px; object-fit: cover; background: #eee; }
  .sel-room-text { flex: 1; }
  .sel-room-name { font-size: 16px; font-weight: 800; color: var(--text-black); margin-bottom: 4px; }
  .sel-room-capa { font-size: 13px; color: var(--text-gray); }
  .sel-room-arrow { color: var(--text-gray); font-size: 20px; font-weight: 300; }
  .calc-area { background: #F8F9FA; border-radius: 4px; padding: 20px; margin-bottom: 24px; }
  .calc-row { display: flex; justify-content: space-between; font-size: 14px; color: var(--text-dark); margin-bottom: 16px; }
  .calc-row:last-child { margin-bottom: 0; border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 16px; font-weight: 800; color: var(--text-black); }
  .calc-total-val { font-size: 20px; font-weight: 900; }
  .btn-reserve-submit { width: 100%; background: var(--text-black); color: white; border: none; padding: 18px 0; font-size: 16px; font-weight: 800; border-radius: 4px; cursor: pointer; transition: background 0.3s; }
  .btn-reserve-submit:hover { background: var(--point-blue); }

  /* 부가 기능 UI */
  .acc-tags { display: flex; gap: 8px; margin-bottom: 32px; }
  .acc-tag { background: #F5F7FA; color: var(--text-dark); padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 600; }
  .coupon-section { display: flex; justify-content: space-between; align-items: center; padding: 20px 0; margin-bottom: 40px; border-top: 1px solid var(--border-light, #E2E8F0); border-bottom: 1px solid var(--border-light, #E2E8F0); }
  .coupon-info { display: flex; align-items: center; gap: 40px; }
  .coupon-label { font-size: 15px; font-weight: 800; color: var(--text-black); }
  .coupon-desc { font-size: 14px; font-weight: 500; color: var(--text-dark); }
  .btn-download-coupon { display: flex; align-items: center; background: var(--text-black); color: white; border: none; padding: 10px 16px; border-radius: 4px; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.2s; }
  .btn-download-coupon:hover { background: var(--point-blue); transform: translateY(-2px); }
  .facility-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-top: 16px; }
  .facility-item { display: flex; align-items: center; gap: 10px; font-size: 15px; color: var(--text-black); font-weight: 600; }
  .fac-emoji { font-size: 22px; }
  .nearby-summary-box { background: #F8F9FA; padding: 16px 20px; border-radius: 8px; margin-top: 16px; display: flex; align-items: center; gap: 12px; font-size: 14px; font-weight: 600; color: var(--point-blue); border: 1px solid #E6F4FF; }
  
  /* 리뷰 UI */
  .review-photo-gallery { display: flex; gap: 12px; margin-bottom: 32px; overflow-x: auto; padding-bottom: 8px; }
  .review-photo-gallery::-webkit-scrollbar { height: 6px; }
  .review-photo-gallery::-webkit-scrollbar-thumb { background: #E2E8F0; border-radius: 4px; }
  .review-photo-item { position: relative; width: 140px; height: 140px; border-radius: 12px; overflow: hidden; cursor: pointer; flex-shrink: 0; }
  .review-photo-item img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s; }
  .review-photo-item:hover img { transform: scale(1.05); }
  .review-photo-overlay { position: absolute; inset: 0; background: rgba(0,0,0,0.6); color: white; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 900; pointer-events: none; }
  .detail-review-list { display: flex; flex-direction: column; gap: 24px; }
  .detail-review-item { border-bottom: 1px solid var(--border-light, #E2E8F0); padding-bottom: 24px; }
  .detail-review-item:last-child { border-bottom: none; padding-bottom: 0; }
  .d-rev-header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
  .d-rev-profile { width: 44px; height: 44px; border-radius: 50%; background: #E6F4FF; color: var(--point-blue); font-size: 16px; font-weight: 900; display: flex; justify-content: center; align-items: center; }
  .d-rev-name { font-size: 15px; font-weight: 800; color: var(--text-black); }
  .d-rev-meta { font-size: 13px; color: var(--text-gray); display: flex; align-items: center; gap: 8px; margin-top: 4px; }
  .d-rev-stars { color: #FFD700; font-size: 13px; letter-spacing: -1px; }
  .d-rev-content { font-size: 15px; color: var(--text-dark); line-height: 1.6; display: -webkit-box; -webkit-line-clamp: 4; -webkit-box-orient: vertical; overflow: hidden; }
  .btn-all-reviews { width: 100%; padding: 16px; background: white; border: 1px solid var(--border-light, #E2E8F0); border-radius: 8px; font-size: 15px; font-weight: 800; color: var(--text-black); cursor: pointer; transition: background 0.2s; margin-top: 24px; }
  .btn-all-reviews:hover { background: #F8F9FA; border-color: var(--text-gray); }

  /* 우측 예약 모달용 CSS */
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

  @media (max-width: 992px) { .content-split { flex-direction: column; } .sticky-sidebar { width: 100%; position: static; } }
  @media (max-width: 768px) { .facility-grid, .rd-fac-grid { grid-template-columns: repeat(2, 1fr); } }
</style>

<div class="detail-page-wrapper">
  <div class="detail-container">

    <div class="carousel-wrapper">
      <div class="carousel-track" id="carouselTrack">
        <c:set var="imgIdx" value="0" />
        <c:if test="${not empty detail.imageUrl}">
            <c:set var="mainImgStr" value="${fn:startsWith(detail.imageUrl, 'http') ? detail.imageUrl : pageContext.request.contextPath += detail.imageUrl}" />
            <img src="${mainImgStr}" class="carousel-slide" alt="메인 썸네일 이미지" onclick="openAccoPhotoModal(${imgIdx})" onerror="this.src='https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1100'">
            <c:set var="imgIdx" value="${imgIdx + 1}" />
        </c:if>
        <c:if test="${not empty detail.images}">
            <c:forEach var="img" items="${detail.images}">
                <c:if test="${img ne detail.imageUrl}">
                    <c:set var="finalImgStr" value="${fn:startsWith(img, 'http') ? img : pageContext.request.contextPath += img}" />
                    <img src="${finalImgStr}" class="carousel-slide" alt="숙소 상세 이미지" onclick="openAccoPhotoModal(${imgIdx})" onerror="this.src='https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1100'">
                    <c:set var="imgIdx" value="${imgIdx + 1}" />
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
                <svg width="15" height="15" viewBox="0 0 24 24" fill="#4A44F2" style="margin-right:-2px; margin-top:-1px;">
                    <path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                </svg>
                <fmt:formatNumber value="${bookmarkCount}" pattern="#,###"/>
              </span>
              <span style="color:#E2E8F0; margin:0 4px;">|</span>
              <a href="#sec-reviews" class="review-link detail-tab">후기 ${reviewStats.totalCount}개</a>
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

        <c:if test="${couponCount > 0}">
		    <div class="coupon-section">
		        <div class="coupon-info">
		            <span class="coupon-label">쿠폰</span>
		            <span class="coupon-desc">${couponCount}개 쿠폰 발급 가능</span>
		        </div>
		        <button class="btn-download-coupon" onclick="openCouponModal()">
		            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:6px;">
		                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line>
		            </svg>
		            쿠폰 받기
		        </button>
		    </div>
		</c:if>
		
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
		    <h3 class="section-title">숙소 편의시설</h3>
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
                <c:if test="${not empty detail.otherFacility}">
                    <div class="facility-item" style="grid-column: 1 / -1;"><span class="fac-emoji">✨</span> 기타: ${detail.otherFacility}</div>
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
				     <c:if test="${!room.available}">style="opacity: 0.6; background-color: #f8f9fa;" title="예약 마감된 객실"</c:if>
				     <c:if test="${room.available and isCapacityExceeded}">style="opacity: 0.6; background-color: #f8f9fa;" title="인원 초과 객실"</c:if>>
				  
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
				  
                  <div style="display:flex; gap:8px; align-self:flex-end;">
                      <button type="button" class="btn-room-detail-view" onclick="openRoomDetailModal('${room.roomId}')">상세보기</button>
                      <c:choose>
                        <c:when test="${!room.available}">
                            <button class="btn-select-room" style="background:#A0AEC0; cursor:not-allowed;" disabled>예약 마감</button>
                        </c:when>
                        <c:when test="${isCapacityExceeded}">
                            <button class="btn-select-room" style="background:#F56565; color:white; cursor:not-allowed;" disabled>인원 초과</button>
                        </c:when>
                        <c:otherwise>
                            <button class="btn-select-room" onclick="selectRoom('${room.roomId}', '${fn:escapeXml(room.roomName)}', '${imgUrl}', '${room.roomBaseCount}', '${room.maxCapacity}', '<fmt:formatNumber value="${finalPrice}"/>', '<fmt:formatNumber value="${totalPrice}"/>')">객실 선택</button>
                        </c:otherwise>
                      </c:choose>
                  </div>
				</div>
              </c:forEach>
            </div>
        </div>

        <div id="sec-reviews" class="scroll-section">
            <h3 class="section-title">방문자 리뷰 <span style="color:var(--text-gray); font-size:18px; margin-left:4px;">(${reviewStats.totalCount})</span></h3>
            <c:choose>
                <c:when test="${reviewStats.totalCount == 0}">
                    <p class="intro-text" style="color:var(--text-gray);">아직 작성된 리뷰가 없습니다. 첫 리뷰의 주인공이 되어보세요!</p>
                </c:when>
                <c:otherwise>
                    <c:if test="${not empty reviewPhotos}">
                        <div class="review-photo-gallery">
                            <c:forEach var="photo" items="${reviewPhotos}" varStatus="status" end="5">
                                <div class="review-photo-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/review/list/${detail.placeId}?tab=photo'">
                                    <img src="${pageContext.request.contextPath}/uploads/review/${photo}" alt="리뷰 사진">
                                    <c:if test="${status.index == 5 and fn:length(reviewPhotos) > 6}">
                                        <div class="review-photo-overlay">+${fn:length(reviewPhotos) - 6}</div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                    
                    <div class="detail-review-list">
                        <c:forEach var="review" items="${topReviews}">
                            <div class="detail-review-item">
                                <div class="d-rev-header">
                                    <div class="d-rev-profile">${fn:substring(review.memberName, 0, 1)}</div>
                                    <div>
                                        <div class="d-rev-name">${review.memberName}</div>
                                        <div class="d-rev-meta">
                                            <span>${review.roomName}</span>
                                            <span style="margin: 0 4px; color: #E2E8F0;">|</span>
                                            <div class="d-rev-stars" style="display: flex; gap: 2px; align-items: center; margin-top: -2px;">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="${i <= review.rating ? '#333333' : '#EDF2F7'}"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                                                </c:forEach>
                                            </div>
                                            <span style="color:#0051C9; font-weight:800; font-size:15px; margin-left:2px;"><fmt:formatNumber value="${review.rating}" pattern="0.0"/></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-rev-content"><c:out value="${review.content}" /></div>
                            </div>
                        </c:forEach>
                    </div>
                    <button class="btn-all-reviews" onclick="location.href='${pageContext.request.contextPath}/accommodation/review/list/${detail.placeId}?tab=review'">방문자 리뷰 전체 보기</button>
                </c:otherwise>
            </c:choose>
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
	     <c:if test="${room.available}">onclick="selectRoom('${room.roomId}', '${fn:escapeXml(room.roomName)}', '${imgUrl}', '${room.roomBaseCount}', '${room.maxCapacity}', '<fmt:formatNumber value="${finalPrice}"/>', '<fmt:formatNumber value="${totalPrice}"/>')"</c:if>
	     <c:if test="${!room.available}">style="opacity: 0.5; pointer-events: none; background-color: #f8f9fa;"</c:if>>
	     
	  <img src="${imgUrl}" alt="${room.roomName}">
	  <div class="rm-item-info">
	    <div class="rm-i-name">${room.roomName}</div>
	    <div class="rm-i-capa">
	        기준 ${room.roomBaseCount}명 (최대 ${room.maxCapacity}명)
	        <c:choose>
	            <c:when test="${not empty param.checkin and not empty param.checkout}"><span style="color:#E53E3E; font-weight:800; margin-left:4px;">| 남은 객실: ${room.remainingCount}개</span></c:when>
	            <c:otherwise><span style="color:var(--text-gray); margin-left:4px;">| 총 객실: ${room.roomCount}개</span></c:otherwise>
	        </c:choose>
	    </div>
	    <div class="rm-i-price">₩<fmt:formatNumber value="${finalPrice}" pattern="#,###"/>~ <span style="font-size:12px; font-weight:500; color:var(--text-gray);">/박</span></div>
	  </div>
	  <c:if test="${!room.available}"><span style="color:#E53E3E; font-size:14px; font-weight:800; align-self:center; margin-left:auto; padding-right:10px;">마감</span></c:if>
	</div>
    </c:forEach>
  </div>
</div>

<div class="rm-overlay" id="cpOverlay" onclick="closeCouponModal()"></div>
<div class="rm-modal" id="cpModal">
  <div class="rm-header">쿠폰 다운로드<span class="rm-close" onclick="closeCouponModal()">✕</span></div>
  <div class="rm-body" id="cpBody"></div>
</div>

<div id="accoPhotoModal" class="photo-modal" onclick="closeAccoPhotoModal(event)">
    <span class="close-modal" onclick="closeAccoPhotoModal(event)">×</span>
    <img id="modalAccoPhoto" class="modal-content">
    <span class="prev" onclick="changeAccoPhoto(-1, event)">&#10094;</span>
    <span class="next" onclick="changeAccoPhoto(1, event)">&#10095;</span>
    <div class="modal-index"><span id="accoModalIndex"></span> / <span id="accoModalTotal"></span></div>
</div>

<div class="rd-overlay" id="roomDetailOverlay" onclick="closeRoomDetailModal()"></div>
<div class="rd-modal" id="roomDetailModal">
    <div class="rd-header">
        <span id="rdModalTitle">객실 상세</span>
        <span class="rd-close" onclick="closeRoomDetailModal()">✕</span>
    </div>
    <div class="rd-body">
        
        <div class="rd-img-container">
            <div class="rd-carousel-track" id="rdCarouselTrack"></div>
            <button class="rd-carousel-btn rd-prev" id="rdBtnPrev" onclick="moveRdCarousel(-1)">&#10094;</button>
            <button class="rd-carousel-btn rd-next" id="rdBtnNext" onclick="moveRdCarousel(1)">&#10095;</button>
            <div class="rd-carousel-counter" id="rdCounterWrapper"><span id="rdCurr">1</span> / <span id="rdTotal">1</span></div>
        </div>
        
        <div class="rd-content">
            <div class="rd-title" id="rdName">객실 이름</div>
            <div class="rd-capa" id="rdCapa">기준 0명 / 최대 0명</div>
            <div class="rd-intro" id="rdIntro">객실 설명</div>
            
            <div class="rd-fac-title">객실 편의시설</div>
            <div class="rd-fac-grid" id="rdFacGrid"></div>
        </div>
    </div>
</div>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoApiKey}&libraries=services"></script>

<script type="text/javascript">
window.disabledDates = [
    <c:forEach var="date" items="${bookedDates}" varStatus="status">'${date}'${!status.last ? ',' : ''}</c:forEach>
];

// --- 메인 숙소 이미지 슬라이더 ---
let currentSlide = 0; let slides = []; let totalSlides = 0;
document.addEventListener("DOMContentLoaded", () => {
    slides = document.querySelectorAll('#carouselTrack .carousel-slide'); totalSlides = slides.length;
    document.getElementById('c-total').innerText = totalSlides;
    if (totalSlides <= 1) { document.getElementById('c-btn-prev').style.display = 'none'; document.getElementById('c-btn-next').style.display = 'none'; }
});
function moveCarousel(dir) {
    if(totalSlides <= 1) return;
    currentSlide += dir;
    if (currentSlide < 0) currentSlide = totalSlides - 1;
    if (currentSlide >= totalSlides) currentSlide = 0;
    document.getElementById('carouselTrack').style.transform = `translateX(-\${currentSlide * 100}%)`;
    document.getElementById('c-curr').innerText = currentSlide + 1;
}

// --- 공용 전체사진 갤러리 로직 ---
let currentAccoPhotos = []; let currentAccoIndex = 0; let modalAccoTotal = 0;

// (메인 숙소 사진 클릭 시 호출)
function openAccoPhotoModal(index) {
    currentAccoPhotos = Array.from(document.querySelectorAll('#carouselTrack .carousel-slide')).map(img => img.src);
    currentAccoIndex = index; modalAccoTotal = currentAccoPhotos.length;
    
    const modal = document.getElementById('accoPhotoModal');
    document.getElementById('modalAccoPhoto').src = currentAccoPhotos[currentAccoIndex];
    document.getElementById('accoModalIndex').textContent = currentAccoIndex + 1;
    document.getElementById('accoModalTotal').textContent = modalAccoTotal;
    modal.classList.add('open'); 
    document.body.style.overflow = 'hidden';
}

function closeAccoPhotoModal(e) {
    if (e.target.id === 'accoPhotoModal' || e.target.className === 'close-modal') {
        document.getElementById('accoPhotoModal').classList.remove('open'); 
        if(!document.getElementById('roomDetailModal').classList.contains('open')) {
            document.body.style.overflow = ''; 
        }
    }
}

function changeAccoPhoto(dir, e) {
    if (e) e.stopPropagation(); currentAccoIndex += dir;
    if (currentAccoIndex >= modalAccoTotal) currentAccoIndex = 0; 
    if (currentAccoIndex < 0) currentAccoIndex = modalAccoTotal - 1; 
    document.getElementById('modalAccoPhoto').src = currentAccoPhotos[currentAccoIndex];
    document.getElementById('accoModalIndex').textContent = currentAccoIndex + 1;
}
document.addEventListener('keydown', function(e) {
    const modal = document.getElementById('accoPhotoModal');
    if (modal && modal.classList.contains('open')) {
        if (e.key === 'ArrowLeft' || e.keyCode === 37) changeAccoPhoto(-1);
        else if (e.key === 'ArrowRight' || e.keyCode === 39) changeAccoPhoto(1);
        else if (e.key === 'Escape' || e.keyCode === 27) closeAccoPhotoModal({ target: { id: 'accoPhotoModal' } });
    }
});


// 🌟 [신규] 객실 상세보기 모달 & 캐러셀 로직 🌟
const roomFacDict = [
    { key: 'bathFacility', icon: '🚿', name: '목욕시설' },
    { key: 'bath', icon: '🛁', name: '욕조' },
    { key: 'airCondition', icon: '❄️', name: '에어컨' },
    { key: 'tv', icon: '📺', name: 'TV' },
    { key: 'pc', icon: '🖥️', name: 'PC' },
    { key: 'internet', icon: '📶', name: '인터넷' },
    { key: 'refrigerator', icon: '🧊', name: '냉장고' },
    { key: 'toiletries', icon: '🪥', name: '세면도구' },
    { key: 'sofa', icon: '🛋️', name: '소파' },
    { key: 'table', icon: '🪑', name: '테이블' },
    { key: 'hairdryer', icon: '💨', name: '헤어드라이어' },
    { key: 'homeTheater', icon: '🎬', name: '홈시어터' }
];

let rdCurrentSlide = 0;
let rdTotalSlides = 0;
let rdImagesArray = []; // 객실 사진을 갤러리로 넘기기 위한 배열

function moveRdCarousel(dir) {
    if(rdTotalSlides <= 1) return;
    rdCurrentSlide += dir;
    if (rdCurrentSlide < 0) rdCurrentSlide = rdTotalSlides - 1;
    if (rdCurrentSlide >= rdTotalSlides) rdCurrentSlide = 0;
    document.getElementById('rdCarouselTrack').style.transform = `translateX(-\${rdCurrentSlide * 100}%)`;
    document.getElementById('rdCurr').innerText = rdCurrentSlide + 1;
}

// 🌟 객실 모달 안의 사진을 클릭했을 때 공용 갤러리를 띄우는 함수
function openRoomGallery(index) {
    currentAccoPhotos = rdImagesArray; // 갤러리에 현재 객실 사진 목록 덮어쓰기
    currentAccoIndex = index;
    modalAccoTotal = currentAccoPhotos.length;
    
    const modal = document.getElementById('accoPhotoModal');
    document.getElementById('modalAccoPhoto').src = currentAccoPhotos[currentAccoIndex];
    document.getElementById('accoModalIndex').textContent = currentAccoIndex + 1;
    document.getElementById('accoModalTotal').textContent = modalAccoTotal;
    modal.classList.add('open'); 
}

function openRoomDetailModal(roomId) {
    document.getElementById('roomDetailOverlay').classList.add('open');
    document.getElementById('roomDetailModal').classList.add('open');
    document.body.style.overflow = 'hidden';
    
    const track = document.getElementById('rdCarouselTrack');
    track.innerHTML = '';
    track.style.transform = 'translateX(0%)';
    rdCurrentSlide = 0;
    document.getElementById('rdName').innerText = '데이터 불러오는 중...';
    document.getElementById('rdIntro').innerText = '';
    document.getElementById('rdFacGrid').innerHTML = '';

    fetch('${pageContext.request.contextPath}/accommodation/room/detail/api/' + roomId)
    .then(res => {
        // 🌟 방어 코드: 로그인 창으로 리다이렉트 되는지 확인
        if (res.redirected || !res.headers.get('content-type')?.includes('application/json')) {
            alert("로그인이 만료되었거나 권한이 없습니다.");
            window.location.href = '${pageContext.request.contextPath}/member/login';
            throw new Error("Redirected");
        }
        return res.json();
    })
    .then(data => {
        if(data.success) {
            const room = data.room;
            const images = data.images;
            
            rdImagesArray = [];
            let trackHtml = '';
            
            // 이미지 캐러셀 세팅
            if (images && images.length > 0) {
                rdTotalSlides = images.length;
                images.forEach((img, idx) => {
                    let imgSrc = img.startsWith('http') ? img : '${pageContext.request.contextPath}' + img;
                    rdImagesArray.push(imgSrc);
                    // 클릭 시 갤러리 열리도록 이벤트 부착
                    trackHtml += `<img src="\${imgSrc}" class="rd-carousel-slide" onclick="openRoomGallery(\${idx})">`;
                });
            } else {
                rdTotalSlides = 1;
                let defaultImg = 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600';
                rdImagesArray.push(defaultImg);
                trackHtml += `<img src="\${defaultImg}" class="rd-carousel-slide" onclick="openRoomGallery(0)">`;
            }
            
            track.innerHTML = trackHtml;
            document.getElementById('rdCurr').innerText = 1;
            document.getElementById('rdTotal').innerText = rdTotalSlides;
            
            // 사진 장수에 따라 버튼 숨기기/보이기
            const btnPrev = document.getElementById('rdBtnPrev');
            const btnNext = document.getElementById('rdBtnNext');
            const counterWrapper = document.getElementById('rdCounterWrapper');
            
            if (rdTotalSlides <= 1) {
                btnPrev.style.display = 'none'; btnNext.style.display = 'none'; counterWrapper.style.display = 'none';
            } else {
                btnPrev.style.display = 'flex'; btnNext.style.display = 'flex'; counterWrapper.style.display = 'block';
            }
            
            // 텍스트 정보 세팅
            document.getElementById('rdName').innerText = room.roomName;
            document.getElementById('rdCapa').innerText = `기준 \${room.baseCount}명 / 최대 \${room.maxCount}명`;
            document.getElementById('rdIntro').innerText = room.roomIntro || '등록된 객실 상세 설명이 없습니다.';
            
            // 편의시설
            let facHtml = '';
            roomFacDict.forEach(fac => {
                if (room[fac.key] == 1) facHtml += `<div class="rd-fac-item"><span class="rd-fac-icon">\${fac.icon}</span>\${fac.name}</div>`;
            });
            if(facHtml === '') facHtml = '<div style="grid-column:1/-1; color:var(--text-gray); font-size:14px;">등록된 편의시설 정보가 없습니다.</div>';
            document.getElementById('rdFacGrid').innerHTML = facHtml;
            
        } else {
            alert(data.message || '객실 정보를 가져올 수 없습니다.');
            closeRoomDetailModal();
        }
    })
    .catch(err => {
        console.error(err);
        if(err.message !== "Redirected") {
            alert('서버 오류가 발생했습니다.');
            closeRoomDetailModal();
        }
    });
}

function closeRoomDetailModal() {
    document.getElementById('roomDetailOverlay').classList.remove('open');
    document.getElementById('roomDetailModal').classList.remove('open');
    document.body.style.overflow = '';
}


// --- 스크롤 스파이 등 나머지 UI 스크립트 ---
window.addEventListener('scroll', () => {
    let current = ''; const sections = document.querySelectorAll('.scroll-section'); const navLinks = document.querySelectorAll('.detail-tab'); 
    sections.forEach(sec => { if (pageYOffset >= sec.offsetTop - 150) current = sec.getAttribute('id'); });
    navLinks.forEach(link => { link.classList.remove('active'); if (link.getAttribute('href').includes(current)) link.classList.add('active'); });
});
document.querySelectorAll('.detail-tab').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault(); window.scrollTo({ top: document.querySelector(this.getAttribute('href')).offsetTop - 80, behavior: 'smooth' });
    });
});

function copyShareUrl() { navigator.clipboard.writeText(window.location.href).then(() => alert('숙소 링크가 복사되었습니다!')); }

window.toggleBookmark = function(e, placeId, btn) {
    e.stopPropagation();
    if (!${not empty sessionScope.loginUser}) return alert("로그인이 필요한 서비스입니다."), location.href='${pageContext.request.contextPath}/member/login';
    fetch('${pageContext.request.contextPath}/accommodation/bookmark', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ placeId: placeId }) })
    .then(res => {
        if (res.redirected || !res.headers.get('content-type')?.includes('application/json')) { alert("로그인이 만료되었습니다."); window.location.href = '${pageContext.request.contextPath}/member/login'; throw new Error("Redirected"); }
        return res.json();
    })
    .then(data => {
        if (!data.success) return alert(data.message);
        const svg = btn.querySelector('svg');
        if (data.isBookmarked) { svg.setAttribute('fill', '#4A44F2'); svg.setAttribute('stroke', '#4A44F2'); } 
        else { svg.setAttribute('fill', 'none'); svg.setAttribute('stroke', 'currentColor'); }
    }).catch(err => { if(err.message !== "Redirected") console.error(err); });
};

let currentSelectedRoomId = null;
function openRoomModal() { document.getElementById('rmOverlay').classList.add('open'); document.getElementById('rmModal').classList.add('open'); document.body.style.overflow = 'hidden'; }
function closeRoomModal() { document.getElementById('rmOverlay').classList.remove('open'); document.getElementById('rmModal').classList.remove('open'); document.body.style.overflow = ''; }
function selectRoom(roomId, name, img, baseCapa, maxCapa, priceStr, totalStr) {
    currentSelectedRoomId = roomId; const imgEl = document.getElementById('s-room-img'); imgEl.src = img; imgEl.style.display = 'block';
    document.getElementById('s-room-name').innerText = name; if(baseCapa) document.getElementById('s-room-capa').innerText = `기준 \${baseCapa}명 (최대 \${maxCapa}명)`;
    document.getElementById('s-price-calc').innerText = `₩\${priceStr} * ${calcNights}박`; document.getElementById('s-price-total').innerText = `₩\${totalStr}`;
    closeRoomModal();
}
document.addEventListener("DOMContentLoaded", () => { const firstRoom = document.querySelector('.rm-item'); if (firstRoom) firstRoom.click(); });

function submitReservation() {
    if (!currentSelectedRoomId) return alert("객실을 먼저 선택해주세요."), openRoomModal();
    if (!${not empty sessionScope.loginUser}) return alert("로그인이 필요한 서비스입니다."), location.href='${pageContext.request.contextPath}/member/login';
    const params = new URLSearchParams(window.location.search);
    const checkin = params.get('checkin') || ''; const checkout = params.get('checkout') || '';
    if (!checkin || !checkout) return alert("체크인 / 체크아웃 날짜를 먼저 선택해주세요!");
    fetch('${pageContext.request.contextPath}/accommodation/check-lock', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ roomId: currentSelectedRoomId, checkin: checkin, checkout: checkout }) })
    .then(res => {
        if (res.redirected || !res.headers.get('content-type')?.includes('application/json')) { alert("로그인이 만료되었습니다."); window.location.href = '${pageContext.request.contextPath}/member/login'; throw new Error("Redirected"); }
        return res.json();
    })
    .then(data => {
        if (data.success) location.href = `${pageContext.request.contextPath}/accommodation/reservation?roomId=\${currentSelectedRoomId}&checkin=\${checkin}&checkout=\${checkout}&adult=\${params.get('adult') || '1'}&child=\${params.get('child') || '0'}`;
        else alert(data.message);
    }).catch(err => { if(err.message !== "Redirected") alert("서버 통신 오류가 발생했습니다."); });
}

document.addEventListener("DOMContentLoaded", () => {
    const lat = ${detail.latitude}, lng = ${detail.longitude};
    if (lat && lng) {
        const mapContainer = document.getElementById('map'); const locPosition = new kakao.maps.LatLng(lat, lng);
        const map = new kakao.maps.Map(mapContainer, { center: locPosition, level: 4 });
        new kakao.maps.Marker({ position: locPosition }).setMap(map);
        const ps = new kakao.maps.services.Places(map); const cats = ['CS2', 'PM9', 'MT1']; const catNames = { 'CS2': '편의점', 'PM9': '약국', 'MT1': '대형마트' };
        let results = [], completed = 0;
        cats.forEach(code => {
            ps.categorySearch(code, function(data, status, pg) {
                if (status === kakao.maps.services.Status.OK && pg.totalCount > 0) results.push(`\${catNames[code]} \${pg.totalCount}개`);
                if (++completed === cats.length) document.getElementById('nearbySummary').innerHTML = results.length > 0 ? `<i class="bi bi-info-circle-fill"></i> 도보 5분(500m) 거리 내 <strong>\${results.join(', ')}</strong>가 있습니다.` : `<i class="bi bi-info-circle"></i> 반경 500m 내에 검색된 주요 편의시설이 없습니다.`;
            }, { location: locPosition, radius: 500 });
        });
    } else { document.getElementById('map').style.display = 'none'; document.getElementById('nearbySummary').style.display = 'none'; }
});

function saveRecentAccom() {
    try {
        const key = '${sessionScope.loginUser.memberId}' ? 'tripan_recent_stays_${sessionScope.loginUser.memberId}' : 'tripan_recent_stays_guest';
        const recent = { accommodationId: '${detail.placeId}', accommodationName: '${detail.name}', address: '${detail.region}', thumbnailUrl: '${detail.imageUrl}', viewedAt: new Date().toISOString() };
        let list = JSON.parse(localStorage.getItem(key) || '[]').filter(x => x.accommodationId != recent.accommodationId);
        list.unshift(recent); if (list.length > 10) list = list.slice(0, 10);
        localStorage.setItem(key, JSON.stringify(list));
    } catch(e) {}
}
saveRecentAccom();

function openCouponModal() {
    if (!${not empty sessionScope.loginUser}) return alert("로그인이 필요한 서비스입니다."), location.href='${pageContext.request.contextPath}/member/login';
    fetch('${pageContext.request.contextPath}/accommodation/coupons/${detail.placeId}')
    .then(res => {
        if (res.redirected || !res.headers.get('content-type')?.includes('application/json')) { alert("로그인이 만료되었습니다."); window.location.href = '${pageContext.request.contextPath}/member/login'; throw new Error("Redirected"); }
        return res.json();
    })
    .then(data => {
        if(data.success) { renderCoupons(data.coupons); document.getElementById('cpOverlay').classList.add('open'); document.getElementById('cpModal').classList.add('open'); document.body.style.overflow = 'hidden'; }
        else alert("쿠폰 정보를 불러오는데 실패했습니다.");
    }).catch(err => { if(err.message !== "Redirected") console.error(err); });
}
function closeCouponModal() { document.getElementById('cpOverlay').classList.remove('open'); document.getElementById('cpModal').classList.remove('open'); document.body.style.overflow = ''; }
function renderCoupons(coupons) {
    let html = coupons.length ? coupons.map(c => `
        <div class="rm-item" style="display:flex; justify-content:space-between; align-items:center;">
            <div style="flex:1;">
                <div style="font-size:16px; font-weight:800; color:var(--text-black);">\${c.couponName}</div>
                <div style="font-size:15px; color:var(--point-blue); font-weight:800; margin-top:4px;">\${c.discountType === 'FIXED' ? '₩'+c.discountAmount.toLocaleString() : c.discountAmount+'%'} 할인</div>
                <div style="font-size:13px; color:var(--text-gray); margin-top:2px;">\${c.minOrderAmount ? '최소 결제 ₩'+c.minOrderAmount.toLocaleString() : '조건 없음'}</div>
            </div>
            <button onclick="downloadCoupon(\${c.couponId}, this)" style="padding:10px 16px; border-radius:4px; font-weight:700; border:none; transition:all 0.2s; cursor:\${c.isDownloaded > 0 ? 'not-allowed' : 'pointer'}; background:\${c.isDownloaded > 0 ? '#E2E8F0' : 'var(--text-black)'}; color:\${c.isDownloaded > 0 ? '#A0AEC0' : 'white'};" \${c.isDownloaded > 0 ? 'disabled' : ''}>\${c.isDownloaded > 0 ? '발급완료' : '다운로드'}</button>
        </div>`).join('') : '<div style="padding:20px; text-align:center; color:var(--text-gray);">발급 가능한 쿠폰이 없습니다.</div>';
    document.getElementById('cpBody').innerHTML = html;
}
function downloadCoupon(id, btn) {
    fetch('${pageContext.request.contextPath}/accommodation/coupon/download', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ couponId: id }) })
    .then(res => {
        if (res.redirected || !res.headers.get('content-type')?.includes('application/json')) { alert("로그인이 만료되었습니다."); window.location.href = '${pageContext.request.contextPath}/member/login'; throw new Error("Redirected"); }
        return res.json();
    })
    .then(data => {
        if(data.success) { alert(data.message); btn.innerText = '발급완료'; btn.style.background = '#E2E8F0'; btn.style.color = '#A0AEC0'; btn.style.cursor = 'not-allowed'; btn.disabled = true; }
        else alert(data.message);
    }).catch(err => { if(err.message !== "Redirected") alert("서버 통신 오류가 발생했습니다."); });
}
</script>

<jsp:include page="../accommodation/searchModal.jsp">
    <jsp:param name="hideRegion" value="true" />
</jsp:include>

<jsp:include page="../layout/footer.jsp" />