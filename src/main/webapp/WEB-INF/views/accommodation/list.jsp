<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<c:if test="${not empty param.checkin and not empty param.checkout}">
    <fmt:parseDate value="${param.checkin}" var="inDate" pattern="yyyy-MM-dd"/>
    <fmt:parseDate value="${param.checkout}" var="outDate" pattern="yyyy-MM-dd"/>
    <fmt:formatDate value="${inDate}" var="inStr" pattern="M.d"/>
    <fmt:formatDate value="${outDate}" var="outStr" pattern="M.d"/>
    <fmt:formatDate value="${inDate}" var="inDay" pattern="E"/>
    <fmt:formatDate value="${outDate}" var="outDay" pattern="E"/>
    
    <c:set var="diffTime" value="${outDate.time - inDate.time}" />
    <c:set var="nights" value="${diffTime / (1000 * 60 * 60 * 24)}" />
    <fmt:parseNumber var="nightCnt" value="${nights}" integerOnly="true" />
</c:if>

<c:set var="adultCnt" value="${empty param.adult ? 0 : param.adult}" />
<c:set var="childCnt" value="${empty param.child ? 0 : param.child}" />
<c:set var="totalGuest" value="${adultCnt + childCnt}" />

<c:if test="${not empty param.regions}">
    <c:set var="regionArr" value="${fn:split(param.regions, ',')}" />
    <c:set var="regionCount" value="${fn:length(regionArr)}" />
    <c:set var="firstRegion" value="${regionArr[0]}" />
</c:if>

<jsp:include page="../layout/header.jsp" />

