<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<style>
  .modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.6); z-index: 9990;
    opacity: 0; visibility: hidden; transition: all 0.3s;
    backdrop-filter: blur(2px);
  }
  .modal-overlay.open { opacity: 1; visibility: visible; }

  .custom-modal {
    position: fixed; bottom: 0; left: 50%;
    width: 100%; max-width: 800px; height: 90vh;
    background: white; border-top-left-radius: 24px; border-top-right-radius: 24px;
    z-index: 9999; transform: translateX(-50%) translateY(100%); 
    transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    display: flex; flex-direction: column;
    box-shadow: 0 -10px 40px rgba(0,0,0,0.2);
    overflow: hidden;
  }
  .custom-modal.open { transform: translateX(-50%) translateY(0); }

  .c-modal-header { padding: 20px 24px 10px; text-align: center; position: relative; flex-shrink: 0; }
  .c-modal-title { font-size: 18px; font-weight: 800; color: var(--text-black); }
  .btn-close-modal { 
    position: absolute; right: 20px; top: 20px; 
    font-size: 24px; cursor: pointer; background: none; border: none; padding: 4px; color: var(--text-black);
  }

  .c-search-area { padding: 0 24px 20px; flex-shrink: 0; border-bottom: 1px solid #F1F3F5; }
  
  /* 🌟 검색바(통합된 영역) 스타일 */
  .search-row {
    display: flex; align-items: center; gap: 8px; padding: 12px 4px;
    border-bottom: 1px solid #E2E8F0; cursor: text; transition: border 0.2s;
  }
  .search-row.active { border-bottom: 2px solid var(--text-black); }
  
  .chip-container {
    flex: 1; display: flex; gap: 8px; overflow-x: auto; flex-wrap: nowrap;
    align-items: center; height: 42px; padding-bottom: 4px;
  }
  .chip-container::-webkit-scrollbar { height: 4px; }
  .chip-container::-webkit-scrollbar-thumb { background: #CBD5E0; border-radius: 4px; }
  .chip-container::-webkit-scrollbar-track { background: transparent; }
  
  .search-chip {
    background: #F1F3F5; padding: 8px 14px; border-radius: 20px;
    font-size: 14px; font-weight: 700; color: var(--text-black);
    display: flex; align-items: center; gap: 8px; white-space: nowrap; flex-shrink: 0;
  }
  .btn-chip-close {
    cursor: pointer; color: #A0AEC0; font-size: 16px; display: flex; align-items: center; justify-content: center;
    width: 20px; height: 20px; border-radius: 50%;
  }
  .btn-chip-close:hover { background: rgba(0,0,0,0.1); color: #E53E3E; }
  
  /* 🌟 검색창(input)이 칩 옆에 자연스럽게 위치하도록 설정 */
  #tsInput {
    flex: 1; min-width: 150px; border: none; outline: none; background: transparent;
    font-size: 15px; font-weight: 600; color: var(--text-black); padding: 4px 0;
  }
  #tsInput::placeholder { color: #A0AEC0; font-weight: 600; font-size: 15px; }

  .btn-ts-search { background: none; border: none; font-size: 15px; font-weight: 800; color: var(--text-black); cursor: pointer; white-space: nowrap; padding: 0 8px; margin-left: auto; }
  .btn-ts-search:hover { color: var(--point-blue); }

  .filter-row { display: flex; justify-content: space-between; margin-top: 12px; }
  .filter-tab {
    display: flex; align-items: center; gap: 8px; padding: 8px 4px;
    font-size: 15px; font-weight: 600; color: var(--text-dark); cursor: pointer; flex: 1;
  }
  .filter-tab:hover { color: var(--point-blue); }
  .filter-tab.active { color: var(--point-blue); font-weight: 800; }

  .c-modal-body { flex: 1; overflow-y: auto; padding: 24px; scrollbar-width: thin; position: relative; }
  
  .view-section { display: none; animation: fadeIn 0.3s ease-out; }
  .view-section.active { display: block; }
  @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

  /* 최근 검색어 스타일 */
  .ts-recent-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
  .ts-recent-header span { font-size: 15px; font-weight: 800; color: var(--text-black); }
  .ts-recent-header button { background: none; border: none; color: #A0AEC0; font-size: 13px; cursor: pointer; text-decoration: underline; }
  .ts-recent-list { list-style: none; padding: 0; margin: 0; }
  .ts-recent-item { display: flex; align-items: center; gap: 12px; padding: 16px 0; border-bottom: 1px solid #F8F9FA; cursor: pointer; }
  .ts-recent-item:hover { background: #FAFAFA; }
  .ts-recent-item svg { color: #A0AEC0; }
  .ts-recent-text { flex: 1; font-size: 15px; font-weight: 600; color: var(--text-dark); }
  .ts-recent-del { background: none; border: none; color: #CBD5E0; cursor: pointer; font-size: 18px; display: flex; align-items: center; justify-content: center; }
  .ts-recent-del:hover { color: #E53E3E; }

  /* 지역 탭 CSS */
  .region-section-header { 
      font-size: 16px; font-weight: 800; color: var(--text-black); 
      margin-bottom: 24px; padding-bottom: 12px; border-bottom: 2px solid var(--text-black); display: inline-block; 
  }
  .region-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 32px; }
  .region-btn {
    display: flex; justify-content: center; align-items: center; height: 46px; border-radius: 23px;
    background: #F5F7FA; font-size: 14px; font-weight: 600; color: var(--text-dark);
    cursor: pointer; transition: all 0.2s; text-align: center;
  }
  .region-btn:hover { background: #E9ECEF; }
  .region-btn.selected { background: var(--text-black); color: white; box-shadow: 0 4px 10px rgba(0,0,0,0.15); }

  /* 달력 & 인원 CSS */
  .calendar-container { text-align: center; padding-bottom: 40px; }
  .month-block { margin-bottom: 40px; }
  .month-title { font-size: 18px; font-weight: 900; margin-bottom: 20px; text-align: center; color: var(--text-black); }
  .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); row-gap: 12px; }
  .day-header { font-size: 14px; color: var(--text-gray); font-weight: 600; padding-bottom: 8px; }
  .day-header.sun { color: #E53E3E; }
  .day-header.sat { color: var(--point-blue); }
  .day-cell { aspect-ratio: 1/1; display: flex; justify-content: center; align-items: center; font-size: 15px; font-weight: 600; cursor: pointer; position: relative; border-radius: 50%; z-index: 1; }
  .day-cell:not(.empty):hover { background: #F7FAFC; font-weight: 800; }
  .day-cell.empty { cursor: default; }
  .day-cell.selected { background: var(--point-blue); color: white; border-radius: 50%; box-shadow: 0 4px 10px rgba(137, 207, 240, 0.4); }
  .day-cell.range { background: var(--bg-beige); color: var(--text-black); border-radius: 0; }
  .day-cell.range-start { background: var(--point-blue); color: white; border-radius: 50%; position: relative; }
  .day-cell.range-start::before { content: ''; position: absolute; z-index: -1; top: 0; right: 0; bottom: 0; left: 50%; background: var(--bg-beige); }
  .day-cell.range-end { background: var(--point-blue); color: white; border-radius: 50%; position: relative; }
  .day-cell.range-end::before { content: ''; position: absolute; z-index: -1; top: 0; right: 50%; bottom: 0; left: 0; background: var(--bg-beige); }

  .guest-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 0; border-bottom: 1px solid #F1F3F5; }
  .guest-info h4 { font-size: 16px; font-weight: 800; margin-bottom: 4px; color: var(--text-black); }
  .guest-info p { font-size: 13px; color: var(--text-gray); }
  .counter-box { display: flex; align-items: center; gap: 16px; }
  .btn-count { width: 32px; height: 32px; border-radius: 50%; border: 1px solid #E2E8F0; background: white; display: flex; justify-content: center; align-items: center; font-size: 18px; color: var(--text-gray); cursor: pointer; transition: all 0.2s; }
  .btn-count:hover { border-color: var(--point-blue); color: var(--point-blue); }
  .btn-count.active { border-color: var(--text-black); color: var(--text-black); font-weight: 700; }
  .count-val { font-size: 18px; font-weight: 800; width: 20px; text-align: center; }

  .c-modal-footer { padding: 16px 24px 32px; border-top: 1px solid #F1F3F5; display: flex; justify-content: space-between; align-items: center; background: white; flex-shrink: 0; }
  .btn-reset { font-size: 14px; font-weight: 600; color: var(--text-gray); background: none; text-decoration: underline; cursor: pointer; border: none; }
  .btn-search-black { background: var(--text-black); color: white; padding: 14px 40px; border-radius: 100px; border: none; font-size: 15px; font-weight: 800; cursor: pointer; transition: background 0.3s; }
  .btn-search-black:hover { background: var(--point-blue); }

  @media (max-width: 768px) {
    .custom-modal { max-width: 100%; height: 95vh; border-radius: 20px 20px 0 0; }
    .region-grid { grid-template-columns: repeat(3, 1fr); }
  }
</style>

<div class="modal-overlay" id="modalOverlay" onclick="closeModal()"></div>
<div class="custom-modal" id="customModal">
  <div class="c-modal-header">
    <div class="c-modal-title">어디로 떠날까요?</div>
    <button class="btn-close-modal" onclick="closeModal()">✕</button>
  </div>

  <div class="c-search-area">
    <c:if test="${param.hideRegion != 'true'}">
        <div class="search-row active" id="headerRegion" onclick="document.getElementById('tsInput').focus(); switchView('region');">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#718096" stroke-width="2" style="flex-shrink:0;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          <div class="chip-container" id="chipContainer">
            <input type="text" id="tsInput" placeholder="떠나고 싶은 지역, 숙소를 찾아보세요" onkeypress="handleTsEnter(event)" autocomplete="off">
          </div>
          <button class="btn-ts-search" onclick="executeTextSearch(event)">검색</button>
          <div style="color:#CBD5E0; cursor: pointer; margin-left:4px; padding: 4px;" onclick="clearRegions(event)">✕</div>
        </div>
    </c:if>

    <div class="filter-row">
      <div class="filter-tab" id="headerDate" onclick="switchView('date')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span id="dateText">일정</span>
      </div>
      <div class="filter-tab" id="headerGuest" onclick="switchView('guest')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        <span id="guestText">인원</span>
      </div>
    </div>
  </div>
    
  <div class="c-modal-body">
    <c:if test="${param.hideRegion != 'true'}">
        <div id="viewRegion" class="view-section active">
          
          <div id="recentSearchArea" style="margin-bottom: 32px; display: none;">
            <div class="ts-recent-header">
                <span>최근 검색</span>
                <button onclick="clearAllRecentSearches()">전체삭제</button>
            </div>
            <ul class="ts-recent-list" id="tsRecentList"></ul>
          </div>

          <div class="region-section-header">국내</div>
          <div class="region-grid" id="majorRegionGrid">
            <div class="region-btn" onclick="toggleRegion('전체')">전체</div>
            <div class="region-btn" onclick="toggleRegion('서울')">서울</div>
            <div class="region-btn" onclick="toggleRegion('제주')">제주</div>
            <div class="region-btn" onclick="toggleRegion('강원')">강원</div>
            <div class="region-btn" onclick="toggleRegion('강릉')">강릉</div>
            <div class="region-btn" onclick="toggleRegion('춘천')">춘천</div>
            <div class="region-btn" onclick="toggleRegion('양양')">양양</div>
            <div class="region-btn" onclick="toggleRegion('부산')">부산</div>
            <div class="region-btn" onclick="toggleRegion('경상')">경상</div>
            <div class="region-btn" onclick="toggleRegion('경주')">경주</div>
            <div class="region-btn" onclick="toggleRegion('전라')">전라</div>
            <div class="region-btn" onclick="toggleRegion('전주')">전주</div>
            <div class="region-btn" onclick="toggleRegion('남원')">남원</div>
            <div class="region-btn" onclick="toggleRegion('경기')">경기</div>
            <div class="region-btn" onclick="toggleRegion('양평')">양평</div>
            <div class="region-btn" onclick="toggleRegion('가평')">가평</div>
            <div class="region-btn" onclick="toggleRegion('인천')">인천</div>
            <div class="region-btn" onclick="toggleRegion('충청')">충청</div>
	      </div>
        </div>
    </c:if>

    <div id="viewDate" class="view-section">
      <div class="calendar-container" id="calendarContainer"></div>
    </div>

    <div id="viewGuest" class="view-section">
      <div class="guest-row">
        <div class="guest-info"><h4>성인</h4><p>만 13세 이상</p></div>
        <div class="counter-box">
          <div class="btn-count" onclick="updateGuest('adult', -1)">-</div>
          <span class="count-val" id="cnt-adult">0</span>
          <div class="btn-count" onclick="updateGuest('adult', 1)">+</div>
        </div>
      </div>
      <div class="guest-row">
        <div class="guest-info"><h4>아동</h4><p>12세 이하</p></div>
        <div class="counter-box">
          <div class="btn-count" onclick="updateGuest('child', -1)">-</div>
          <span class="count-val" id="cnt-child">0</span>
          <div class="btn-count" onclick="updateGuest('child', 1)">+</div>
        </div>
      </div>
    </div>
  </div>

  <div class="c-modal-footer">
    <button class="btn-reset" onclick="resetAll()">초기화</button>
    <button class="btn-search-black" onclick="submitSearch()">검색</button>
  </div>
</div>

<script>
  // --- 유틸리티 ---
  const getDisplayDate = dateStr => {
    const [y, m, d] = dateStr.split('-');
    return `\${m}.\${d}`;
  };

  // --- 상태 관리 변수 ---
  let selectedRegions = []; 
  let selectedDates = [];
  let guests = { adult: 0, child: 0 }; 

  document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    
    const regionParam = params.get('regions');
    if (regionParam) {
      selectedRegions = decodeURIComponent(regionParam).split(',');
      renderChips(); 
      refreshGridHighlight(); 
    }

    const checkin = params.get('checkin');
    const checkout = params.get('checkout');
    if (checkin && checkout) {
      selectedDates = [checkin, checkout];
    }

    const adult = parseInt(params.get('adult')) || 1;
    const child = parseInt(params.get('child')) || 0;
    guests.adult = adult;
    guests.child = child;
    
    if(document.getElementById('cnt-adult')) {
      document.getElementById('cnt-adult').innerText = adult;
      document.getElementById('cnt-child').innerText = child;
      updateGuestBtnState('adult', adult);
      updateGuestBtnState('child', child);
    }
    updateHeaderText();
  });

  function updateGuestBtnState(type, val) {
      const el = document.getElementById(`cnt-\${type}`);
      if(!el) return;
      const btnBox = el.parentNode;
      const minusBtn = btnBox.querySelector('.btn-count:first-child');
      if (val > 0) minusBtn.classList.add('active');
      else minusBtn.classList.remove('active');
  }

  // --- 모달 제어 ---
  function openModal(viewType) {
    document.getElementById('modalOverlay').classList.add('open');
    document.getElementById('customModal').classList.add('open');
    document.body.style.overflow = 'hidden';

    if(document.getElementById('calendarContainer').innerHTML.trim() === "") {
      renderCalendar();
    }
    
    updateCalendarUI();
    renderRecentSearches(); 
    
    let targetView = viewType || 'region';
    <c:if test="${param.hideRegion == 'true'}">
        if (targetView === 'region') targetView = 'date';
    </c:if>
    
    switchView(targetView);
  }

  function closeModal() {
    document.getElementById('modalOverlay').classList.remove('open');
    document.getElementById('customModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  function switchView(viewName) {
    const headerRegion = document.getElementById('headerRegion');
    const viewRegion = document.getElementById('viewRegion');

    if(headerRegion) headerRegion.classList.remove('active');
    document.getElementById('headerDate').classList.remove('active');
    document.getElementById('headerGuest').classList.remove('active');

    if(viewName === 'region' && headerRegion) headerRegion.classList.add('active');
    else if(viewName === 'date') document.getElementById('headerDate').classList.add('active');
    else if(viewName === 'guest') document.getElementById('headerGuest').classList.add('active');

    document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
    
    if(viewName === 'region' && viewRegion) viewRegion.classList.add('active');
    else if(viewName === 'date') document.getElementById('viewDate').classList.add('active');
    else if(viewName === 'guest') document.getElementById('viewGuest').classList.add('active');
  }


  // 🌟 최근 검색어 및 직접 검색 통합 로직 🌟
  function getRecentSearches() {
      try {
          let data = JSON.parse(localStorage.getItem('recentSearches') || '[]');
          // 문자열(키워드)만 깔끔하게 빼옵니다.
          return data.map(item => typeof item === 'object' ? item.keyword : item).filter(Boolean);
      } catch(e) {
          return [];
      }
  }
  
  function saveRecentSearch(keyword) {
      if(!keyword.trim()) return;
      let searches = getRecentSearches();
      searches = searches.filter(s => s !== keyword); 
      searches.unshift(keyword); 
      if(searches.length > 5) searches.pop(); 
      localStorage.setItem('recentSearches', JSON.stringify(searches));
  }

  function handleTsEnter(e) {
      if(e.key === 'Enter' || e.keyCode === 13) {
          e.preventDefault();
          executeTextSearch();
      }
  }

  function executeTextSearch(e) {
      if(e) { e.preventDefault(); e.stopPropagation(); }
      
      const val = document.getElementById('tsInput').value.trim();
      if(val) {
          saveRecentSearch(val);
          selectedRegions = [val]; 
          document.getElementById('tsInput').value = '';
          renderChips();
          refreshGridHighlight();
      }
      
      if(selectedRegions.length > 0) {
          submitSearch(); 
      } else {
          document.getElementById('tsInput').focus();
      }
  }
  
  function clickRecentSearch(keyword) {
      selectedRegions = [keyword];
      renderChips();
      refreshGridHighlight();
      saveRecentSearch(keyword); 
      submitSearch();
  }
  
  function deleteRecentSearch(e, keyword) {
      e.stopPropagation();
      let searches = getRecentSearches().filter(s => s !== keyword);
      localStorage.setItem('recentSearches', JSON.stringify(searches));
      renderRecentSearches();
  }
  
  function clearAllRecentSearches() {
      localStorage.removeItem('recentSearches');
      renderRecentSearches();
  }
  
  function renderRecentSearches() {
      const list = document.getElementById('tsRecentList');
      const area = document.getElementById('recentSearchArea');
      const searches = getRecentSearches();
      
      if (!list || !area) return;
      
      if(searches.length === 0) {
          area.style.display = 'none';
          return;
      }
      
      area.style.display = 'block';
      list.innerHTML = searches.map(keyword => `
          <li class="ts-recent-item" onclick="clickRecentSearch('\${keyword}')">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
              <div style="flex:1;">
                  <div class="ts-recent-text">\${keyword}</div>
              </div>
              <button class="ts-recent-del" onclick="deleteRecentSearch(event, '\${keyword}')">✕</button>
          </li>
      `).join('');
  }

  // --- [로직 1] 지역 (타일 & 칩 연동) ---
  function toggleRegion(name) {
    if (selectedRegions.includes(name)) {
      selectedRegions = [];
    } else {
      selectedRegions = [name];
    }
    document.getElementById('tsInput').value = ''; 
    renderChips();
    refreshGridHighlight();
  }

  function refreshGridHighlight() {
    const subBtns = document.querySelectorAll('#majorRegionGrid .region-btn');
    subBtns.forEach(btn => {
      if(selectedRegions.includes(btn.innerText)) btn.classList.add('selected');
      else btn.classList.remove('selected');
    });
  }

  // 🌟 입력창을 유지한 채 칩만 자연스럽게 추가/삭제하는 렌더링 함수
  function renderChips() {
    const container = document.getElementById('chipContainer');
    const input = document.getElementById('tsInput');
    
    container.querySelectorAll('.search-chip').forEach(el => el.remove());

    if (selectedRegions.length > 0) {
      input.placeholder = ""; 
      selectedRegions.forEach(region => {
        const chip = document.createElement('div');
        chip.className = 'search-chip';
        chip.innerHTML = `\${region} <div class="btn-chip-close" onclick="removeRegion('\${region}', event)">✕</div>`;
        container.insertBefore(chip, input);
      });
    } else {
      input.placeholder = "떠나고 싶은 지역, 숙소를 찾아보세요";
    }
  }

  function removeRegion(name, e) {
    if(e) { e.preventDefault(); e.stopPropagation(); }
    const index = selectedRegions.indexOf(name);
    if (index > -1) selectedRegions.splice(index, 1);
    renderChips();
    refreshGridHighlight();
  }

  function clearRegions(e) {
    if(e) { e.preventDefault(); e.stopPropagation(); }
    selectedRegions = [];
    document.getElementById('tsInput').value = ''; 
    renderChips();
    refreshGridHighlight();
  }

  // --- [로직 2] 달력 ---
  function renderCalendar() {
    const container = document.getElementById('calendarContainer');
    const now = new Date();
    
    const today = new Date();
    const tYear = today.getFullYear();
    const tMonth = String(today.getMonth() + 1).padStart(2, '0');
    const tDate = String(today.getDate()).padStart(2, '0');
    const todayStr = `\${tYear}-\${tMonth}-\${tDate}`; 

    let html = '';
    for (let i = 0; i <= 12; i++) {
      let currentMonth = new Date(now.getFullYear(), now.getMonth() + i, 1);
      let year = currentMonth.getFullYear();
      let month = currentMonth.getMonth();
      
      html += `<div class="month-block">
                 <div class="month-title">\${year}년 \${month + 1}월</div>
                 <div class="calendar-grid">
                   <div class="day-header sun">일</div><div class="day-header">월</div><div class="day-header">화</div>
                   <div class="day-header">수</div><div class="day-header">목</div><div class="day-header">금</div><div class="day-header sat">토</div>`;
      
      let firstDay = new Date(year, month, 1).getDay();
      for(let j=0; j<firstDay; j++) html += `<div class="day-cell empty"></div>`;
      
      let daysInMonth = new Date(year, month + 1, 0).getDate();
      for(let d=1; d<=daysInMonth; d++) {
         let mStr = String(month+1).padStart(2,'0');
         let dStr = String(d).padStart(2,'0');
         let dateStr = `\${year}-\${mStr}-\${dStr}`;
         
         let isBooked = window.disabledDates && window.disabledDates.includes(dateStr);
         if (dateStr < todayStr) {
             html += `<div class="day-cell disabled" style="color:#CBD5E0; cursor:not-allowed;">\${d}</div>`;
         } else if (isBooked) {
             html += `<div class="day-cell disabled" style="color:#A0AEC0; background:#F7FAFC; cursor:not-allowed; text-decoration:line-through;" title="예약 마감">\${d}</div>`;
         } else {
             html += `<div class="day-cell" data-date="\${dateStr}" onclick="selectDate(this)">\${d}</div>`;
         }
       }
      html += `</div></div>`;
    }
    container.innerHTML = html;
  }

  function selectDate(el) {
    const date = el.dataset.date;
    if (selectedDates.length === 2) selectedDates = []; 
    
    if (selectedDates.length === 0) {
        selectedDates.push(date);
    } else {
    	
    	if (selectedDates[0] === date) {
            selectedDates = [date]; 
            updateCalendarUI();
            updateHeaderText();
            return;
        }
    	
        const start = selectedDates[0] < date ? selectedDates[0] : date;
        const end = selectedDates[0] < date ? date : selectedDates[0];
        
        let hasBookedInBetween = false;
        if (window.disabledDates) {
            for (let d of window.disabledDates) {
                if (d >= start && d < end) {
                    hasBookedInBetween = true;
                    break;
                }
            }
        }

        if (hasBookedInBetween) {
            alert("선택하신 기간 내에 예약이 마감된 날짜가 포함되어 있습니다.");
            selectedDates = [date]; 
        } else {
            selectedDates = [start, end];
        }
    }
    
    updateCalendarUI();
    updateHeaderText();
  }

  function updateCalendarUI() {
    document.querySelectorAll('.day-cell').forEach(el => {
      el.className = 'day-cell'; 
      if(el.classList.contains('empty')) el.classList.add('empty');

      const d = el.dataset.date;
      if (!d) return;

      if(selectedDates.includes(d)) el.classList.add('selected');
      
      if(selectedDates.length === 2) {
        if(d > selectedDates[0] && d < selectedDates[1]) el.classList.add('range');
        if(d === selectedDates[0]) el.classList.add('range-start');
        if(d === selectedDates[1]) el.classList.add('range-end');
      }
    });
  }

  // --- [로직 3] 인원 ---
  function updateGuest(type, delta) {
    let newVal = guests[type] + delta;
    if (newVal < 0) return;
    
    guests[type] = newVal;
    document.getElementById(`cnt-\${type}`).innerText = newVal;
    updateGuestBtnState(type, newVal);

    updateHeaderText();
  }

  function updateHeaderText() {
    const dateText = document.getElementById('dateText');
    if (selectedDates.length === 2) {
      const d1 = new Date(selectedDates[0]);
      const d2 = new Date(selectedDates[1]);
      const diffTime = Math.abs(d2 - d1);
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      
      dateText.innerText = `\${diffDays}박 \${getDisplayDate(selectedDates[0])} ~ \${getDisplayDate(selectedDates[1])}`;
      dateText.style.color = "var(--text-black)";
      dateText.style.fontWeight = "800";
    } else if (selectedDates.length === 1) {
      dateText.innerText = `\${getDisplayDate(selectedDates[0])} ~`;
    } else {
      dateText.innerText = "일정";
      dateText.style.color = "var(--text-dark)";
      dateText.style.fontWeight = "600";
    }

    const guestText = document.getElementById('guestText');
    const total = guests.adult + guests.child;
    if (total > 0) {
      guestText.innerText = `\${total}명`;
      guestText.style.color = "var(--text-black)";
      guestText.style.fontWeight = "800";
    } else {
      guestText.innerText = "인원";
      guestText.style.color = "var(--text-dark)";
      guestText.style.fontWeight = "600";
    }
  }

  //--- 검색 제출 ---
  function submitSearch() {
    let params = [];
    let hasRegion = false; 
    
    if(selectedRegions.length > 0 && !selectedRegions.includes('전국') && !selectedRegions.includes('전체')) {
      const optimizedRegions = selectedRegions.map(r => r.replace(' 전체', ''));
      params.push('regions=' + encodeURIComponent(optimizedRegions.join(',')));
      hasRegion = true;
    }
    
    if(selectedDates.length === 2) {
      params.push('checkin=' + selectedDates[0]);
      params.push('checkout=' + selectedDates[1]);
    }
    
    if (guests.adult > 0 || guests.child > 0) {
        params.push(`adult=\${guests.adult}&child=\${guests.child}`);
    }
    
    let url = '${pageContext.request.contextPath}/accommodation/list';
    
    if (window.location.pathname.includes('/detail/') && !hasRegion) {
        url = window.location.pathname;
    }

    if(params.length > 0) {
        url += '?' + params.join('&');
    }
    location.href = url;
  }
  
  function resetAll() {
     clearRegions();
     selectedDates = [];
     guests = { adult: 0, child: 0 };
     
     document.getElementById('cnt-adult').innerText = 1;
     document.getElementById('cnt-child').innerText = 0;
     
     document.querySelectorAll('.btn-count').forEach(b => b.classList.remove('active'));
     updateCalendarUI();
     updateHeaderText();
  }
</script>