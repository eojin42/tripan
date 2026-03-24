<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    /* ── 하드코딩 장소 데이터 (나중에 DB 연동으로 교체) ── */
    List<Map<String, Object>> places = new ArrayList<>();

    places.add(Map.of("id","2833705","name","서울로 7017","location","서울 용산구",
        "category","관광지","image","https://tong.visitkorea.or.kr/cms/resource/87/2833687_image2_1.jpg",
        "tags",Arrays.asList("도심여행","친구와함께","나홀로여행","산책코스"),
        "likes",22,"views",15700));
    places.add(Map.of("id","2593245","name","서울도서관","location","서울 중구",
        "category","문화시설","image","https://tong.visitkorea.or.kr/cms/resource/05/2478105_image2_1.jpg",
        "tags",Arrays.asList("친구와함께","전통&역사문화","도심도서관","서울시독서공간"),
        "likes",33,"views",3000));
    places.add(Map.of("id","2782667","name","서울 구 벨기에영사관","location","서울 관악구",
        "category","문화시설","image","https://tong.visitkorea.or.kr/cms/resource/59/2478159_image2_1.jpg",
        "tags",Arrays.asList("열린문화공간","서울시립미술관","역사문화재","역사공부","관광지"),
        "likes",12,"views",4400));
    places.add(Map.of("id","1865597","name","서울색공원","location","서울 영등포구",
        "category","관광지","image","https://tong.visitkorea.or.kr/cms/resource/86/3563186_image2_1.jpg",
        "tags",Arrays.asList("도심여행","서울색공원","열린문화공간","힐링"),
        "likes",15,"views",3100));
    places.add(Map.of("id","1896032","name","N서울타워","location","서울 중구",
        "category","관광지","image","https://tong.visitkorea.or.kr/cms/resource/69/3550369_image2_1.jpg",
        "tags",Arrays.asList("야경","데이트코스","랜드마크","남산"),
        "likes",87,"views",42000));
    places.add(Map.of("id","582215","name","경복궁","location","서울 종로구",
        "category","관광지","image","https://tong.visitkorea.or.kr/cms/resource/81/4009781_image2_1.jpg",
        "tags",Arrays.asList("역사","전통문화","궁궐","사진명소"),
        "likes",241,"views",98000));
    places.add(Map.of("id","136485","name","광장시장","location","서울 종로구",
        "category","음식점","image","https://tong.visitkorea.or.kr/cms/resource/62/4010062_image2_1.jpg",
        "tags",Arrays.asList("전통시장","먹거리","빈대떡","마약김밥"),
        "likes",156,"views",61000));
    places.add(Map.of("id","2707444","name","성수동 카페거리","location","서울 성동구",
        "category","음식점","image","https://tong.visitkorea.or.kr/cms/resource/31/4009931_image2_1.jpg",
        "tags",Arrays.asList("힙플","카페투어","인스타감성","주말나들이"),
        "likes",203,"views",75000));
%>

<jsp:include page="../layout/header.jsp" />

<style>
@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css');

/* ── 레이아웃 ── */
.pl-page {
    background: #f8fafc;
    min-height: 100vh;
    padding: 130px 5% 60px; 
    display: flex;
    gap: 40px;
    max-width: 1800px;
    margin: 0 auto;
}

/*  양옆 여백 넉넉하게 (padding: 0 40px로 증가) */
.pl-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 40px; 
}