<style>
  /* 컨테이너 */
  .list-container { 
    max-width: 1400px; 
    margin: 160px auto 100px; 
    padding: 0 40px; 
  }
  
  /* 통합 검색바 스타일 */
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
    border-radius: 100px; 
    box-shadow: 0 4px 20px rgba(0,0,0,0.05); 
    padding: 4px;
    transition: all 0.3s ease;
  }
  
  .unified-search-bar:hover {
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
    transform: translateY(-2px);
  }

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
    border-radius: 50px; 
  }
  .search-segment:hover { background-color: #F8F9FA; }
  
  .search-segment svg { width: 20px; height: 20px; color: var(--text-gray); }
  
  .search-segment.active { color: var(--point-blue); }
  .search-segment.active svg { color: var(--point-blue); }

  /* 구분선 */
  .search-segment:not(:last-child)::after {
    content: ''; position: absolute; right: 0; top: 25%;
    height: 50%; width: 1px; background-color: #E2E8F0;
  }

  /* 필터 아이콘 */
  .btn-filter-icon {
    position: absolute; right: 0; top: 50%; transform: translateY(-50%);
    width: 48px; height: 48px; border-radius: 50%; border: 1px solid #E2E8F0;
    display: flex; align-items: center; justify-content: center; cursor: pointer;
    background: white; transition: all 0.2s;
  }
  .btn-filter-icon:hover { background: #F7FAFC; border-color: var(--text-black); }

  /* 카테고리 & 그리드 */
  .category-nav { display: flex; gap: 32px; overflow-x: auto; padding-bottom: 16px; margin-bottom: 30px; border-bottom: 1px solid #F1F3F5; scrollbar-width: none; }
  .cat-item { display: flex; flex-direction: column; align-items: center; gap: 8px; min-width: 64px; cursor: pointer; opacity: 0.6; transition: opacity 0.2s; }
  .cat-item:hover, .cat-item.active { opacity: 1; }
  .cat-item span { font-size: 13px; font-weight: 700; color: var(--text-black); white-space: nowrap; }
  .cat-item.active { border-bottom: 2px solid var(--text-black); padding-bottom: 10px; margin-bottom: -18px; }

  .accommodation-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 40px 32px; }
  .accommodation-item { cursor: pointer; transition: transform 0.2s; }
  .accommodation-item:hover { transform: translateY(-4px); }
  .accommodation-thumb { width: 100%; aspect-ratio: 4/3; border-radius: 16px; overflow: hidden; margin-bottom: 16px; position: relative; background: #eee; }
  .accommodation-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
  .accommodation-item:hover .accommodation-thumb img { transform: scale(1.05); }
  .accommodation-meta h3 { font-size: 18px; font-weight: 800; margin-bottom: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .accommodation-desc { font-size: 14px; color: var(--text-gray); margin-bottom: 8px; }
  .accommodation-price { font-size: 17px; font-weight: 800; }
  .accommodation-discount { color: var(--point-blue); margin-right: 4px; }

  @media (max-width: 1200px) { .accommodation-grid { grid-template-columns: repeat(3, 1fr); } }
  @media (max-width: 992px) { 
    .accommodation-grid { grid-template-columns: repeat(2, 1fr); } 
    .unified-search-bar { width: 100%; justify-content: space-between; }
    .search-segment { padding: 12px 16px; font-size: 14px; }
    .btn-filter-icon { position: static; transform: none; margin-left: 12px; }
    .list-search-bar { justify-content: space-between; }
  }
  @media (max-width: 600px) { 
    .accommodation-grid { grid-template-columns: 1fr; } 
    .list-container { padding: 0 20px; margin-top: 120px; } 
    .search-segment span { display: none; }
  }
</style>

<main class="list-container reveal active">
  
  <div class="list-search-bar">
    <div class="unified-search-bar">
      
      <div class="search-segment ${not empty param.regions ? 'active' : ''}" onclick="openModal('region')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <span>
          ${not empty param.regions ? param.regions : '여행지'}
        </span>
      </div>
      
      <div class="search-segment ${not empty param.checkin ? 'active' : ''}" onclick="openModal('date')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span>
          <c:choose>
             <c:when test="${not empty param.checkin}">
               ${nightCnt}박 ${inStr}(${inDay}) - ${outStr}(${outDay})
             </c:when>
             <c:otherwise>일정</c:otherwise>
          </c:choose>
        </span>
      </div>
      
      <div class="search-segment ${totalGuest > 0 ? 'active' : ''}" onclick="openModal('guest')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        <span>${totalGuest > 0 ? totalGuest += '명' : '인원'}</span>
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

  <div class="accommodation-grid" id="accommodation-list-container">
  </div>

</main>

<script>
  // 🌟 무한 스크롤 상태 관리 변수들
  let currentOffset = 0;   // 현재까지 불러온 개수
  const PAGE_SIZE = 9;         // 한 번에 불러올 개수 (3열 격자니까 9개가 깔끔해요!)
  let isFetching = false;  // 현재 서버와 통신 중인지 (중복 요청 방지)
  let hasMore = true;      // 더 불러올 데이터가 남아있는지

  window.renderAccommodations = function(list, isAppend) {
    const container = document.getElementById('accommodation-list-container');
    const currentQueryString = window.location.search;
    
    // 1. 처음 검색했는데 아예 데이터가 없는 경우
    if (!isAppend && (!list || list.length === 0)) {
      container.innerHTML = '<div style="grid-column:1/-1; text-align:center; padding:80px 0; font-size:16px; color:#718096;">조건에 맞는 숙소가 없습니다. 텅! 🗑️</div>';
      return;
    }

    let html = '';
    list.forEach(item => {
      const formattedPrice = item.minPrice ? item.minPrice.toLocaleString() : '0';
      const imgPath = item.imageUrl ? item.imageUrl : 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600';
      const regionName = item.region ? item.region.split(' ')[0] : '숙소';
      
      const isZzim = item.isBookmarked > 0;
      const svgFill = isZzim ? '#4A44F2' : 'none';
      const svgStroke = isZzim ? '#4A44F2' : 'white';

      html += `
        <div class="accommodation-item" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail/\${item.placeId}\${currentQueryString}'">
          <div class="accommodation-thumb">
            <img src="\${imgPath}" alt="\${item.name}">
            
            <div class="wish-btn" onclick="toggleBookmark(event, \${item.placeId}, this)" 
                 style="position:absolute; top:12px; right:12px; cursor:pointer; z-index:10;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="\${svgFill}" stroke="\${svgStroke}" stroke-width="2">
                    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
          </div>
          <div class="accommodation-meta">
            <h3>\${item.name}</h3>
            <p class="accommodation-desc">\${regionName} · \${item.accommodationType || '숙소'}</p>
            <div class="accommodation-price">₩\${formattedPrice}~</div>
          </div>
        </div>
      `;
    });
    
    // 2. 덮어씌울지(새로고침), 밑에 이어붙일지(스크롤) 결정!
    if (isAppend) {
        container.insertAdjacentHTML('beforeend', html);
    } else {
        container.innerHTML = html;
    }
  };

  // 🌟 기존 fetchInitialList를 대체하는 메인 요청 함수
  async function fetchAccommodations(isReset = false) {
    // 통신 중이거나 더 이상 데이터가 없으면 튕겨냄
    if (isFetching || (!hasMore && !isReset)) return;
    isFetching = true;

    // 초기화 요청(첫 로드)일 경우 변수 리셋
    if (isReset) {
        currentOffset = 0;
        hasMore = true;
    }

    const urlParams = new URLSearchParams(window.location.search);
    const requestData = {
      region: urlParams.get('regions') || '',
      checkin: urlParams.get('checkin') || '',
      checkout: urlParams.get('checkout') || '',
      adult: parseInt(urlParams.get('adult')) || 0,
      child: parseInt(urlParams.get('child')) || 0,
      accTypes: [], accFacilities: [], roomFacilities: [],
      
      // 🌟 DTO에 추가한 페이징 데이터 전달!
      offset: currentOffset,
      size: PAGE_SIZE
    };

    try {
      const response = await fetch('${pageContext.request.contextPath}/accommodation/search', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestData)
      });
      if (!response.ok) throw new Error('데이터를 불러오지 못했습니다.');
      
      const data = await response.json();
      
      // 🌟 방금 받아온 데이터가 요청한 9개보다 적다면? -> 마지막 페이지라는 뜻!
      if (data.length < PAGE_SIZE) {
          hasMore = false; 
      }

      // 화면 그리기 (isReset이 true면 새로 그리기, false면 이어 붙이기)
      window.renderAccommodations(data, !isReset);
      
      // 다음 번 요청을 위해 offset 증가
      currentOffset += data.length;

    } catch (error) {
      console.error(error);
      if (isReset) {
        document.getElementById('accommodation-list-container').innerHTML = '<div style="grid-column:1/-1; text-align:center;">오류가 발생했습니다.</div>';
      }
    } finally {
      isFetching = false; // 통신 끝! 락 해제
    }
  }

  // 북마크 토글 함수 (기존 코드 그대로 유지)
  window.toggleBookmark = function(event, placeId, btnElement) {
    event.stopPropagation(); 
    fetch('${pageContext.request.contextPath}/accommodation/bookmark', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ placeId: placeId })
    })
    .then(res => res.json())
    .then(data => {
        if (!data.success) {
            alert(data.message);
            if (data.message.includes('로그인')) location.href = '${pageContext.request.contextPath}/member/login';
            return;
        }
        const svg = btnElement.querySelector('svg');
        if (data.isBookmarked) {
            svg.setAttribute('fill', '#4A44F2'); svg.setAttribute('stroke', '#4A44F2');
        } else {
            svg.setAttribute('fill', 'none'); svg.setAttribute('stroke', 'white');
        }
    })
    .catch(err => console.error(err));
  };

  // 1. 페이지 로드 시 최초 1회 데이터 요청
  document.addEventListener("DOMContentLoaded", () => {
    fetchAccommodations(true);
  });

  // 2. 🌟 무한 스크롤 마법의 코드! 스크롤 이벤트 감지
  window.addEventListener('scroll', () => {
      // 문서 전체 높이에서 (현재 스크롤 위치 + 창 높이)를 뺐을 때 300px 남으면 미리 다음 데이터 호출!
      if (document.documentElement.scrollHeight - (window.scrollY + window.innerHeight) < 300) {
          fetchAccommodations(false); // isReset = false (이어붙이기)
      }
  });
</script>

<jsp:include page="../accommodation/searchModal.jsp" /> 
<jsp:include page="../accommodation/filterModal.jsp" /> 
<jsp:include page="../layout/footer.jsp" />