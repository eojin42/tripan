<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  /*
   * Controller: CommunityController.java
   * @GetMapping("/community/feed")
   * model: hotFeeds, allFeeds, totalCount, sort, category
   */

  // ── 더미 데이터 (실제: model attribute) ──
  String[] hotTitles = {"부산 2박3일 핫플 뚜시기", "제주 동쪽 감성 숙소 투어", "속초 1박 2일 맛집 지도", "강릉 드라이브 코스", "경주 한옥스테이 추천", "여수 밤바다 감성 여행", "통영 섬투어 완벽 코스", "전주 한옥+막걸리 1박"};
  String[] hotTags   = {"#부산 #해운대", "#제주도 #오션뷰", "#속초 #박닥뷰어", "#강릉 #해안도로", "#경주 #한옥", "#여수 #야경", "#통영 #섬", "#전주 #한옥"};
  String[] hotUsers  = {"@travel_holic", "@jeju_vibe", "@n_bread_master", "@world_driver", "@gyeongju_s", "@yeosu_night", "@tongyeong_k", "@jeonju_fan"};
  int[]    hotLikes  = {890, 750, 620, 540, 430, 380, 310, 285};
  String[] hotImgs   = {
    "https://picsum.photos/seed/busan11/700/480",
    "https://picsum.photos/seed/jeju22/700/480",
    "https://picsum.photos/seed/sokcho11/700/480",
    "https://picsum.photos/seed/gangneung11/700/480",
    "https://picsum.photos/seed/gyeongju11/700/480",
    "https://picsum.photos/seed/yeosu11/700/480",
    "https://picsum.photos/seed/tongyeong1/700/480",
    "https://picsum.photos/seed/jeonju11/700/480"
  };
  String[] hotDescs = {
    "담아오기 1,204회 기록 돌파!", "오션뷰 숙소만 엄선해서", "가성비 끝판왕 N빵 공개",
    "인생샷 보장 로드트립", "고즈넉한 한옥스테이", "야경 맛집 총정리",
    "섬 일주 완벽 가이드", "막걸리+비빔밥 코스"
  };

  String[] allTitles = {"서울 성수동 카페 투어", "전주 한옥마을 1박", "남해 독일마을 드라이브", "통영 한려수도 유람", "안동 찜닭 성지 순례", "제주 올레길 완주 후기", "부산 광안리 야경 명소", "강화도 당일치기 코스", "춘천 닭갈비+소양강", "대구 근대골목 탐방", "담양 메타세쿼이아 길", "양평 카페거리 드라이브"};
  String[] allTags2  = {"#서울 #성수", "#전주 #한옥", "#남해 #드라이브", "#통영 #바다", "#안동 #맛집", "#제주 #올레길", "#부산 #야경", "#강화도 #당일", "#춘천 #닭갈비", "#대구 #골목", "#담양 #숲", "#양평 #카페"};
  int[]    allLikes2 = {312, 289, 245, 210, 198, 187, 165, 143, 132, 118, 104, 98};
  int[]    allViews2 = {4200, 3800, 3100, 2900, 2600, 2400, 2100, 1900, 1700, 1500, 1300, 1100};
  String[] allUsers2 = {"@seoul_local", "@jeonju_fan", "@namhae_go", "@tongyeong_s", "@andong_food", "@jeju_walker", "@busan_night", "@ganghwa_t", "@chuncheon_e", "@daegu_alley", "@damyang_f", "@yangpyeong_c"};
  String[] allImgs2  = {
    "https://picsum.photos/seed/seongsu1/500/340",
    "https://picsum.photos/seed/jeonju1/500/340",
    "https://picsum.photos/seed/namhae1/500/340",
    "https://picsum.photos/seed/tongyeong2/500/340",
    "https://picsum.photos/seed/andong1/500/340",
    "https://picsum.photos/seed/ollet1/500/340",
    "https://picsum.photos/seed/gwangan1/500/340",
    "https://picsum.photos/seed/ganghwa1/500/340",
    "https://picsum.photos/seed/chuncheon1/500/340",
    "https://picsum.photos/seed/daegu21/500/340",
    "https://picsum.photos/seed/damyang1/500/340",
    "https://picsum.photos/seed/yangpyeong1/500/340"
  };
%>

