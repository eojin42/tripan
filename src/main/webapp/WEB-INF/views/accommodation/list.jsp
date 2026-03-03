<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<c:if test="${not empty param.checkin and not empty param.checkout}">
    <fmt:parseDate value="${param.checkin}" var="inDate" pattern="yyyy-MM-dd"/>
    <fmt:parseDate value="${param.checkout}" var="outDate" pattern="yyyy-MM-dd"/>
    <fmt:formatDate value="${inDate}" var="inStr" pattern="M.d"/>
    <fmt:formatDate value="${outDate}" var="outStr" pattern="M.d"/>
    
    <fmt:formatDate value="${inDate}" var="inDay" pattern="E"/>
    <fmt:formatDate value="${outDate}" var="outDay" pattern="E"/>
</c:if>

<c:set var="adultCnt" value="${empty param.adult ? 0 : param.adult}" />
<c:set var="childCnt" value="${empty param.child ? 0 : param.child}" />
<c:set var="totalGuest" value="${adultCnt + childCnt}" />

<jsp:include page="../layout/header.jsp" />

<style>
  /* 컨테이너 */
  .list-container { 
    max-width: 1400px; 
    margin: 160px auto 100px; 
    padding: 0 40px; 
  }
  
  /* --- [핵심 1] 통합 검색바 스타일 (사진 2번 스타일) --- */
  .list-search-bar {
    position: relative;
    display: flex; 
    justify-content: center; 
    margin-bottom: 40px;
  }
  
  .unified-search-bar {
    display: flex;
    align-items: center;
    background: white;
    border: 1px solid #E2E8F0;
    border-radius: 100px; /* 둥근 알약 모양 */
    box-shadow: 0 4px 20px rgba(0,0,0,0.05); /* 부드러운 그림자 */
    padding: 4px;
    transition: all 0.3s ease;
  }
  
  .unified-search-bar:hover {
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
    transform: translateY(-2px);
  }

  /* 검색 섹션 (지역/일정/인원) */
  .search-segment {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 32px;
    cursor: pointer;
    position: relative;
    color: var(--text-black);
    font-size: 15px;
    font-weight: 700;
    transition: background 0.2s;
    border-radius: 50px; /* 호버 시 둥글게 */
  }
  
  .search-segment:hover {
    background-color: #F8F9FA;
  }
  
  /* 아이콘 스타일 */
  .search-segment svg {
    width: 20px; height: 20px;
    color: var(--text-gray); /* 기본 회색 */
  }
  
  /* 활성화 되었을 때 (값이 있을 때) */
  .search-segment.active {
    color: var(--point-blue);
  }
  .search-segment.active svg {
    color: var(--point-blue);
  }

  /* ✨ 세로 구분선 (Divider) */
  .search-segment:not(:last-child)::after {
    content: '';
    position: absolute;
    right: 0;
    top: 25%;
    height: 50%; /* 높이 절반 */
    width: 1px;
    background-color: #E2E8F0;
  }

  /* 우측 필터 아이콘 (절대 위치) */
  .btn-filter-icon {
    position: absolute;
    right: 0;
    top: 50%; transform: translateY(-50%);
    width: 48px; height: 48px; border-radius: 50%; border: 1px solid #E2E8F0;
    display: flex; align-items: center; justify-content: center; cursor: pointer;
    background: white; transition: all 0.2s;
  }
  .btn-filter-icon:hover { background: #F7FAFC; border-color: var(--text-black); }

  /* 카테고리 메뉴 */
  .category-nav {
    display: flex; gap: 32px; overflow-x: auto; padding-bottom: 16px; margin-bottom: 30px;
    border-bottom: 1px solid #F1F3F5; scrollbar-width: none;
  }
  .cat-item {
    display: flex; flex-direction: column; align-items: center; gap: 8px;
    min-width: 64px; cursor: pointer; opacity: 0.6; transition: opacity 0.2s;
  }
  .cat-item:hover, .cat-item.active { opacity: 1; }
  .cat-item span { font-size: 13px; font-weight: 700; color: var(--text-black); white-space: nowrap; }
  .cat-item.active { border-bottom: 2px solid var(--text-black); padding-bottom: 10px; margin-bottom: -18px; }

  /* --- [핵심 2] 숙소 그리드 (3열 배치) --- */
  .stay-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr); /* 🚀 3개씩 배치 */
    gap: 40px 32px; /* 세로간격 40px, 가로간격 32px */
  }
  
  .stay-item { cursor: pointer; transition: transform 0.2s; }
  .stay-item:hover { transform: translateY(-4px); }
  
  .stay-thumb {
    width: 100%; aspect-ratio: 4/3; border-radius: 16px; overflow: hidden; margin-bottom: 16px;
    position: relative; background: #eee;
  }
  .stay-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
  .stay-item:hover .stay-thumb img { transform: scale(1.05); }
  
  .stay-meta h3 { font-size: 18px; font-weight: 800; margin-bottom: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .stay-desc { font-size: 14px; color: var(--text-gray); margin-bottom: 8px; }
  .stay-price { font-size: 17px; font-weight: 800; }
  .stay-discount { color: var(--point-blue); margin-right: 4px; }

  /* 반응형 */
  @media (max-width: 1200px) { 
    .stay-grid { grid-template-columns: repeat(3, 1fr); } 
  }
  @media (max-width: 992px) { 
    .stay-grid { grid-template-columns: repeat(2, 1fr); } 
    .unified-search-bar { width: 100%; justify-content: space-between; }
    .search-segment { padding: 12px 16px; font-size: 14px; }
    .btn-filter-icon { position: static; transform: none; margin-left: 12px; }
    .list-search-bar { justify-content: space-between; }
  }
  @media (max-width: 600px) { 
    .stay-grid { grid-template-columns: 1fr; } 
    .list-container { padding: 0 20px; margin-top: 120px; } 
    .search-segment span { display: none; } /* 모바일엔 아이콘만 */
  }
</style>

<main class="list-container reveal active">
  
  <div class="list-search-bar">
    
    <div class="unified-search-bar">
      
      <div class="search-segment ${not empty param.regions ? 'active' : ''}" onclick="openModal('region')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <span>${not empty param.regions ? param.regions : '서울'}</span>
      </div>
      
      <div class="search-segment ${not empty param.checkin ? 'active' : ''}" onclick="openModal('date')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span>
          <c:choose>
             <c:when test="${not empty param.checkin}">
               1박 ${inStr}(${inDay}) - ${outStr}(${outDay})
             </c:when>
             <c:otherwise>일정</c:otherwise>
          </c:choose>
        </span>
      </div>
      
      <div class="search-segment ${totalGuest > 0 ? 'active' : ''}" onclick="openModal('guest')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        <span>${totalGuest > 0 ? totalGuest += '명' : '1명'}</span>
      </div>
      
    </div>

    <button class="btn-filter-icon" onclick="openFilterModal()">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg>
    </button>
  </div>

  <div class="category-nav">
    <div class="cat-item active"><span>🏠 모든 스테이</span></div>
    <div class="cat-item"><span>🌸 봄꽃여행</span></div>
    <div class="cat-item"><span>🏷️ 프로모션</span></div>
    <div class="cat-item"><span>✨ 신규 오픈</span></div>
    <div class="cat-item"><span>⏰ 마감임박</span></div>
    <div class="cat-item"><span>🏯 고즈넉한</span></div>
    <div class="cat-item"><span>🐶 반려동물</span></div>
  </div>

  <div class="stay-grid">
    
    <div class="stay-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail?id=1'">
      <div class="stay-thumb">
        <img src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600" alt="img">
        <div style="position:absolute; top:12px; right:12px; color:white;">♡</div>
      </div>
      <div class="stay-meta">
        <h3>자하 (JAHA)</h3>
        <p class="stay-desc">서울 종로구 · 2-8명</p>
        <div class="stay-price"><span class="stay-discount">10%</span> ₩300,000~</div>
      </div>
    </div>

    <div class="stay-item">
      <div class="stay-thumb">
        <img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600" alt="img">
        <div class="wish-btn">♡</div>
      </div>
      <div class="stay-meta">
        <h3>히가공덕</h3>
        <p class="stay-desc">서울 마포구 · 4-6명</p>
        <div class="stay-price"><span class="stay-discount">20%</span> ₩236,000~</div>
      </div>
    </div>
    
    <div class="stay-item">
      <div class="stay-thumb">
        <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600" alt="img">
        <div class="wish-btn">♡</div>
      </div>
      <div class="stay-meta">
        <h3>무보재</h3>
        <p class="stay-desc">서울 종로구 · 4-8명</p>
        <div class="stay-price">₩370,000~</div>
      </div>
    </div>
    
    <div class="stay-item">
      <div class="stay-thumb">
        <img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?w=600" alt="img">
        <div class="wish-btn">♡</div>
      </div>
      <div class="stay-meta">
        <h3>서촌 스테이</h3>
        <p class="stay-desc">서울 종로구 · 2명</p>
        <div class="stay-price">₩180,000~</div>
      </div>
    </div>
    
    <div class="stay-item">
      <div class="stay-thumb">
        <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=600" alt="img">
        <div class="wish-btn">♡</div>
      </div>
      <div class="stay-meta">
        <h3>아만 도쿄</h3>
        <p class="stay-desc">일본 도쿄 · 2명</p>
        <div class="stay-price">₩1,200,000~</div>
      </div>
    </div>

  </div>

</main>

<jsp:include page="../accommodation/searchModal.jsp" /> 
<jsp:include page="../accommodation/filterModal.jsp" /> 
<jsp:include page="../layout/footer.jsp" />