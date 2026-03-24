<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Map<String, Object> place = new HashMap<>();
    place.put("id",        "2593245");
    place.put("name",      "서울도서관");
    place.put("category",  "문화시설");
    place.put("location",  "서울 중구");
    place.put("address",   "서울특별시 중구 세종대로 110 (태평로1가)");
    place.put("phone",     "02-2133-0300");
    place.put("homepage",  "http://lib.seoul.go.kr");
    place.put("hours",     "[일반자료실, 디지털자료실, 장애인자료실]\n평일 09:00 ~ 21:00, 수일 09:00 ~ 18:00\n[서울자료실, 세계자료실]\n평일 09:00 ~ 18:00, 수일 09:00 ~ 18:00");
    place.put("holiday",   "[정기휴관일] 매주 월요일");
    place.put("parking",   "서울시청 주차장 이용");
    place.put("desc",      "서울도서관은 서울 시청 옆에 있는 도서관이다. 서울시민이 언제 어디서나 편리하게 도서관 서비스를 받을 수 있도록 서울시에서 도서관 정책을 개발하고 있으며, 이를 기반으로 서울시에 소재하고 있는 천여 개 도서관과 함께 정보제공, 독서 진흥, 평생학습 및 문화 활동 증진을 위해 다양한 서비스를 제공한다. 이곳은 서울에 관한 자료를 폭넓게 받을 수 있고, 역사, 문화, 도시계획, 교통, 환경, 행정 등 모든 분야에 관한 자료와 해외여행 보고서, 연구논문, 영상자료, 전자정보 등을 이용할 수 있다. 서울도서관이 디지털 대전환 시대에 통합적 모바일, 웹 서비스 강화로 서울시민의 정보 접근권을 확대하고, 서울시민의 꿈과 희망을 실현하기 위한 다양한 경험과 교류를 할 수 있는 공간으로 자리매김하고 있다.");
    place.put("rating",    4.8);
    place.put("reviewCount", 128);

    List<String> images = Arrays.asList(
        "https://tong.visitkorea.or.kr/cms/resource/05/2478105_image2_1.jpg",
        "https://tong.visitkorea.or.kr/cms/resource/59/2478159_image2_1.jpg",
        "https://tong.visitkorea.or.kr/cms/resource/81/4009781_image2_1.jpg"
    );
    place.put("images", images);
    List<String> imageUrls = (List<String>) place.get("images");
%>

<jsp:include page="../layout/header.jsp" />

<style>
@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css');

.dt-page {  
    background: #f8fafc;
    min-height: 100vh;
    padding-top: 130px !important; 
    padding-left: 5%; 
    padding-right: 5%;
}

/* 컨테이너 — 좌우 여백 넓게 */
.dt-container {
    max-width: 1100px;
    margin: 0 auto;
    padding: 0 64px;
}

/* ── 캐러셀: 컨테이너 너비 안에서 제한 ── */
.dt-carousel-wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 0 64px;
}
.dt-carousel {
    position: relative;
    width: 100%;
    aspect-ratio: 16 / 7;
    max-height: 400px;
    overflow: hidden;
    border-radius: 14px;
    background: #111;
}
.dt-carousel-track {
    display: flex; height: 100%;
    transition: transform .45s cubic-bezier(.4,0,.2,1);
}
.dt-carousel-slide { min-width: 100%; height: 100%; }
.dt-carousel-slide img { width: 100%; height: 100%; object-fit: cover; }
.dt-carousel-btn {
    position: absolute; top: 50%; transform: translateY(-50%);
    width: 38px; height: 38px;
    background: rgba(255,255,255,.2); backdrop-filter: blur(8px);
    border: 1.5px solid rgba(255,255,255,.35); border-radius: 50%;
    color: #fff; font-size: 14px; cursor: pointer;
    display: flex; align-items: center; justify-content: center; z-index: 10;
    transition: background .15s;
}
.dt-carousel-btn:hover { background: rgba(255,255,255,.45); }
.dt-carousel-btn.prev { left: 14px; }
.dt-carousel-btn.next { right: 14px; }
.dt-carousel-counter {
    position: absolute; bottom: 12px; right: 14px;
    background: rgba(0,0,0,.55); backdrop-filter: blur(4px);
    color: #fff; font-size: 12px; font-weight: 700;
    padding: 4px 10px; border-radius: 50px;
}