<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
:root {
  --blue:    #89CFF0;
  --pink:    #FFB6C1;
  --ice:     #A8C8E1;
  --orchid:  #C2B8D9;
  --rose:    #E0BBC2;
  --dark:    #1A202C;
  --mid:     #4A5568;
  --light:   #A0AEC0;
  --white:   #FFFFFF;
  --bg:      #F7F9FC;
  --border:  #E8EDF4;
  --grad:    linear-gradient(120deg, var(--ice), var(--orchid), var(--rose));
  --grad2:   linear-gradient(135deg, var(--blue), var(--pink));
  --ease:    cubic-bezier(0.19,1,0.22,1);
  --shadow:  0 2px 16px rgba(0,0,0,0.06);
  --shadow-hover: 0 12px 36px rgba(0,0,0,0.11);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Pretendard', sans-serif; background: var(--bg); color: var(--dark); }

/* ── 전체 래퍼 ── */
.feed-page { max-width: 1280px; margin: 0 auto; padding: 0 40px 100px; }

/* ════════════════════════════════════
   섹션 공통 헤더
════════════════════════════════════ */
.sec-head {
  display: flex; justify-content: space-between; align-items: flex-end;
  margin-bottom: 24px;
}
.sec-title {
  font-size: 24px; font-weight: 900; color: var(--dark);
  display: flex; align-items: center; gap: 8px; letter-spacing: -0.5px;
}
.sec-sub { font-size: 13px; color: var(--light); margin-top: 5px; font-weight: 500; }
.sec-more {
  font-size: 13px; font-weight: 700; color: var(--mid);
  text-decoration: none; display: flex; align-items: center; gap: 4px;
  transition: color .2s; white-space: nowrap;
}
.sec-more:hover { color: var(--blue); }

/* ════════════════════════════════════
   HOT FEED — 풀와이드 슬라이더
════════════════════════════════════ */
.hot-section {
  padding: 48px 0 0;    /* 상단만 여백, 하단은 divider가 처리 */
}

.carousel-wrap { position: relative; }
.carousel-outer { overflow: hidden; }
.carousel-track {
  display: flex; gap: 18px;
  transition: transform .5s var(--ease);
  will-change: transform;
}

/* 카드 */
.hot-card {
  flex: 0 0 calc(25% - 14px);
  border-radius: 18px; overflow: hidden;
  background: var(--white);
  box-shadow: var(--shadow);
  cursor: pointer; transition: transform .3s var(--ease), box-shadow .3s;
  text-decoration: none; color: inherit; display: block;
}
.hot-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-hover); }

.hot-card__img-wrap { position: relative; height: 210px; overflow: hidden; }
.hot-card__img {
  width: 100%; height: 100%; object-fit: cover;
  transition: transform 1.4s var(--ease);
  display: block;
}
.hot-card:hover .hot-card__img { transform: scale(1.07); }

/* 그라디언트 오버레이 */
.hot-card__gradient {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(26,32,44,.45) 0%, transparent 55%);
}

