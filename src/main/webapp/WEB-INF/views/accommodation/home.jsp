<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../layout/header.jsp" />

<style>
  /* --- 공통 설정 --- */
  :root { --home-max-width: 1200px; }
  .home-wrapper { font-family: var(--font-sans); padding-bottom: 100px; background-color: #FAFAFA; }
  .home-container { max-width: var(--home-max-width); margin: 0 auto; padding: 0 24px; }
  .section-title { font-size: 26px; font-weight: 900; color: var(--text-black); margin-bottom: 8px; letter-spacing: -0.5px; }
  .section-desc { font-size: 15px; color: var(--text-gray); margin-bottom: 24px; font-weight: 500; }
  
  /* --- 1. 히어로 섹션 --- */
  .acc-hero { position: relative; width: 100%; height: 65vh; min-height: 550px; display: flex; align-items: center; justify-content: center; flex-direction: column; overflow: hidden; margin-bottom: 60px; }
  .hero-bg { position: absolute; inset: 0; background: url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1600&q=80') center/cover no-repeat; z-index: 1; transform: scale(1.05); animation: slowZoom 20s infinite alternate; }
  @keyframes slowZoom { from { transform: scale(1); } to { transform: scale(1.05); } }
  .hero-overlay { position: absolute; inset: 0; background: linear-gradient(to bottom, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.6) 100%); z-index: 2; }
  .hero-content { position: relative; z-index: 3; width: 100%; max-width: 900px; padding: 0 20px; text-align: center; }
  .hero-content h1 { color: white; font-size: 42px; font-weight: 900; margin-bottom: 40px; text-shadow: 0 4px 12px rgba(0,0,0,0.3); line-height: 1.3; }
  
  /* 🌟 수정: 기존 통통한 검색바 스타일 복원 */
  .unified-search-bar { display: inline-flex; align-items: center; background: white; border: 1px solid #E2E8F0; border-radius: 100px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); padding: 8px; transition: all 0.3s ease; cursor: pointer; }
  .unified-search-bar:hover { box-shadow: 0 15px 40px rgba(0,0,0,0.3); transform: translateY(-2px); }
  .search-segment { display: flex; align-items: center; gap: 12px; padding: 14px 32px; color: var(--text-black); font-size: 16px; font-weight: 700; position: relative; transition: background 0.2s; border-radius: 50px; }
  .search-segment:hover { background-color: #F8F9FA; }
  .search-segment svg { width: 22px; height: 22px; color: var(--text-gray); }
  .search-segment:not(:last-child)::after { content: ''; position: absolute; right: 0; top: 25%; height: 50%; width: 1px; background-color: #E2E8F0; }
  .btn-search-icon { width: 54px; height: 54px; border-radius: 50%; background: var(--point-blue); display: flex; align-items: center; justify-content: center; color: white; margin-left: 8px; flex-shrink: 0; box-shadow: 0 4px 12px rgba(74, 68, 242, 0.3); }

  /* --- 공통 가로 스크롤 카드 UI (최근본숙소, 인기숙소 공용) --- */
  .horizontal-scroll { display: flex; gap: 24px; overflow-x: auto; padding-bottom: 20px; padding-top: 10px; scrollbar-width: none; }
  .horizontal-scroll::-webkit-scrollbar { display: none; }
  .stay-card { cursor: pointer; transition: transform 0.2s; flex-shrink: 0; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.04); border: 1px solid #F1F3F5; width: 300px; }
  .stay-card:hover { transform: translateY(-6px); box-shadow: 0 12px 24px rgba(0,0,0,0.1); }
  .sc-img-box { position: relative; width: 100%; height: 200px; overflow: hidden; background: #eee; }
  .sc-img-box img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
  .stay-card:hover .sc-img-box img { transform: scale(1.05); }
  .sc-bookmark { position: absolute; top: 16px; right: 16px; background: rgba(255,255,255,0.95); padding: 8px; border-radius: 50%; display: flex; justify-content: center; align-items: center; z-index: 10; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
  .sc-info { padding: 20px; }
  .sc-info .sc-loc { font-size: 13px; color: var(--text-gray); font-weight: 600; margin-bottom: 6px; }
  .sc-info .sc-name { font-size: 18px; font-weight: 800; color: var(--text-black); margin-bottom: 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .sc-info .sc-price { font-size: 18px; font-weight: 900; color: var(--text-black); }
  .sc-info .sc-price span { font-size: 13px; color: var(--text-gray); font-weight: 500; }

  /* --- 2. 인기 여행지 --- */
  .dest-section { margin-bottom: 80px; background: white; padding: 40px; border-radius: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
  .dest-grid { display: flex; justify-content: space-between; overflow-x: auto; padding-bottom: 10px; scrollbar-width: none; }
  .dest-grid::-webkit-scrollbar { display: none; }
  .dest-item { display: flex; flex-direction: column; align-items: center; gap: 12px; cursor: pointer; flex-shrink: 0; transition: transform 0.2s; min-width: 90px; }
  .dest-item:hover { transform: translateY(-4px); }
  .dest-img { width: 80px; height: 80px; border-radius: 40%; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.08); border: 2px solid white; background:#eee; }
  .dest-img img { width: 100%; height: 100%; object-fit: cover; }
  .dest-name { font-size: 15px; font-weight: 800; color: var(--text-black); }

  /* --- 3. 최근 본 숙소 --- */
  #recentViewsSection { margin-bottom: 80px; }

  /* --- 4. 프로모션 배너 --- */
  .promo-banner { margin-bottom: 80px; border-radius: 24px; overflow: hidden; background: linear-gradient(135deg, #4A44F2 0%, #00C6FF 100%); color: white; display: flex; align-items: center; justify-content: space-between; padding: 40px 60px; box-shadow: 0 10px 30px rgba(74, 68, 242, 0.2); cursor: pointer; transition: transform 0.2s; }
  .promo-banner:hover { transform: translateY(-4px); }
  .promo-text h3 { font-size: 28px; font-weight: 900; margin-bottom: 8px; }
  .promo-text p { font-size: 16px; font-weight: 500; opacity: 0.9; }
  .promo-btn { background: white; color: #4A44F2; padding: 12px 32px; border-radius: 100px; font-weight: 800; font-size: 15px; }

  /* --- 5. 인기 숙소 --- */
  .popular-section { margin-bottom: 80px; }

  /* --- 6. 테마 여행 --- */
  .theme-section { margin-bottom: 80px; background: white; padding: 40px; border-radius: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
  .theme-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
  .theme-card { position: relative; height: 180px; border-radius: 16px; overflow: hidden; cursor: pointer; background:#eee; }
  .theme-card img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
  .theme-card:hover img { transform: scale(1.05); }
  .theme-overlay { position: absolute; inset: 0; background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0) 100%); display: flex; align-items: flex-end; padding: 20px; }
  .theme-title { color: white; font-size: 18px; font-weight: 800; letter-spacing: -0.5px; }

  /* --- 7. Tripan 혜택 --- */
  .benefits-section { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 60px; }
  .benefit-card { background: white; padding: 32px; border-radius: 20px; text-align: center; border: 1px solid #F1F3F5; }
  .benefit-icon { font-size: 40px; margin-bottom: 16px; }
  .benefit-title { font-size: 18px; font-weight: 800; color: var(--text-black); margin-bottom: 8px; }
  .benefit-desc { font-size: 14px; color: var(--text-gray); line-height: 1.5; }

  @media (max-width: 992px) { 
      .theme-grid { grid-template-columns: repeat(2, 1fr); } 
      .benefits-section { grid-template-columns: 1fr; }
      .promo-banner { flex-direction: column; text-align: center; gap: 24px; padding: 32px; }
  }
  @media (max-width: 600px) { 
      .hero-content h1 { font-size: 28px; }
      .search-segment { padding: 14px 16px; }
      .search-segment span { display: none; } /* 모바일에서는 글자 숨김 */
  }
</style>

<div class="home-wrapper">

  <section class="acc-hero">
    <div class="hero-bg"></div>
    <div class="hero-overlay"></div>
    <div class="hero-content">
      <h1>모든 순간이 여행이 되는 곳,<br>Tripan과 함께 떠나보세요.</h1>
      
      <div class="unified-search-bar" onclick="openModal('region')">
        <div class="search-segment">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          <span>여행지 / 숙소</span>
        </div>
        <div class="search-segment">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
          <span>일정</span>
        </div>
        <div class="search-segment">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          <span>인원</span>
        </div>
        <div class="btn-search-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </div>
      </div>

    </div>
  </section>

  <div class="home-container">

    <section class="dest-section">
      <h2 class="section-title">국내 인기 여행지</h2>
      <p class="section-desc">지금 가장 사랑받는 도시들을 만나보세요.</p>
      <div class="dest-grid">
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=서울'">
          <%-- 서울: 한강과 도심 전경 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1532649097480-b67d52743b69?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="서울"></div><div class="dest-name">서울</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=제주'">
          <%-- 제주: 성산일출봉과 바다 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1612977512598-3b8d6a498bbb?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="제주"></div><div class="dest-name">제주도</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=부산'">
          <%-- 부산: 해운대 광안대교 전경 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1638591751482-1a7d27fcea15?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="부산"></div><div class="dest-name">부산</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=강릉'">
          <%-- 강릉: 시원한 동해 바다와 해변 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1542086094-a61c1ab7c4b8?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="강릉"></div><div class="dest-name">강릉</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=경주'">
          <%-- 경주: 고즈넉한 대릉원/첨성대 전경 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1656980593245-b54c8c0828f0?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="경주"></div><div class="dest-name">경주</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=전주'">
          <%-- 전주: 예쁜 한옥마을 기와지붕 전경 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1548115184-bc6544d06a58?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="전주"></div><div class="dest-name">전주</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?regions=여수'">
          <%-- 여수: 화려한 여수 밤바다와 돌산대교 야경 --%>
          <div class="dest-img"><img src="https://images.unsplash.com/photo-1651375562199-65caae096ace?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="여수"></div><div class="dest-name">여수</div>
        </div>
        <div class="dest-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/list'">
          <div class="dest-img" style="border: 2px solid #E2E8F0; background:#F8F9FA; display:flex; justify-content:center; align-items:center;">
             <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
          <div class="dest-name">전체보기</div>
        </div>
      </div>
    </section>

    <section id="recentViewsSection" style="display:none;">
      <h2 class="section-title">최근 살펴본 숙소 👀</h2>
      <p class="section-desc">방금 전 눈여겨보던 그곳, 다시 확인해보세요.</p>
      <div class="horizontal-scroll" id="recentViewsContainer">
        </div>
    </section>

    <div class="promo-banner" onclick="try { showLoginModal(); } catch(e) { location.href='${pageContext.request.contextPath}/member/login'; }">
        <div class="promo-text">
            <h3>Tripan이 처음이신가요?</h3>
            <p>신규 가입하고 웰컴 할인 쿠폰팩과 첫 결제 1% 마일리지 적립 혜택을 누려보세요!</p>
        </div>
        <div class="promo-btn">로그인 및 혜택 받기</div>
    </div>

    <section class="popular-section">
      <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:8px;">
        <h2 class="section-title" style="margin-bottom:0;">지금 가장 핫한 숙소 🔥</h2>
        <a href="${pageContext.request.contextPath}/accommodation/list" style="font-weight:700; color:var(--point-blue); text-decoration:none;">더보기 &rarr;</a>
      </div>
      <p class="section-desc">Tripan 유저들이 실시간으로 가장 많이 찜한 인기 숙소들을 모았습니다.</p>
      
      <div class="horizontal-scroll">
        <c:if test="${not empty popularList}">
            <c:forEach var="stay" items="${popularList}">
                <div class="stay-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail/${stay.placeId}'">
                  <div class="sc-img-box">
                    <img src="${fn:startsWith(stay.imageUrl, 'http') ? stay.imageUrl : pageContext.request.contextPath += stay.imageUrl}" onerror="this.src='https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'">
                    <div class="sc-bookmark" onclick="event.stopPropagation();">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="${stay.isBookmarked > 0 ? '#4A44F2' : 'none'}" stroke="${stay.isBookmarked > 0 ? '#4A44F2' : '#111'}" stroke-width="2">
                            <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path>
                        </svg>
                    </div>
                  </div>
                  <div class="sc-info">
                    <div class="sc-loc">${stay.region}</div>
                    <div class="sc-name">${stay.name}</div>
                    <div class="sc-price">
                        <span style="color:#FFD700; margin-right:4px;">★ 4.8</span> 
                        ₩<fmt:formatNumber value="${stay.minPrice}" pattern="#,###"/><span> /박</span>
                    </div>
                  </div>
                </div>
            </c:forEach>
        </c:if>
        <c:if test="${empty popularList}">
            <div style="width:100%; text-align:center; padding:60px 0; background:white; border-radius:16px; border:1px solid #eee;">
                <p style="color:var(--text-gray); font-weight:600;">현재 서버에 등록된 추천 숙소가 없습니다.</p>
            </div>
        </c:if>
      </div>
    </section>

    <section class="theme-section">
      <h2 class="section-title">취향으로 찾는 테마 여행 🎯</h2>
      <p class="section-desc">내가 원하는 스타일의 숙소만 쏙쏙 골라보세요.</p>
      
      <div class="theme-grid">
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=도심속휴식'">
          <img src="https://images.unsplash.com/photo-1517840901100-8179e982acb7?w=600" alt="도심속휴식">
          <div class="theme-overlay"><div class="theme-title">#도심속휴식</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=감성숙소'">
          <img src="https://images.unsplash.com/photo-1499916078039-922301b0eb9b?w=600" alt="감성숙소">
          <div class="theme-overlay"><div class="theme-title">#감성숙소</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=오션뷰'">
          <img src="https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=600" alt="오션뷰">
          <div class="theme-overlay"><div class="theme-title">#오션뷰</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=반려동물'">
          <img src="https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=600" alt="반려동물">
          <div class="theme-overlay"><div class="theme-title">#반려동물동반</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=한옥'">
          <img src="https://images.unsplash.com/photo-1618237586696-d3690dad22e3?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="한옥">
          <div class="theme-overlay"><div class="theme-title">#고즈넉한_한옥</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=수영장'">
          <img src="https://images.unsplash.com/photo-1596178067639-5c6e68aea6dc?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="풀빌라">
          <div class="theme-overlay"><div class="theme-title">#프라이빗_풀빌라</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=가족여행'">
          <img src="https://images.unsplash.com/photo-1566552881560-0be862a7c445?w=600" alt="가족여행">
          <div class="theme-overlay"><div class="theme-title">#가족여행</div></div>
        </div>
        <div class="theme-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/list?tag=바비큐'">
          <img src="https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600" alt="바비큐">
          <div class="theme-overlay"><div class="theme-title">#맛있는_바비큐</div></div>
        </div>
      </div>
    </section>

    <section class="benefits-section">
        <div class="benefit-card">
            <div class="benefit-icon">🪙</div>
            <div class="benefit-title">결제 금액 1% 무제한 적립</div>
            <div class="benefit-desc">숙소를 예약할 때마다 제한 없이 마일리지가 차곡차곡 쌓입니다.</div>
        </div>
        <div class="benefit-card">
            <div class="benefit-icon">🎟️</div>
            <div class="benefit-title">매월 쏟아지는 할인 쿠폰</div>
            <div class="benefit-desc">숙소 상세 페이지에서 발급받은 쿠폰으로 더 저렴하게 예약하세요.</div>
        </div>
        <div class="benefit-card">
            <div class="benefit-icon">🛡️</div>
            <div class="benefit-title">안전하고 간편한 결제</div>
            <div class="benefit-desc">포트원 결제 연동으로 신용카드부터 간편결제까지 안전하게 지원합니다.</div>
        </div>
    </section>

  </div>
</div>

<jsp:include page="../member/loginModal.jsp" />

<jsp:include page="../accommodation/searchModal.jsp" />

<script>
function loadRecentViews() {
    const key = '${sessionScope.loginUser.memberId}' ? 'tripan_recent_stays_${sessionScope.loginUser.memberId}' : 'tripan_recent_stays_guest';
    const list = JSON.parse(localStorage.getItem(key) || '[]');
    const container = document.getElementById('recentViewsContainer');
    const section = document.getElementById('recentViewsSection');
    
    if(list.length === 0) {
        section.style.display = 'none';
        return;
    }
    
    section.style.display = 'block';
    let html = '';
    list.forEach(item => {
        const imgSrc = item.thumbnailUrl.startsWith('http') ? item.thumbnailUrl : '${pageContext.request.contextPath}' + item.thumbnailUrl;
        html += `
        <div class="stay-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail/\${item.accommodationId}'">
            <div class="sc-img-box">
                <img src="\${imgSrc}" onerror="this.src='https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'">
            </div>
            <div class="sc-info">
                <div class="sc-loc">\${item.address}</div>
                <div class="sc-name">\${item.accommodationName}</div>
            </div>
        </div>`;
    });
    container.innerHTML = html;
}

document.addEventListener("DOMContentLoaded", loadRecentViews);
</script>

<jsp:include page="../layout/footer.jsp" />