/* ── 왼쪽 사이드바 ── */
.pl-sidebar {
    width: 280px;
    flex-shrink: 0;
    padding: 36px 28px 28px;
    background: #fff; 
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.03);
    top: 130px; 
    height: calc(100vh - 150px);
    overflow-y: auto;
}
.pl-sidebar::-webkit-scrollbar { width: 4px; }
.pl-sidebar::-webkit-scrollbar-thumb { background: #E0E0E0; border-radius: 4px; }

.pl-filter-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
}
.pl-filter-title {
    font-size: 17px;
    font-weight: 800;
    color: #1A1A1A;
}
.pl-filter-reset {
    font-size: 13px;
    color: #888;
    background: none;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 3px;
    padding: 0;
}
.pl-filter-reset:hover { color: #555; }

/* 시/도 */
.pl-section-title {
    font-size: 14px;
    font-weight: 800;
    color: #1A1A1A;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.pl-region-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 0;
}
.pl-region-btn {
    padding: 5px 12px;
    border-radius: 50px;
    border: 1px solid #E0E0E0;
    background: #fff;
    font-size: 12px;
    font-weight: 600;
    color: #555;
    cursor: pointer;
    transition: all .15s;
}
.pl-region-btn:hover { border-color: #89CFF0; color: #3a8fb7; }
.pl-region-btn.active {
    background: #1A1A1A;
    border-color: #1A1A1A;
    color: #fff;
}

/* ── 오른쪽 메인 ── */
.pl-main {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    overflow: visible;
}

/* 상단 검색바 영역 */
.pl-topbar {
    background: transparent;
    border: none;
    box-shadow: none;
    margin-bottom: 40px;
    display: flex;
    flex-direction: column;
    align-items: center; /* 가운데 정렬 */
}
/* 검색바 — 카드형으로 리디자인 */
.pl-search-row {
    padding: 0 0 24px 0;
    border: none;
    width: 100%;
    display: flex;
    justify-content: center;
}
.pl-search-box {
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    max-width: 600px; /* 길이를 더 늘려줌 */
    background: #fff;
    border: 1px solid #E2E8F0;
    border-radius: 50px; /* 완전 둥글게 */
    padding: 12px 24px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.04);
    transition: all .2s;
}
.pl-search-box:focus-within {
    border-color: #89CFF0;
    box-shadow: 0 8px 32px rgba(137,207,240,0.15);
}
.pl-search-ico { color: #AAA; flex-shrink: 0; }
.pl-search-input {
    flex: 1;
    border: none;
    outline: none;
    font-size: 14px;
    font-family: inherit;
    font-weight: 600;
    color: #1A1A1A;
    background: transparent;
}
.pl-search-input::placeholder { color: #BBB; font-weight: 400; }
.pl-search-btn {
    padding: 5px 14px;
    background: #1A1A1A;
    color: #fff;
    border: none;
    border-radius: 7px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    white-space: nowrap;
    transition: background .15s;
}
.pl-search-btn:hover { background: #3a8fb7; }

/* 카테고리 탭 */
.pl-cat-tabs {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px; 
	padding: 0;
	width: 100%;
	margin-bottom: 40px;
}
.pl-cat-tabs::-webkit-scrollbar { display: none; }
.pl-cat-tab {
    padding: 10px 22px;
	font-size: 15px;
	font-weight: 700;
	color: #64748B;
	background: #F1F5F9; 
	border: 1px solid transparent;
	border-radius: 30px; 
	cursor: pointer;
	transition: all .2s ease;
}
.pl-cat-tab:hover { background: #E2E8F0; color: #1E293B; }
.pl-cat-tab.active {
    background: #1A1A1A; 
	color: #fff;
	box-shadow: 0 4px 12px rgba(0,0,0,0.15); 
}

/* 결과 헤더 */
.pl-result-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 24px 10px 14px;
}
.pl-result-count {
    font-size: 17px;
    font-weight: 700;
    color: #1A1A1A;
}
.pl-result-count em {
    font-style: normal;
    color: #3a8fb7;
    font-weight: 900;
}
.pl-sort-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 7px 14px;
    border: 1px solid #E0E0E0;
    border-radius: 6px;
    background: #fff;
    font-size: 13px;
    font-weight: 700;
    color: #333;
    cursor: pointer;
}

/* 카드 그리드 */
.pl-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px; 
    padding: 10px 0 60px; 
}
@media (max-width: 1400px) { .pl-grid { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 1024px) { .pl-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px)  { .pl-grid { grid-template-columns: 1fr; } }

/* 카드 */
.pl-card {
    padding: 12px;
    cursor: pointer;
    transition: background .15s;
    border-radius: 12px;
}
.pl-card:hover { background: #F8F8F8; }

.pl-card-img-wrap {
    position: relative;
    width: 100%;
    padding-bottom: 70%;
    border-radius: 10px;
    overflow: hidden;
    margin-bottom: 10px;
    background: #F0F0F0;
}
.pl-card-img {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .35s;
}
.pl-card:hover .pl-card-img { transform: scale(1.04); }

.pl-card-bookmark {
    position: absolute;
    top: 10px; right: 10px;
    width: 32px; height: 32px;
    background: rgba(255,255,255,.22);
    backdrop-filter: blur(6px);
    border: none;
    border-radius: 6px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer;
    transition: background .15s;
}
.pl-card-bookmark:hover { background: rgba(255,255,255,.85); }
.pl-card-bookmark svg { width: 16px; height: 16px; fill: #fff; }
.pl-card-bookmark.saved svg { fill: #3a8fb7; }

.pl-card-name {
    font-size: 15px;
    font-weight: 800;
    color: #1A1A1A;
    margin-bottom: 3px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.pl-card-loc {
    font-size: 12px;
    color: #888;
    font-weight: 600;
    margin-bottom: 6px;
    display: flex;
    align-items: center;
    gap: 3px;
}
.pl-card-tags {
    font-size: 12px;
    color: #555;
    font-weight: 600;
    line-height: 1.6;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.pl-card-stats {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
    color: #AAA;
    font-weight: 600;
    border-top: 1px solid #F0F0F0;
    padding-top: 8px;
}
.pl-card-stat {
    display: flex;
    align-items: center;
    gap: 3px;
}
.pl-card-stat svg { width: 13px; height: 13px; }
.pl-card-stats-right { margin-left: auto; display: flex; gap: 6px; }
.pl-card-icon-btn {
    background: none; border: none; cursor: pointer;
    color: #BBB; padding: 0;
    display: flex; align-items: center;
}
.pl-card-icon-btn:hover { color: #555; }
.pl-card-icon-btn svg { width: 15px; height: 15px; }

/* 빈 결과 */
.pl-empty {
    grid-column: 1/-1;
    text-align: center;
    padding: 80px 20px;
    color: #AAA;
}
.pl-empty-ico { font-size: 48px; margin-bottom: 12px; }
.pl-empty-msg { font-size: 16px; font-weight: 700; }

.pl-divider { height: 1px; background: #F0F0F0; margin: 0 10px 16px; }
</style>

<div class="pl-page">

  <!-- ── 왼쪽 사이드바 ── -->
  <aside class="pl-sidebar">
    <div class="pl-filter-header">
      <span class="pl-filter-title">검색필터</span>
      <button class="pl-filter-reset" onclick="resetFilters()">
        초기화
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.5"/></svg>
      </button>
    </div>

    <!-- 시/도 -->
    <div class="pl-section-title">시/도</div>
    <div class="pl-region-grid" id="regionGrid">
      <% String[] regions = {"전체","서울","부산","대구","인천","광주","대전","울산","세종","경기","강원","충북","충남","경북","경남","전북","전남","제주"}; %>
      <% for(String r : regions) { %>
        <button class="pl-region-btn <%= "전체".equals(r) ? "active" : "" %>" onclick="selectRegion(this,'<%= r %>')"><%= r %></button>
      <% } %>
    </div>
  </aside>

  <!-- ── 오른쪽 메인 ── -->
  <main class="pl-main">

    <!-- 상단 검색 + 카테고리 탭 -->
    <div class="pl-topbar">
      <div class="pl-search-row">
        <div class="pl-search-box">
          <svg class="pl-search-ico" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input id="mainSearchInput" class="pl-search-input" type="text" placeholder="핫플, 숙소, 유저 검색" value="서울"
            onkeyup="if(event.key==='Enter')applyFilters()">
          <button class="pl-search-btn" onclick="applyFilters()">검색</button>
        </div>
      </div>
      <div class="pl-cat-tabs">
        <% String[] catLabels = {"전체","관광지","음식점","숙박","문화시설","레포츠","쇼핑","축제"};
           String[] catValues = {"전체","관광지","음식점","숙박","문화시설","레포츠","쇼핑","축제"}; %>
        <% for(int i = 0; i < catLabels.length; i++) { %>
          <button class="pl-cat-tab <%= i==0?"active":"" %>" onclick="selectCat(this,'<%= catValues[i] %>')"><%= catLabels[i] %></button>
        <% } %>
      </div>
    </div>

    <!-- 결과 헤더 -->
    <div class="pl-result-header">
      <div class="pl-result-count" id="resultCount">
        &ldquo;<em>서울</em>&rdquo;에 대한 검색결과 <strong><%= places.size() %>개</strong>
      </div>
      <div>
        <button class="pl-sort-btn">
          관련도순
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
        </button>
      </div>
    </div>
    <div class="pl-divider"></div>

    <!-- 카드 그리드 -->
    <div class="pl-grid" id="placeGrid">
      <% for(Map<String, Object> p : places) {
           List<String> tags = (List<String>) p.get("tags");
           String tagStr = String.join(" #", tags);
      %>
      <div class="pl-card" data-cat="<%= p.get("category") %>"
           data-name="<%= p.get("name") %>" data-tags="<%= tagStr %>"
           onclick="goDetail('<%= p.get("id") %>')">
        <div class="pl-card-img-wrap">
          <img class="pl-card-img" src="<%= p.get("image") %>" alt="<%= p.get("name") %>"
               onerror="this.src='https://via.placeholder.com/400x280/F0F0F0/AAA?text=No+Image'">
          <button class="pl-card-bookmark" onclick="event.stopPropagation();this.classList.toggle('saved')">
            <svg viewBox="0 0 24 24"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
          </button>
        </div>
        <div class="pl-card-name"><%= p.get("name") %></div>
        <div class="pl-card-loc">
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#AAA" stroke-width="2.5" stroke-linecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          <%= p.get("location") %>
        </div>
        <div class="pl-card-tags">#<%= tagStr %></div>
        <div class="pl-card-stats">
          <div class="pl-card-stat">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            <%= p.get("likes") %>
          </div>
          <div class="pl-card-stat">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            <% int v = (int)p.get("views"); %>
            <%= v >= 1000 ? (v/1000)+"."+((v%1000)/100)+"K" : v %>
          </div>
          <div class="pl-card-stats-right">
            <button class="pl-card-icon-btn" onclick="event.stopPropagation()">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>
            </button>
            <button class="pl-card-icon-btn" onclick="event.stopPropagation()">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            </button>
          </div>
        </div>
      </div>
      <% } %>

      <!-- 빈 결과 -->
      <div class="pl-empty" id="emptyMsg" style="display:none;">
        <div class="pl-empty-ico">🔍</div>
        <div class="pl-empty-msg">검색 결과가 없습니다</div>
      </div>
    </div>
  </main>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
let currentCat = '전체';
let currentRegion = '전체';

function selectCat(el, cat) {
  currentCat = cat;
  document.querySelectorAll('.pl-cat-tab').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  applyFilters();
}

function selectRegion(el, region) {
  currentRegion = region;
  document.querySelectorAll('.pl-region-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  applyFilters();
}

function resetFilters() {
  currentCat = '전체'; currentRegion = '전체';
  document.querySelectorAll('.pl-cat-tab').forEach(b => b.classList.remove('active'));
  document.querySelector('.pl-cat-tab').classList.add('active');
  document.querySelectorAll('.pl-region-btn').forEach(b => b.classList.remove('active'));
  document.querySelector('.pl-region-btn').classList.add('active');
  document.getElementById('mainSearchInput').value = '';
  applyFilters();
}

function applyFilters() {
  const kw    = (document.getElementById('mainSearchInput').value || '').trim().toLowerCase();
  const cards = document.querySelectorAll('.pl-card');
  let shown = 0;

  cards.forEach(card => {
    const cat  = card.dataset.cat;
    const name = (card.dataset.name || '').toLowerCase();
    const tags = (card.dataset.tags || '').toLowerCase();
    const matchCat    = currentCat === '전체' || cat === currentCat;
    const matchKw     = !kw || name.includes(kw) || tags.includes(kw);
    const show = matchCat && matchKw;
    card.style.display = show ? '' : 'none';
    if (show) shown++;
  });

  const kwDisp = kw || '전체';
  const countEl = document.getElementById('resultCount');
  countEl.innerHTML = `&ldquo;<em>${kwDisp}</em>&rdquo;에 대한 검색결과 <strong>${shown}개</strong>`;
  document.getElementById('emptyMsg').style.display = shown === 0 ? 'block' : 'none';
}

function goDetail(id) {
  location.href = '${pageContext.request.contextPath}/curation/detail?id=' + id;
}
</script>