/* 뱃지 */
.hot-card__rank {
  position: absolute; top: 12px; left: 12px;
  background: var(--grad2); color: white;
  font-size: 11px; font-weight: 900; letter-spacing: 1px;
  padding: 3px 10px; border-radius: 50px;
}
.hot-card__like {
  position: absolute; top: 12px; right: 12px;
  background: rgba(255,255,255,.95); backdrop-filter: blur(6px);
  border-radius: 50px; padding: 4px 11px;
  font-size: 13px; font-weight: 800; color: var(--dark);
  display: flex; align-items: center; gap: 4px;
  box-shadow: 0 2px 10px rgba(0,0,0,.1);
}
.heart { color: #E8849A; }

.hot-card__body { padding: 16px 18px 18px; }
.hot-card__tags { font-size: 11px; font-weight: 700; color: var(--blue); margin-bottom: 6px; }
.hot-card__title { font-size: 16px; font-weight: 800; line-height: 1.35; margin-bottom: 7px; word-break: keep-all; }
.hot-card__desc  { font-size: 12px; color: var(--light); margin-bottom: 14px; }
.hot-card__user  { display: flex; align-items: center; gap: 8px; }
.u-avatar {
  width: 26px; height: 26px; border-radius: 50%;
  background: var(--grad2); flex-shrink: 0;
}
.u-name { font-size: 12px; font-weight: 600; color: var(--mid); }

/* 캐러셀 내비 버튼 */
.car-btn {
  position: absolute; top: calc(210px / 2); transform: translateY(-50%);
  width: 42px; height: 42px; border-radius: 50%;
  background: var(--white); border: 1px solid var(--border);
  box-shadow: 0 4px 16px rgba(0,0,0,.1);
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  color: var(--mid); font-size: 17px;
  transition: all .2s; z-index: 10;
}
.car-btn:hover { background: var(--blue); color: white; border-color: var(--blue); }
.car-btn:disabled { opacity: .3; cursor: not-allowed; }
.car-btn.prev { left: -21px; }
.car-btn.next { right: -21px; }

/* dots */
.car-dots { display: flex; justify-content: center; gap: 7px; margin-top: 22px; }
.car-dot {
  width: 7px; height: 7px; border-radius: 50%;
  background: var(--border); border: none; cursor: pointer; padding: 0;
  transition: all .35s var(--ease);
}
.car-dot.on { width: 22px; border-radius: 4px; background: var(--grad2); }

/* ────────────────────────────────────
   섹션 구분선 (hot ↔ all 이어주기) - 짜치는 비행기 제거 완!
──────────────────────────────────── */
.section-bridge {
  margin: 52px 0 0;
  padding: 32px 0 0;
  border-top: 1px solid var(--border);
  position: relative;
}

/* ════════════════════════════════════
   FILTER BAR
════════════════════════════════════ */
.filter-bar {
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 28px; flex-wrap: wrap;
}
.f-chip {
  padding: 7px 16px; border-radius: 50px;
  border: 1.5px solid var(--border); background: var(--white);
  font-family: 'Pretendard', sans-serif; font-size: 12px; font-weight: 700;
  color: var(--mid); cursor: pointer; transition: all .2s;
  white-space: nowrap;
}
.f-chip:hover  { border-color: var(--blue); color: var(--blue); }
.f-chip.on     { border-color: transparent; background: var(--grad2); color: white; box-shadow: 0 4px 14px rgba(137,207,240,.3); }

.filter-right { margin-left: auto; display: flex; gap: 8px; align-items: center; }
.sort-sel {
  padding: 7px 14px; border: 1.5px solid var(--border);
  border-radius: 50px; font-family: 'Pretendard', sans-serif;
  font-size: 12px; font-weight: 600; color: var(--mid);
  background: var(--white); outline: none; cursor: pointer; appearance: none;
}
.btn-write {
  padding: 8px 18px; border: none; border-radius: 50px;
  background: var(--grad2); color: white;
  font-family: 'Pretendard', sans-serif; font-size: 12px; font-weight: 800;
  cursor: pointer; box-shadow: 0 4px 14px rgba(137,207,240,.3);
  transition: all .3s var(--ease); display: flex; align-items: center; gap: 5px;
}
.btn-write:hover { transform: translateY(-2px); box-shadow: 0 7px 20px rgba(137,207,240,.4); }

/* ════════════════════════════════════
   ALL FEED 그리드
════════════════════════════════════ */
.feed-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.feed-card {
  background: var(--white); border-radius: 16px;
  overflow: hidden; text-decoration: none; color: inherit;
  box-shadow: var(--shadow); display: block;
  border: 1.5px solid transparent;
  transition: all .3s var(--ease);
}
.feed-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
  border-color: rgba(137,207,240,.25);
}

.feed-card__img-wrap { position: relative; height: 170px; overflow: hidden; }
.feed-card__img {
  width: 100%; height: 100%; object-fit: cover; display: block;
  transition: transform 1s var(--ease);
}
.feed-card:hover .feed-card__img { transform: scale(1.06); }
.feed-card__dim {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(26,32,44,.28), transparent 55%);
}

.feed-card__body { padding: 14px 16px 16px; }
.feed-card__tags { font-size: 10px; font-weight: 700; color: var(--blue); margin-bottom: 5px; }
.feed-card__title { font-size: 14px; font-weight: 800; margin-bottom: 12px; line-height: 1.4; word-break: keep-all; }
.feed-card__foot {
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid var(--border); padding-top: 10px;
}
.feed-card__user { display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 600; color: var(--mid); }
.feed-card__user .u-avatar { width: 22px; height: 22px; }
.feed-card__stats { display: flex; gap: 8px; font-size: 11px; color: var(--light); font-weight: 600; }