/* 썸네일 */
.dt-thumb-row { display: flex; gap: 6px; padding: 8px 0 0; }
.dt-thumb {
    width: 56px; height: 38px; border-radius: 6px; overflow: hidden;
    cursor: pointer; opacity: .45; transition: opacity .15s;
    border: 2px solid transparent; flex-shrink: 0;
}
.dt-thumb.active { opacity: 1; border-color: #89CFF0; }
.dt-thumb img { width: 100%; height: 100%; object-fit: cover; }

/* ── 타이틀 ── */
.dt-title-row {
    display: flex; align-items: flex-start;
    justify-content: space-between; gap: 16px;
    padding: 0 0 14px; 
    border-bottom: 1px solid #EBEBEB;
}
.dt-cat-badge {
    display: inline-flex; align-items: center; gap: 4px;
    font-size: 12px; font-weight: 800; color: #3a8fb7;
    background: rgba(137,207,240,.12);
    border: 1px solid rgba(137,207,240,.3);
    padding: 4px 10px; border-radius: 50px; margin-bottom: 10px;
}
.dt-name { font-size: 26px; font-weight: 900; color: #1A1A1A; margin-bottom: 6px; line-height: 1.25; }
.dt-location { font-size: 14px; color: #888; font-weight: 600; display: flex; align-items: center; gap: 4px; }
.dt-rating-box { display: flex; align-items: center; gap: 5px; font-size: 15px; font-weight: 800; padding-top: 4px; flex-shrink: 0; }
.dt-rating-box small { font-size: 12px; font-weight: 500; color: #AAA; }

/* ── 탭 ── */
.dt-tabs { display: flex; border-bottom: 1px solid #EBEBEB; }
.dt-tab {
    padding: 14px 22px; font-size: 14px; font-weight: 700; color: #888;
    background: none; border: none; border-bottom: 2px solid transparent;
    cursor: pointer; transition: all .15s; margin-bottom: -1px;
}
.dt-tab:hover { color: #1A1A1A; }
.dt-tab.active { color: #1A1A1A; border-bottom-color: #1A1A1A; }

/* ── 본문 2단 ── */
.dt-body { 
    display: flex; 
    gap: 48px; 
    align-items: flex-start; 
    padding: 24px 0;
}
.dt-main { flex: 1; min-width: 0; }
.dt-side { width: 280px; flex-shrink: 0; position: sticky; top: 100px; }

/* ── 섹션 ── */
.dt-section { margin-bottom: 44px; }
.dt-section-title { font-size: 18px; font-weight: 900; color: #1A1A1A; margin-bottom: 18px; }

.dt-desc {
    font-size: 15px; line-height: 1.9; color: #333;
    display: -webkit-box; -webkit-line-clamp: 6; -webkit-box-orient: vertical; overflow: hidden;
}
.dt-desc.expanded { -webkit-line-clamp: unset; }
.dt-more-btn {
    display: flex; align-items: center; justify-content: flex-end; gap: 4px;
    width: 100%; margin-top: 8px; background: none; border: none;
    font-size: 13px; font-weight: 700; color: #555; cursor: pointer; padding: 0;
}
.dt-more-btn:hover { color: #1A1A1A; }

/* 지도 */
.dt-map {
    width: 100%; height: 280px; border-radius: 10px;
    background: #F0F0F0; margin: 28px 0 22px;
    border: 1px solid #E8E8E8;
    display: flex; align-items: center; justify-content: center;
    color: #AAA; font-size: 14px; font-weight: 600;
}

/* 정보 그리드 */
.dt-info-grid {
    display: grid; grid-template-columns: 1fr 1fr;
    gap: 0; border-top: 1px solid #E8E8E8;
}
.dt-info-row {
    display: flex; align-items: flex-start; gap: 12px;
    padding: 16px 0; border-bottom: 1px solid #F0F0F0;
}
.dt-info-row:nth-child(odd)  { padding-right: 28px; }
.dt-info-row:nth-child(even) { padding-left: 28px; border-left: 1px solid #F0F0F0; }
.dt-info-dot { width: 5px; height: 5px; border-radius: 50%; background: #3a8fb7; flex-shrink: 0; margin-top: 7px; }
.dt-info-label { font-size: 12px; font-weight: 700; color: #888; margin-bottom: 4px; }
.dt-info-value { font-size: 13px; font-weight: 600; color: #333; line-height: 1.7; white-space: pre-line; }
.dt-info-value a { color: #3a8fb7; text-decoration: none; }
.dt-info-value a:hover { text-decoration: underline; }
.dt-more-info { display: flex; justify-content: flex-end; padding: 10px 0 4px; }
.dt-more-info-btn { background: none; border: none; font-size: 13px; font-weight: 700; color: #3a8fb7; cursor: pointer; }
.dt-more-info-btn:hover { text-decoration: underline; }

/* ── 사이드 패널 ── */
.dt-side-panel {
    background: #fff; border: 1.5px solid #E0E0E0; border-radius: 16px;
    padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,.06);
}
.dt-side-rating { display: flex; align-items: center; gap: 6px; font-size: 16px; font-weight: 800; margin-bottom: 16px; }
.dt-side-rating small { font-size: 12px; font-weight: 500; color: #AAA; }
.dt-side-divider { height: 1px; background: #F0F0F0; margin: 14px 0; }
.dt-side-meta { font-size: 12px; color: #888; font-weight: 600; line-height: 1.8; }
.dt-side-meta strong { color: #1A1A1A; font-weight: 700; display: block; margin-bottom: 3px; font-size: 13px; }

@media (max-width: 960px) {
    .dt-container, .dt-carousel-wrap { padding: 0 28px; }
    .dt-body { flex-direction: column; }
    .dt-side { width: 100%; position: static; }
    .dt-info-grid { grid-template-columns: 1fr; }
    .dt-info-row:nth-child(even) { padding-left: 0; border-left: none; }
    .dt-name { font-size: 22px; }
    .dt-title-row {
	    display: flex; align-items: flex-start;
	    justify-content: space-between; gap: 16px;
	    padding: 16px 0 18px; /* 🔥 기존 28px에서 16px로 줄여서 바짝 땡김! */
	    border-bottom: 1px solid #EBEBEB;
	}
}
</style>

<div class="dt-page">

  <!-- 캐러셀 -->
  <div class="dt-carousel-wrap">
    <div class="dt-carousel">
      <div class="dt-carousel-track" id="dtTrack">
        <% for(String img : imageUrls) { %>
          <div class="dt-carousel-slide">
            <img src="<%= img %>" alt="<%= place.get("name") %>">
          </div>
        <% } %>
      </div>
      <button class="dt-carousel-btn prev" onclick="slideMove(-1)">&#10094;</button>
      <button class="dt-carousel-btn next" onclick="slideMove(1)">&#10095;</button>
      <div class="dt-carousel-counter" id="dtCounter">1 / <%= imageUrls.size() %></div>
    </div>
    <div class="dt-thumb-row">
      <% for(int i = 0; i < imageUrls.size(); i++) { %>
        <div class="dt-thumb <%= i==0?"active":"" %>" onclick="goSlide(<%= i %>)">
          <img src="<%= imageUrls.get(i) %>" alt="">
        </div>
      <% } %>
    </div>
  </div>

  <!-- 본문 -->
  <div class="dt-container">

    <!-- 타이틀 -->
    <div class="dt-title-row">
      <div>
        <div class="dt-cat-badge">
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          <%= place.get("category") %>
        </div>
        <div class="dt-name"><%= place.get("name") %></div>
        <div class="dt-location">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#AAA" stroke-width="2.5" stroke-linecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          <%= place.get("location") %>
        </div>
      </div>
      <div class="dt-rating-box">
        ⭐ <%= place.get("rating") %>
        <small>(<%= place.get("reviewCount") %>개)</small>
      </div>
    </div>

    <!-- 탭 -->
    <div class="dt-tabs">
      <button class="dt-tab active" onclick="scrollToSection('secInfo',this)">상세정보</button>
      <button class="dt-tab" onclick="scrollToSection('secNearby',this)">주변</button>
    </div>

    <!-- 본문 2단 -->
    <div class="dt-body">
      <div class="dt-main">

        <!-- 상세정보 -->
        <section class="dt-section" id="secInfo">
          <div class="dt-section-title">상세정보</div>

          <p class="dt-desc" id="dtDesc"><%= place.get("desc") %></p>
          <button class="dt-more-btn" id="dtMoreBtn" onclick="toggleDesc()">
            내용 더보기
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
          </button>

          <!-- 지도 -->
          <div class="dt-map">
            <div style="text-align:center;">
              <div style="font-size:30px;margin-bottom:8px;">🗺️</div>
              <div style="font-weight:700;">카카오 지도 API 영역</div>
              <div style="font-size:12px;margin-top:6px;color:#CCC;"><%= place.get("address") %></div>
            </div>
          </div>

          <!-- 정보 그리드 -->
          <div class="dt-info-grid">
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">문의 및 안내</div>
                <div class="dt-info-value"><%= place.get("phone") %></div>
              </div>
            </div>
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">홈페이지</div>
                <div class="dt-info-value">
                  <a href="<%= place.get("homepage") %>" target="_blank"><%= place.get("homepage") %></a>
                </div>
              </div>
            </div>
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">주소</div>
                <div class="dt-info-value"><%= place.get("address") %></div>
              </div>
            </div>
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">이용시간</div>
                <div class="dt-info-value"><%= place.get("hours") %></div>
              </div>
            </div>
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">휴일</div>
                <div class="dt-info-value"><%= place.get("holiday") %></div>
              </div>
            </div>
            <div class="dt-info-row">
              <div class="dt-info-dot"></div>
              <div>
                <div class="dt-info-label">주차</div>
                <div class="dt-info-value"><%= place.get("parking") %></div>
              </div>
            </div>
          </div>
          <div class="dt-more-info">
            <button class="dt-more-info-btn">더보기 +</button>
          </div>
        </section>

        <!-- 주변 -->
        <section class="dt-section" id="secNearby">
          <div class="dt-section-title">주변 장소</div>
          <div style="text-align:center;padding:52px;color:#AAA;border:1.5px dashed #E8E8E8;border-radius:12px;">
            <div style="font-size:36px;margin-bottom:10px;">📍</div>
            <div style="font-size:14px;font-weight:700;">주변 장소 정보는 곧 추가됩니다</div>
          </div>
        </section>

      </div><!-- .dt-main -->

      <!-- 사이드 패널 -->
      <div class="dt-side">
        <div class="dt-side-panel">
          <div class="dt-side-rating">
            ⭐ <%= place.get("rating") %>
            <small>(<%= place.get("reviewCount") %>개 평가)</small>
          </div>
          <div class="dt-side-divider"></div>
          <div class="dt-side-meta">
            <strong>카테고리</strong><%= place.get("category") %>
          </div>
          <div class="dt-side-divider"></div>
          <div class="dt-side-meta">
            <strong>주소</strong><%= place.get("address") %>
          </div>
          <div class="dt-side-divider"></div>
          <div class="dt-side-meta">
            <strong>문의</strong><%= place.get("phone") %>
          </div>
          <div class="dt-side-divider"></div>
          <div class="dt-side-meta">
            <strong>홈페이지</strong>
            <a href="<%= place.get("homepage") %>" target="_blank"
               style="color:#3a8fb7;font-size:12px;font-weight:600;">바로가기 →</a>
          </div>
        </div>
      </div>

    </div><!-- .dt-body -->
  </div><!-- .dt-container -->
</div><!-- .dt-page -->

<jsp:include page="../layout/footer.jsp" />

<script>
let slide = 0, total = <%= imageUrls.size() %>;
const track = document.getElementById('dtTrack');
const counter = document.getElementById('dtCounter');

function goSlide(n) {
    slide = n;
    track.style.transform = 'translateX(-' + (slide * 100) + '%)';
    counter.textContent = (slide + 1) + ' / ' + total;
    document.querySelectorAll('.dt-thumb').forEach((t, i) => t.classList.toggle('active', i === slide));
}
function slideMove(d) { goSlide((slide + d + total) % total); }

let expanded = false;
function toggleDesc() {
    expanded = !expanded;
    document.getElementById('dtDesc').classList.toggle('expanded', expanded);
    document.getElementById('dtMoreBtn').innerHTML = expanded
        ? '내용 접기 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="18 15 12 9 6 15"/></svg>'
        : '내용 더보기 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>';
}

function scrollToSection(id, el) {
    document.querySelectorAll('.dt-tab').forEach(t => t.classList.remove('active'));
    el.classList.add('active');
    document.getElementById(id).scrollIntoView({ behavior: 'smooth', block: 'start' });
}
</script>
