<%@ page contentType="text/html; charset=UTF-8" %>

<style>
  .mate-header { margin-bottom: 24px; }
  .mate-title { font-size: 24px; font-weight: 900; margin: 0 0 8px 0; letter-spacing: -0.5px; }
  .mate-sub { font-size: 14px; color: var(--text-gray); margin: 0; }

  .mate-filter-bar {
    display: flex; flex-direction: column; gap: 16px; background: white; padding: 24px; 
    border-radius: 16px; box-shadow: 0 4px 16px rgba(137, 207, 240, 0.15); 
  }
  
  .filter-row-1 {
    display: flex; gap: 16px; align-items: center; width: 100%; flex-wrap: wrap;
  }
  .mate-select { 
    flex: 1; 
    min-width: 150px;
    padding: 14px 16px; border: 1px solid var(--border-color); border-radius: 8px;
    font-family: 'Pretendard', sans-serif; font-size: 15px; outline: none;
    color: var(--text-dark); background: #F8FAFC; cursor: pointer; transition: 0.2s;
  }
  .date-group {
    flex: 2; 
    display: flex; align-items: center; gap: 12px;
  }
  .mate-date { 
    flex: 1;
    padding: 14px 16px; border: 1px solid var(--border-color); border-radius: 8px;
    font-family: 'Pretendard', sans-serif; font-size: 15px; outline: none;
    color: var(--text-dark); background: #F8FAFC; cursor: pointer; transition: 0.2s;
  }

  .filter-row-2 { 
    display: flex; width: 100%; align-items: stretch; height: 50px;
  }
  .mate-input {
    flex: 1; padding: 0 20px; border: 1px solid var(--border-color); 
    border-radius: 8px 0 0 8px; border-right: none;
    font-family: 'Pretendard', sans-serif; font-size: 15px; outline: none;
    color: var(--text-dark); background: #F8FAFC; transition: 0.2s;
  }
  .mate-input::placeholder { color: #A0AEC0; }
  
  .btn-search-bar {
    background: var(--sky-blue); color: white; border: none; padding: 0 32px;
    border-radius: 0 8px 8px 0; font-weight: 900; font-size: 16px; cursor: pointer;
    transition: 0.2s; white-space: nowrap;
  }
  .btn-search-bar:hover { background: #72bde0; }
  
  .mate-select:focus, .mate-date:focus, .mate-input:focus { 
    border-color: var(--sky-blue); 
    box-shadow: 0 0 0 3px rgba(137, 207, 240, 0.2);
    background: white;
  }

  .filter-row-3 {
    display: flex; justify-content: flex-end; width: 100%; padding-top: 4px;
  }
  .btn-write-mate {
    background: var(--grad-main); color: white; border: none; padding: 12px 28px;
    border-radius: 24px; font-weight: 800; font-size: 15px; cursor: pointer;
    box-shadow: 0 4px 12px rgba(137, 207, 240, 0.3); transition: 0.2s;
  }
  .btn-write-mate:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(137, 207, 240, 0.5); }

  .mate-list { display: flex; flex-direction: column; gap: 16px; }
  .mate-card { 
    display: flex; flex-direction: column; 
    align-items: stretch; background: var(--glass-bg); padding: 20px; 
    border-radius: 16px; border: 1px solid rgba(255,255,255,0.8); 
    box-shadow: 0 4px 12px rgba(0,0,0,0.03); transition: all 0.3s ease; gap: 0;
  }
  .mate-card:hover { transform: translateY(-3px); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.15); border-color: rgba(137,207,240,0.4); }
  .mate-info { display: flex; flex-direction: column; gap: 8px; flex: 1; }
  .mate-badges { display: flex; gap: 8px; align-items: center; }
  .badge-status { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; }
  .status-on { background: #E6FFFA; color: #00A88F; } 
  .status-off { background: #EDF2F7; color: #A0AEC0; } 
  .mate-region { font-size: 13px; font-weight: 700; color: white; background: var(--text-dark); padding: 4px 10px; border-radius: 6px; }
  .mate-card-title { font-size: 17px; font-weight: 800; margin: 0; color: var(--text-black); }
  .mate-meta { font-size: 13px; color: var(--text-gray); display: flex; gap: 12px; align-items: center; }
  .mate-tags { display: flex; gap: 6px; margin-top: 4px; }
  .m-tag { font-size: 12px; color: var(--sky-blue); background: rgba(137, 207, 240, 0.1); padding: 4px 8px; border-radius: 4px; font-weight: 600; }
  .mate-action { display: flex; flex-direction: column; align-items: flex-end; gap: 12px; min-width: 120px; }
  .mate-user { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; color: var(--text-dark); }
  .mate-user img { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 2px solid white; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
  .btn-apply { background: var(--grad-main); color: white; border: none; padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 800; cursor: pointer; transition: 0.2s; width: 100%; box-shadow: 0 4px 10px rgba(137, 207, 240, 0.3); }
  .btn-apply:hover { transform: scale(1.05); }
  

    .mate-card:hover { transform: translateY(-3px); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.15); border-color: rgba(137,207,240,0.4); }
    .mate-card.expanded { border-color: var(--sky-blue); transform: none; }
    .mate-card-header {
      display: flex; justify-content: space-between; align-items: center; width: 100%; gap: 20px;
    }

    .mate-detail-area {
      display: none;
      margin-top: 20px; padding-top: 20px;
      border-top: 1px dashed var(--border-color);
      animation: fadeIn 0.3s ease;
    }
    .mate-card.expanded .mate-detail-area { display: block;}

    .btn-collapse {
      background: #f1f5f9; color: var(--text-gray); border: none; 
      width: 32px; height: 32px; border-radius: 50%; font-size: 12px; 
      cursor: pointer; display: none; align-items: center; justify-content: center;
      transition: 0.2s;
    }
    .btn-collapse:hover { background: var(--text-dark); color: white; }
    .mate-card.expanded .btn-collapse { display: flex; }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
	
	.comment-options { position: relative; display: inline-block; }
	.btn-kebab {
	    background: none; border: none; font-size: 16px; color: var(--text-gray);
	    cursor: pointer; padding: 2px 6px; border-radius: 4px; transition: 0.2s; line-height: 1;
	}
	.btn-kebab:hover { background: rgba(0,0,0,0.05); color: var(--text-dark); }
	.btn-kebab svg { pointer-events: none; }
	
	.kebab-menu-list {
	    display: none; position: absolute; right: 0; top: 100%;
	    background: white; border: 1px solid #E2E8F0;
	    border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);
	    min-width: 110px; z-index: 99999; margin-top: 8px; padding: 4px;
	}
	.kebab-item {
	    display: block; width: 100%; text-align: center; background: none; border: none;
	    padding: 10px 0; font-size: 14px; font-weight: 600; color: #4A5568;
	    cursor: pointer; transition: 0.2s; font-family: 'Pretendard', sans-serif; border-radius: 6px;
	}
	.kebab-item:hover { background: #F8FAFC; color: var(--text-black); }
	.kebab-item.danger { color: #FF6B6B; }
	.kebab-item.danger:hover { background: #FFF5F5; }
    .kebab-divider { border-top: 1px solid #f1f5f9; margin: 4px 0; }
	
</style>

<div class="mate-header">
  <h2 class="mate-title">🤝 트래블 메이트</h2>
  <p class="mate-sub">일정과 취향이 딱 맞는 여행 동행을 찾아보세요!</p>
</div>

<div class="mate-filter-bar">
  
  <div class="filter-row-1">
    <select class="mate-select" id="filterRegion">
      <option value="">📍 모든 지역</option>
      <option value="1">서울/경기</option>
      <option value="2">부산/경상</option>
      <option value="3">제주도</option>
    </select>
    
    <div class="date-group">
      <input type="date" class="mate-date" id="filterStartDate" title="가는 날">
      <span style="color: var(--text-gray); font-weight: bold;">~</span>
      <input type="date" class="mate-date" id="filterEndDate" title="오는 날">
    </div>
  </div>

  <div class="filter-row-2">
    <input type="text" class="mate-input" id="filterTag" placeholder="🔍 해시태그로 나에게 딱 맞는 동행을 찾아보세요! (예: #20대 #당일치기)">
    <button class="btn-search-bar" onclick="searchMates()">검색</button>
  </div>
</div>

<div class="filter-row-3">
  <button class="btn-write-mate" onclick="openMateModal()">✏️ 동행 모집하기</button>
</div>

<div class="mate-list" id="mateListContainer">
  <div style="text-align:center; padding: 60px; color:var(--sky-blue); font-weight:800; font-size:18px;">
    데이터를 불러오는 중입니다... ✈️
  </div>
</div>