/* 더보기 */
.load-more-wrap { text-align: center; margin-top: 48px; }
.btn-load {
  padding: 13px 48px;
  border: 1.5px solid var(--border); border-radius: 50px;
  background: var(--white); font-family: 'Pretendard', sans-serif;
  font-size: 13px; font-weight: 700; color: var(--mid);
  cursor: pointer; transition: all .3s var(--ease);
}
.btn-load:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

/* ── 반응형 ── */
@media (max-width: 1100px) {
  .feed-grid { grid-template-columns: repeat(3, 1fr); }
  .hot-card  { flex: 0 0 calc(33.333% - 12px); }
}
@media (max-width: 768px) {
  .feed-page { padding: 0 20px 80px; }
  .feed-grid { grid-template-columns: repeat(2, 1fr); }
  .hot-card  { flex: 0 0 calc(50% - 9px); }
  .filter-right { margin-left: 0; }
}
@media (max-width: 480px) {
  .feed-grid { grid-template-columns: 1fr; }
  .hot-card  { flex: 0 0 100%; }
  .sec-title { font-size: 20px; }
}
</style>


<div class="feed-page">

  <%-- ══════════════════════════════════
       HOT FEED
  ══════════════════════════════════ --%>
  <section class="hot-section">
    <div class="sec-head">
      <div>
        <div class="sec-title">실시간 인기 피드 🔥</div>
        <div class="sec-sub">지금 이 순간 가장 많이 담겨진 여행 코스</div>
      </div>
      <a href="${pageContext.request.contextPath}/community/feed?sort=hot" class="sec-more">전체보기 →</a>
    </div>

    <div class="carousel-wrap">
      <button class="car-btn prev" id="btnPrev" onclick="carMove(-1)" disabled>&#8592;</button>
      <div class="carousel-outer">
        <div class="carousel-track" id="carTrack">
          <%
            for (int i = 0; i < hotTitles.length; i++) {
          %>
          <a href="${pageContext.request.contextPath}/community/feed/<%= i+1 %>" class="hot-card">
            <div class="hot-card__img-wrap">
              <img class="hot-card__img" src="<%= hotImgs[i] %>" alt="<%= hotTitles[i] %>" loading="lazy">
              <div class="hot-card__gradient"></div>
              <div class="hot-card__rank">HOT <%= i+1 %></div>
              <div class="hot-card__like"><span class="heart">♥</span> <%= hotLikes[i] %></div>
            </div>
            <div class="hot-card__body">
              <div class="hot-card__tags"><%= hotTags[i] %></div>
              <div class="hot-card__title"><%= hotTitles[i] %></div>
              <div class="hot-card__desc"><%= hotDescs[i] %></div>
              <div class="hot-card__user">
                <div class="u-avatar"></div>
                <span class="u-name"><%= hotUsers[i] %></span>
              </div>
            </div>
          </a>
          <% } %>
        </div>
      </div>
      <button class="car-btn next" id="btnNext" onclick="carMove(1)">&#8594;</button>
    </div>
    <div class="car-dots" id="carDots"></div>
  </section>


  <%-- ══════════════════════════════════
       섹션 브릿지 (시각적 연결)
  ══════════════════════════════════ --%>
  <div class="section-bridge">

    <%-- FILTER BAR --%>
    <div class="sec-head" style="margin-bottom:16px;">
      <div>
        <div class="sec-title">전체 피드</div>
        <div class="sec-sub">트리판 유저들의 생생한 여행 이야기</div>
      </div>
    </div>

    <div class="filter-bar">
      <button class="f-chip on"  onclick="filterFeed(this,'all')">🗺️ 전체</button>
      <button class="f-chip" onclick="filterFeed(this,'domestic')">🇰🇷 국내</button>
      <button class="f-chip" onclick="filterFeed(this,'food')">🍽️ 맛집</button>
      <button class="f-chip" onclick="filterFeed(this,'stay')">🏨 숙소</button>
      <button class="f-chip" onclick="filterFeed(this,'activity')">🏄 액티비티</button>
      <button class="f-chip" onclick="filterFeed(this,'budget')">💸 가성비</button>
      <div class="filter-right">
        <select class="sort-sel" onchange="sortFeed(this.value)">
          <option value="hot">인기순</option>
          <option value="latest">최신순</option>
          <option value="scrap">담아오기순</option>
        </select>
        <button class="btn-write" onclick="location.href='${pageContext.request.contextPath}/community/feed/write'">
          ✏️ 여행 공유하기
        </button>
      </div>
    </div>

    <%-- ALL FEED GRID --%>
    <div class="feed-grid" id="feedGrid">
      <%
        for (int i = 0; i < allTitles.length; i++) {
      %>
      <a href="${pageContext.request.contextPath}/community/feed/<%= 100 + i %>" class="feed-card">
        <div class="feed-card__img-wrap">
          <img class="feed-card__img" src="<%= allImgs2[i] %>" alt="<%= allTitles[i] %>" loading="lazy">
          <div class="feed-card__dim"></div>
        </div>
        <div class="feed-card__body">
          <div class="feed-card__tags"><%= allTags2[i] %></div>
          <div class="feed-card__title"><%= allTitles[i] %></div>
          <div class="feed-card__foot">
            <div class="feed-card__user">
              <div class="u-avatar" style="background:var(--grad)"></div>
              <span><%= allUsers2[i] %></span>
            </div>
            <div class="feed-card__stats">
              <span>♥ <%= allLikes2[i] %></span>
              <span>👁 <%= String.format("%,d", allViews2[i]) %></span>
            </div>
          </div>
        </div>
      </a>
      <% } %>
    </div>

    <div class="load-more-wrap">
      <button class="btn-load" onclick="loadMore()">더 보기 ↓</button>
    </div>

  </div><%-- /section-bridge --%>

