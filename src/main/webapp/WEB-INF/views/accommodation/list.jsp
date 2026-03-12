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
  /* --- 메인 컨테이너 --- */
  .list-container { max-width: 1400px; margin: 160px auto 100px; padding: 0 40px; transition: all 0.3s ease; }
  
  /* 지도 모드일 때 화면을 넓게 쓰기 위함 */
  .list-container.map-mode { max-width: 100%; padding: 0 20px; margin-top: 130px; }

  /* --- 통합 검색바 --- */
  .list-search-bar { position: relative; display: flex; justify-content: center; margin-bottom: 30px; }
  .unified-search-bar { display: flex; align-items: center; background: white; border: 1px solid #E2E8F0; border-radius: 100px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); padding: 4px; transition: all 0.3s ease; }
  .unified-search-bar:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
  .search-segment { display: flex; align-items: center; gap: 12px; padding: 14px 32px; cursor: pointer; position: relative; color: var(--text-black); font-size: 15px; font-weight: 700; transition: background 0.2s; border-radius: 50px; }
  .search-segment:hover { background-color: #F8F9FA; }
  .search-segment svg { width: 20px; height: 20px; color: var(--text-gray); }
  .search-segment.active { color: var(--point-blue); }
  .search-segment.active svg { color: var(--point-blue); }
  .search-segment:not(:last-child)::after { content: ''; position: absolute; right: 0; top: 25%; height: 50%; width: 1px; background-color: #E2E8F0; }

  .btn-filter-icon { position: absolute; right: 0; top: 50%; transform: translateY(-50%); width: 48px; height: 48px; border-radius: 50%; border: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: center; cursor: pointer; background: white; transition: all 0.2s; }
  .btn-filter-icon:hover { background: #F7FAFC; border-color: var(--text-black); }

  /* --- 🌟 카테고리 알약(Pill) 디자인 --- */
  .category-nav { 
    display: flex; 
    gap: 12px; 
    overflow-x: auto; /* 가로 스크롤은 유지 */
    overflow-y: hidden; /* 🌟 0.1px의 세로 넘침도 허용하지 않음 (스크롤바 박멸!) */
    padding: 10px 4px 15px; 
    margin-bottom: 20px; 
    align-items: center;
    white-space: nowrap; /* 아이템들이 아래로 떨어지지 않게 고정 */

    scrollbar-width: thin; 
    scrollbar-color: #cbd5e0 transparent;
    
    -ms-overflow-style: -ms-autohiding-scrollbar;
  }

  .category-nav::-webkit-scrollbar:vertical {
    display: none !important;
  }

  .category-nav::-webkit-scrollbar {
    height: 4px; /* 가로 스크롤바 두께 */
    display: block; /* 숨김 해제 */
  }

  .category-nav::-webkit-scrollbar-track {
    background: transparent; 
  }

  .category-nav::-webkit-scrollbar-thumb {
    background: #e2e8f0; /* 아주 연한 회색 */
    border-radius: 10px;
    transition: background 0.3s;
  }

  .category-nav:hover::-webkit-scrollbar-thumb {
    background: #cbd5e0; /* 조금 더 진한 회색 */
  }

  .cat-item { 
    display: flex; 
    align-items: center; 
    justify-content: center; 
    gap: 8px; 
    padding: 10px 22px; 
    border-radius: 50px; /* 완전한 알약 모양 */
    border: 1px solid #eee; 
    cursor: pointer; 
    background: white; 
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
    white-space: nowrap;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04); /* 은은한 그림자 추가 */
  }

  .cat-item span { 
    font-size: 14px; 
    font-weight: 600; 
    color: #4A5568; 
    letter-spacing: -0.3px; /* 글자 간격 조절로 가독성 향상 */
  }

  /* 마우스 올렸을 때 효과 */
  .cat-item:hover { 
    border-color: #cbd5e0;
    transform: translateY(-2px); /* 살짝 떠오르는 느낌 */
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  }

  /* 활성화된 상태 (검정색 알약) */
  .cat-item.active { 
    background: #1A202C; 
    border-color: #1A202C; 
    box-shadow: 0 4px 14px rgba(26, 32, 44, 0.25);
  }

  .cat-item.active span { 
    color: white; 
    font-weight: 700;
  }

  /* --- 🌟 레이아웃 래퍼 --- */
  .content-wrapper { display: flex; width: 100%; transition: all 0.3s ease; gap: 24px; }
  .list-container.map-mode .content-wrapper { height: calc(100vh - 220px); overflow: hidden; }

  /* --- 왼쪽 리스트 패널 --- */
  .left-panel { flex: 1; transition: all 0.3s ease; display: flex; flex-direction: column; }
  .list-container.map-mode .left-panel { width: 480px; flex: none; height: 100%; overflow: hidden; display: flex; flex-direction: column; }

  /* 그리드 */
  .accommodation-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 40px 32px; }
  .list-container.map-mode .accommodation-grid { grid-template-columns: 1fr; overflow-y: auto; padding-right: 16px; align-content: start; height: 100%; }
  
  /* 숙소 카드 */
  .accommodation-item { cursor: pointer; transition: transform 0.2s; display: flex; flex-direction: column; height: 100%; position: relative; }
  .accommodation-item:hover { transform: translateY(-4px); }
  .accommodation-thumb { width: 100%; aspect-ratio: 4/3; border-radius: 16px; overflow: hidden; margin-bottom: 16px; position: relative; background: #eee; }
  .accommodation-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
  .accommodation-item:hover .accommodation-thumb img { transform: scale(1.05); }
  .accommodation-meta { position: relative; display: flex; flex-direction: column; flex: 1; }
  .accommodation-meta h3 { font-size: 18px; font-weight: 800; margin-bottom: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; padding-right: 80px; }
  .accommodation-desc { font-size: 14px; color: var(--text-gray); margin-bottom: 8px; }
  .accommodation-price { font-size: 17px; font-weight: 800; margin-top: auto; }

  /* --- 🌟 위치보기 버튼 --- */
  .btn-view-location { display: none; position: absolute; right: 0; bottom: 0; background: white; border: 1px solid #E2E8F0; color: var(--text-black); border-radius: 6px; padding: 6px 14px; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.2s; z-index: 10; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
  .btn-view-location:hover { background: #F8F9FA; border-color: var(--text-black); }
  .list-container.map-mode .btn-view-location { display: block; }

  /* --- 🌟 오른쪽 지도 영역 --- */
  #map-wrapper { display: none; flex: 1; border-radius: 16px; position: relative; overflow: hidden; background: #E2E8F0; }
  .list-container.map-mode #map-wrapper { display: block; }
  
  /* 지도 닫기 버튼 */
  .btn-close-map { position: absolute; top: 20px; right: 20px; z-index: 10; background: white; border: 1px solid #E2E8F0; border-radius: 30px; padding: 10px 20px; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15); transition: all 0.2s; color: var(--text-black); }
  .btn-close-map:hover { background: #F8F9FA; transform: translateY(-2px); }

  /* 플로팅 지도 열기 버튼 */
  .btn-floating-map { position: fixed; bottom: 40px; left: 50%; transform: translateX(-50%); background: #111; color: white; border: none; border-radius: 30px; padding: 12px 24px; font-size: 15px; font-weight: 800; display: flex; align-items: center; gap: 8px; cursor: pointer; z-index: 100; box-shadow: 0 4px 12px rgba(0,0,0,0.3); transition: background 0.2s; }
  .btn-floating-map:hover { background: #333; }
  .list-container.map-mode ~ .btn-floating-map { display: none; }

  @media (max-width: 992px) { 
    .accommodation-grid { grid-template-columns: repeat(2, 1fr); } 
    .unified-search-bar { width: 100%; justify-content: space-between; }
    .btn-filter-icon { position: static; transform: none; margin-left: 12px; }
    .list-search-bar { justify-content: space-between; }
    .list-container.map-mode .left-panel { width: 350px; }
  }
  @media (max-width: 600px) { 
    .accommodation-grid { grid-template-columns: 1fr; } 
    .list-container { padding: 0 20px; margin-top: 120px; } 
    .search-segment span { display: none; }
  }
</style>

<main class="list-container reveal active" id="mainContainer">
  
  <div class="list-search-bar">
    <div class="unified-search-bar">
      <div class="search-segment ${not empty param.regions ? 'active' : ''}" onclick="openModal('region')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <span>${not empty param.regions ? param.regions : '어디로 떠날까요?'}</span>
      </div>
      
      <div class="search-segment ${not empty param.checkin ? 'active' : ''}" onclick="openModal('date')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span>
          <c:choose>
             <c:when test="${not empty param.checkin}">${nightCnt}박 ${inStr}(${inDay}) - ${outStr}(${outDay})</c:when>
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

  <div class="content-wrapper">
      
      <div class="left-panel">
          <div class="category-nav">
            <div class="cat-item active"><span>모든 스테이</span></div>
            <div class="cat-item"><span>봄꽃여행</span></div>
            <div class="cat-item"><span>프로모션</span></div>
            <div class="cat-item"><span>신규 오픈</span></div>
            <div class="cat-item"><span>마감임박할인</span></div>
            <div class="cat-item"><span>단독 소개</span></div>
          </div>
          <div class="accommodation-grid" id="accommodation-list-container"></div>
      </div>
      
      <div id="map-wrapper">
          <button class="btn-close-map" onclick="toggleMapView()">닫기 ✕</button>
          <div id="kakao-map" style="width:100%; height:100%;"></div>
      </div>
  </div>

</main>

<button class="btn-floating-map" onclick="toggleMapView()">
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"></polygon><line x1="8" y1="2" x2="8" y2="18"></line><line x1="16" y1="6" x2="16" y2="22"></line></svg>
  <span id="mapBtnText">지도</span>
</button>

<script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoApiKey}"></script>

<script>
  let currentOffset = 0;   
  const PAGE_SIZE = 9;      
  let isFetching = false;  
  let hasMore = true;      

  let isMapMode = false;
  let mapInstance = null;
  let markers = [];
  let currentList = []; 

  window.renderAccommodations = function(list, isAppend) {
    const container = document.getElementById('accommodation-list-container');
    const currentQueryString = window.location.search;
    
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
            
            <button class="btn-view-location" onclick="panToMap(\${item.latitude}, \${item.longitude}, event)">위치보기</button>
          </div>
        </div>
      `;
    });
    
    if (isAppend) {
        container.insertAdjacentHTML('beforeend', html);
    } else {
        container.innerHTML = html;
    }
  };

  async function fetchAccommodations(isReset = false) {
    if (isFetching || (!hasMore && !isReset)) return;
    isFetching = true;

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
      
      if (isReset) {
          currentList = data;
      } else {
          currentList = currentList.concat(data);
      }
      
      if (data.length < PAGE_SIZE) {
          hasMore = false; 
      }

      window.renderAccommodations(data, !isReset);
      
      if (isMapMode) {
    	  initOrUpdateMap(isReset);
      }
      
      currentOffset += data.length;
    } catch (error) {
      console.error(error);
      if (isReset) {
        document.getElementById('accommodation-list-container').innerHTML = '<div style="grid-column:1/-1; text-align:center;">오류가 발생했습니다.</div>';
      }
    } finally {
      isFetching = false;
    }
  }

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

  document.addEventListener("DOMContentLoaded", () => {
    fetchAccommodations(true);
  });

  window.addEventListener('scroll', () => {
      if(isMapMode) return; 
      if (document.documentElement.scrollHeight - (window.scrollY + window.innerHeight) < 300) {
          fetchAccommodations(false);
      }
  });
  
  document.querySelector('.left-panel .accommodation-grid').addEventListener('scroll', function() {
      if(!isMapMode) return;
      if (this.scrollHeight - (this.scrollTop + this.clientHeight) < 300) {
          fetchAccommodations(false);
      }
  });

  window.toggleMapView = function() {
      const container = document.getElementById('mainContainer');
      isMapMode = !isMapMode;

      if (isMapMode) {
          container.classList.add('map-mode');
          initOrUpdateMap(true);
      } else {
          container.classList.remove('map-mode');
      }
  };

  function initOrUpdateMap(isReset = true) {
      const mapContainer = document.getElementById('kakao-map');
      
      if (!mapInstance) {
          const options = {
              center: new kakao.maps.LatLng(37.566826, 126.978656), 
              level: 5 
          };
          mapInstance = new kakao.maps.Map(mapContainer, options);
      }
      
      markers.forEach(m => m.setMap(null));
      markers = [];

      if (currentList.length > 0) {
    	  if (isReset) { 
              const firstValidItem = currentList.find(item => item.latitude && item.longitude);
              if (firstValidItem) {
                  mapInstance.setCenter(new kakao.maps.LatLng(firstValidItem.latitude, firstValidItem.longitude));
              }
          }

          currentList.forEach(item => {
              if (item.latitude && item.longitude) {
                  let position = new kakao.maps.LatLng(item.latitude, item.longitude);
                  let marker = new kakao.maps.Marker({
                      map: mapInstance,
                      position: position,
                      title: item.name
                  });
                  markers.push(marker);
              }
          });
      }
      
      setTimeout(() => {
          mapInstance.relayout();
          
          if (isReset && currentList.length > 0) {
              const firstValidItem = currentList.find(item => item.latitude && item.longitude);
              if (firstValidItem) {
                  mapInstance.setCenter(new kakao.maps.LatLng(firstValidItem.latitude, firstValidItem.longitude));
              }
          }
      }, 350);
  }
  
  window.panToMap = function(lat, lng, event) {
      event.stopPropagation(); 
      if(mapInstance && lat && lng) {
          const moveLatLon = new kakao.maps.LatLng(lat, lng);
          mapInstance.panTo(moveLatLon);
      }
  };

</script>

<jsp:include page="../accommodation/searchModal.jsp" /> 
<jsp:include page="../accommodation/filterModal.jsp" /> 
<jsp:include page="../layout/footer.jsp" />