</div><%-- /feed-page --%>

<jsp:include page="../layout/footer.jsp" />

<script>
/* ════════════
   캐러셀
════════════ */
var track    = document.getElementById('carTrack');
var btnPrev  = document.getElementById('btnPrev');
var btnNext  = document.getElementById('btnNext');
var dotsWrap = document.getElementById('carDots');
var curIdx   = 0;
var cards    = track.querySelectorAll('.hot-card');
var total    = cards.length;

function cpv() {
  if (window.innerWidth < 480)  return 1;
  if (window.innerWidth < 768)  return 2;
  if (window.innerWidth < 1100) return 3;
  return 4;
}

function buildDots() {
  dotsWrap.innerHTML = '';
  var pages = Math.ceil(total / cpv());
  for (var i = 0; i < pages; i++) {
    var d = document.createElement('button');
    d.className = 'car-dot' + (i === curIdx ? ' on' : '');
    (function(idx){ d.onclick = function(){ goTo(idx); }; })(i);
    dotsWrap.appendChild(d);
  }
}

function goTo(idx) {
  var c   = cpv();
  var max = Math.ceil(total / c) - 1;
  curIdx  = Math.max(0, Math.min(idx, max));

  var gap   = 18;
  var cardW = cards[0].offsetWidth;
  track.style.transform = 'translateX(-' + (curIdx * c * (cardW + gap)) + 'px)';

  btnPrev.disabled = curIdx === 0;
  btnNext.disabled = curIdx >= max;

  document.querySelectorAll('.car-dot').forEach(function(d, i) {
    d.classList.toggle('on', i === curIdx);
  });
}

function carMove(dir) { goTo(curIdx + dir); }

window.addEventListener('resize', function() { buildDots(); goTo(curIdx); });
buildDots();

/* ════════════
   필터
════════════ */
function filterFeed(btn, cat) {
  document.querySelectorAll('.f-chip').forEach(function(c){ c.classList.remove('on'); });
  btn.classList.add('on');
  toast('🔍 ' + cat + ' 카테고리 (API 연동 예정)');
}
function sortFeed(val) { toast('📊 ' + val + ' 정렬 적용'); }
function loadMore()    { toast('⏳ 다음 페이지 로딩 (API 연동 예정)'); }

/* ════════════
   토스트
════════════ */
var _t = null;
function toast(msg) {
  if (_t) _t.remove();
  _t = document.createElement('div');
  _t.style.cssText = 'position:fixed;bottom:28px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:11px 22px;border-radius:50px;font-size:13px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);animation:tIn .3s ease;white-space:nowrap;font-family:Pretendard,sans-serif;';
  _t.textContent = msg;
  document.body.appendChild(_t);
  setTimeout(function(){ if(_t){_t.style.opacity='0';_t.style.transition='opacity .3s';setTimeout(function(){if(_t)_t.remove();},300);} }, 2300);
}
var _s = document.createElement('style');
_s.textContent = '@keyframes tIn{from{opacity:0;transform:translateX(-50%) translateY(12px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';
document.head.appendChild(_s);
</script>