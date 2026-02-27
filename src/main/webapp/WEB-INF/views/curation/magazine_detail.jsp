<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // ─────────────────────────────────────────────
    // [Tripan DB Connect] 실제 구현 시:
    //   String articleId = request.getParameter("id");
    //   Article article  = articleService.findById(articleId);
    // ─────────────────────────────────────────────

    Map<String, Object> article = new HashMap<>();
    article.put("id",       "jeju-secret-stays");
    article.put("vol",      "DIGITAL ARCHIVE VOL. 12");
    article.put("category", "EDITOR'S CHOICE");
    article.put("author",   "Editor. Tripan");
    article.put("date",     "2026.02.27");
    article.put("readTime", "5 MIN READ");
    article.put("title",    "제주, 온전한 쉼을 위한\n비밀스러운 공간들");
    article.put("lead",     "파도 소리만 들리는 프라이빗한 숙소부터 숨겨진 로컬 맛집까지, 당신의 지친 일상을 위로할 완벽한 가이드. Tripan이 선별한 제주의 진짜 모습을 만나보세요.");
    article.put("mainImg",  "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=1800&q=85");

    // 이전/다음 아티클 (실제로는 DB에서 조회)
    Map<String, String> prevArticle = new HashMap<>();
    prevArticle.put("title", "부산 해운대, 미식가들의 성지를 찾아서");
    prevArticle.put("tag",   "TASTE");
    prevArticle.put("href",  "#");

    Map<String, String> nextArticle = new HashMap<>();
    nextArticle.put("title", "푸른 바람을 가르며, 우도 자전거 여행");
    nextArticle.put("tag",   "JOURNEY");
    nextArticle.put("href",  "#");
%>

<jsp:include page="../layout/header.jsp" />

<%-- Google Fonts --%>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;0,900;1,400;1,700;1,900&family=Pretendard:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* ═══════════════════════════════════════════
   0. DESIGN TOKEN  (magazine_list.jsp 동일)
═══════════════════════════════════════════ */
:root {
    --ice-blue:       #A8C8E1;
    --orchid-purple:  #C2B8D9;
    --rose-pink:      #E0BBC2;
    --point-blue:     #89CFF0;
    --point-pink:     #FFB6C1;
    --text-dark:      #1A202C;
    --text-light:     #718096;
    --white:          #FFFFFF;
    --bg-subtle:      #F8FAFC;

    --instar3-gradient: linear-gradient(120deg,
        var(--ice-blue)      0%,
        var(--orchid-purple) 50%,
        var(--rose-pink)     100%);
    --cta-gradient: linear-gradient(135deg, var(--point-blue), var(--point-pink));

    --radius-sm: 4px;
    --radius-pill: 50px;
    --shadow-card: 0 30px 80px rgba(0,0,0,0.06);
    --shadow-hover: 0 20px 40px rgba(137,207,240,0.25);
    --transition: 0.4s cubic-bezier(0.19,1,0.22,1);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* ═══════════════════════════════════════════
   1. LAYOUT WRAPPER
═══════════════════════════════════════════ */
.detail-page {
    background: var(--white);
    font-family: 'Pretendard', sans-serif;
    color: var(--text-dark);
    overflow-x: hidden;
}

/* ═══════════════════════════════════════════
   2. HERO  –  풀스크린 + 패럴랙스
═══════════════════════════════════════════ */
.detail-hero {
    position: relative;
    width: 100%;
    height: 100vh;
    min-height: 640px;
    overflow: hidden;
    /* 헤더 높이만큼 아래로 밀기 (헤더가 fixed일 경우 조정 필요) */
    margin-top: 0;
}
.detail-hero__img {
    position: absolute;
    inset: -10% 0;
    width: 100%;
    height: 120%;
    object-fit: cover;
    will-change: transform;
    transition: transform 0.1s linear;
}
.detail-hero__gradient {
    position: absolute;
    inset: 0;
    background: linear-gradient(
        to bottom,
        rgba(26,32,44,0.15) 0%,
        rgba(26,32,44,0.05) 40%,
        rgba(26,32,44,0.65) 100%
    );
}

/* 히어로 하단 메타 정보 */
.detail-hero__meta {
    position: absolute;
    bottom: 80px;
    left: 50%;
    transform: translateX(-50%);
    width: min(900px, 90%);
    text-align: center;
    color: var(--white);
    animation: fadeUp 1s ease both;
}
.detail-hero__vol {
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 4px;
    text-transform: uppercase;
    opacity: 0.8;
    display: block;
    margin-bottom: 20px;
}
.detail-hero__title {
    font-family: 'Pretendard', 'Playfair Display', serif;
    font-size: clamp(34px, 5.5vw, 74px);
    font-weight: 900;
    line-height: 1.1;
    letter-spacing: -2px;
    white-space: pre-line;
    text-shadow: 0 4px 24px rgba(0,0,0,0.3);
    margin-bottom: 32px;
}
.detail-hero__info {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 18px;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 3px;
    text-transform: uppercase;
    opacity: 0.75;
}
.detail-hero__info .dot { opacity: 0.4; }

/* 히어로 하단 스크롤 힌트 */
.scroll-hint {
    position: absolute;
    bottom: 30px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    color: rgba(255,255,255,0.5);
    font-size: 10px;
    letter-spacing: 3px;
    font-weight: 700;
    text-transform: uppercase;
}
.scroll-hint__line {
    width: 1px;
    height: 40px;
    background: rgba(255,255,255,0.3);
    animation: scrollPulse 2s ease infinite;
}
@keyframes scrollPulse {
    0%,100% { transform: scaleY(1);   opacity: 0.3; }
    50%      { transform: scaleY(0.5); opacity: 0.8; }
}

/* ═══════════════════════════════════════════
   3. 오버랩 리드(LEAD) 카드  –  히어로 위에 겹침
═══════════════════════════════════════════ */
.detail-lead-wrap {
    display: flex;
    justify-content: center;
    position: relative;
    z-index: 20;
    margin-top: -120px;
    margin-bottom: 100px;
    padding: 0 40px;
}
.detail-lead-card {
    width: min(860px, 100%);
    background: var(--white);
    padding: 70px 80px;
    box-shadow: var(--shadow-card);
    border-radius: var(--radius-sm);
    text-align: center;
}
.lead-badge {
    display: inline-block;
    background: var(--instar3-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 4px;
    text-transform: uppercase;
    margin-bottom: 24px;
}
.lead-text {
    font-size: 20px;
    line-height: 1.85;
    color: var(--text-light);
    word-break: keep-all;
    font-weight: 400;
}
.lead-divider {
    width: 48px;
    height: 2px;
    background: var(--instar3-gradient);
    margin: 40px auto 0;
    border-radius: 2px;
}

/* ═══════════════════════════════════════════
   4. 본문 (BODY) 레이아웃
═══════════════════════════════════════════ */
.detail-body {
    max-width: 780px;
    margin: 0 auto;
    padding: 0 40px 80px;   /* ← 하단 여백 줄임 */
    overflow: hidden;        /* ← float 클리어 */
}

/* 드롭캡 첫 단락 - float 제거하고 inline-block으로 안전하게 */
.detail-body p:first-of-type::first-letter {
    font-family: 'Playfair Display', serif;
    font-size: 4.2em;
    font-weight: 900;
    line-height: 0.8;
    float: left;
    margin: 4px 10px -4px 0;
    background: var(--instar3-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}
/* 드롭캡 단락 뒤 float 클리어 */
.detail-body p:first-of-type {
    overflow: hidden;   /* float 자가 클리어 */
}

.detail-body p {
    font-size: 18px;
    line-height: 2.0;
    color: #2D3748;
    margin-bottom: 36px;
    word-break: keep-all;
    font-weight: 400;
}

/* 섹션 헤딩 */
.detail-body h3 {
    font-family: 'Pretendard', sans-serif;
    font-size: 32px;
    font-weight: 900;
    line-height: 1.2;
    color: var(--text-dark);
    letter-spacing: -1.5px;
    margin: 90px 0 28px;
    word-break: keep-all;
}
.detail-body h3::before {
    content: '—';
    display: block;
    font-size: 14px;
    font-family: 'Pretendard', sans-serif;
    font-weight: 800;
    letter-spacing: 3px;
    background: var(--instar3-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 16px;
}

/* 인라인 이미지 (단독) */
.detail-body .img-single {
    margin: 70px -80px;       /* ← 본문보다 넓게 출혈 */
    border-radius: var(--radius-sm);
    overflow: hidden;
    aspect-ratio: 16 / 9;
    background: #e8edf2;
}
.detail-body .img-single img {
    width: 100%;
    height: 100%;             /* ← 부모 채우기 */
    display: block;
    object-fit: cover;        /* ← 비율 유지하며 크롭 */
    transition: transform 1.5s var(--transition);
}
.detail-body .img-single:hover img { transform: scale(1.03); }
.detail-body .img-caption {
    text-align: center;
    font-size: 13px;
    color: #A0AEC0;
    margin-top: 12px;
    margin-bottom: 0;
    letter-spacing: 0.5px;
    font-style: italic;
    display: block;
}

/* 2열 이미지 */
.detail-body .img-pair {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin: 70px -60px;
}
.detail-body .img-pair-item {
    border-radius: var(--radius-sm);
    overflow: hidden;
    aspect-ratio: 4/3;
}
.detail-body .img-pair-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 1.2s var(--transition);
}
.detail-body .img-pair-item:hover img { transform: scale(1.06); }

/* 풀블리드 인용구 */
.detail-body blockquote {
    margin: 80px -40px;
    padding: 60px 80px;
    background: var(--bg-subtle);
    border-left: 4px solid transparent;
    border-image: var(--instar3-gradient) 1;
    position: relative;
}
.detail-body blockquote p {
    font-family: 'Playfair Display', serif;
    font-size: 26px;
    font-weight: 700;
    font-style: italic;
    line-height: 1.6;
    color: var(--text-dark);
    margin-bottom: 0;
}
.detail-body blockquote p::first-letter { all: unset; }
.detail-body blockquote cite {
    display: block;
    font-size: 13px;
    font-weight: 700;
    color: #A0AEC0;
    letter-spacing: 3px;
    text-transform: uppercase;
    margin-top: 20px;
    font-style: normal;
}

/* ═══════════════════════════════════════════
   5. 관련 아티클 STRIP
═══════════════════════════════════════════ */
.related-strip {
    max-width: 780px;        /* ← 본문과 동일한 너비 */
    margin: 0 auto 80px;
    padding: 0 40px;
    position: relative;
    z-index: 1;
    clear: both;
}
.related-strip__label {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 4px;
    text-transform: uppercase;
    background: var(--instar3-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 20px;
    display: block;
    text-align: left;
}
.related-nav {
    display: grid;
    grid-template-columns: 1fr 1fr;  /* ← 동등한 2열 */
    gap: 20px;
    width: 100%;
}
.related-nav__card {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 32px;
    border: 1px solid #E2E8F0;
    border-radius: var(--radius-sm);
    text-decoration: none;
    color: inherit;
    transition: var(--transition);
    position: relative;
    overflow: hidden;
    background: var(--white);
}
.related-nav__card::after {
    content: '';
    position: absolute;
    inset: 0;
    background: var(--instar3-gradient);
    opacity: 0;
    transition: opacity 0.3s;
}
.related-nav__card:hover {
    border-color: var(--ice-blue);
    box-shadow: var(--shadow-hover);
    transform: translateY(-4px);
}
.related-nav__card:hover::after { opacity: 0.04; }
.related-nav__direction {
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 3px;
    color: #A0AEC0;
    text-transform: uppercase;
}
.related-nav__tag {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 2px;
    color: var(--point-pink);
    text-transform: uppercase;
}
.related-nav__title {
    font-family: 'Pretendard', sans-serif;
    font-size: 17px;
    font-weight: 700;
    line-height: 1.4;
    color: var(--text-dark);
    word-break: keep-all;
}
.related-nav__card--next {
    text-align: right;
}

/* ═══════════════════════════════════════════
   6. FOOTER BAR  (Back + Share)
═══════════════════════════════════════════ */
.detail-footer-bar {
    max-width: 780px;
    margin: 0 auto 140px;
    padding: 48px 40px 0;
    border-top: 1px solid #EDF2F7;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    clear: both;
}
.btn-back {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
    color: var(--text-dark);
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    transition: var(--transition);
}
.btn-back:hover { transform: translateX(-6px); }
.btn-back svg { flex-shrink: 0; }

.btn-share {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 16px 36px;
    background: var(--instar3-gradient);
    border: none;
    border-radius: var(--radius-pill);
    color: var(--white);
    font-family: 'Pretendard', sans-serif;
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    cursor: pointer;
    box-shadow: 0 10px 28px rgba(194,184,217,0.45);
    transition: var(--transition);
}
.btn-share:hover {
    transform: translateY(-4px);
    box-shadow: 0 18px 36px rgba(194,184,217,0.6);
}

/* ═══════════════════════════════════════════
   7. 유틸
═══════════════════════════════════════════ */
.instar3-gradient-text {
    background: var(--instar3-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: inline;
}

@keyframes fadeUp {
    from { opacity: 0; transform: translateX(-50%) translateY(30px); }
    to   { opacity: 1; transform: translateX(-50%) translateY(0);    }
}

/* ═══════════════════════════════════════════
   8. RESPONSIVE
═══════════════════════════════════════════ */
@media (max-width: 900px) {
    .detail-lead-card { padding: 48px 36px; }
    .lead-text { font-size: 17px; }
    .detail-body { padding: 0 24px 120px; }
    .detail-body .img-single,
    .detail-body .img-pair { margin-left: -24px; margin-right: -24px; }
    .detail-body blockquote { margin: 60px 0; padding: 40px 32px; }
    .detail-body blockquote p { font-size: 20px; }
    .detail-body h3 { font-size: 28px; }
}
@media (max-width: 600px) {
    .detail-lead-wrap { margin-top: -80px; padding: 0 20px; }
    .detail-hero__title { letter-spacing: -1px; }
    .detail-hero__meta { bottom: 60px; }
    .detail-body .img-pair { grid-template-columns: 1fr; }
    .related-nav { grid-template-columns: 1fr; }
    .detail-footer-bar { flex-direction: column; gap: 20px; }
    .btn-share { width: 100%; justify-content: center; }
}
</style>


<%-- ═══════════════ HTML ═══════════════ --%>
<div class="detail-page">

    <%-- ── 1. HERO ── --%>
    <section class="detail-hero" aria-label="Hero">
        <img id="heroParallax"
             class="detail-hero__img"
             src="<%= article.get("mainImg") %>"
             alt="<%= article.get("title") %>">
        <div class="detail-hero__gradient"></div>

        <div class="detail-hero__meta">
            <span class="detail-hero__vol">
                <%= article.get("vol") %> &nbsp;/&nbsp; <%= article.get("category") %>
            </span>
            <h1 class="detail-hero__title"><%= article.get("title") %></h1>
            <div class="detail-hero__info">
                <span><%= article.get("author") %></span>
                <span class="dot">·</span>
                <span><%= article.get("date") %></span>
                <span class="dot">·</span>
                <span><%= article.get("readTime") %></span>
            </div>
        </div>

        <div class="scroll-hint" aria-hidden="true">
            <div class="scroll-hint__line"></div>
            <span>SCROLL</span>
        </div>
    </section>


    <%-- ── 2. LEAD CARD (히어로 오버랩) ── --%>
    <div class="detail-lead-wrap">
        <div class="detail-lead-card">
            <span class="lead-badge"><%= article.get("category") %></span>
            <p class="lead-text"><%= article.get("lead") %></p>
            <div class="lead-divider"></div>
        </div>
    </div>


    <%-- ── 3. BODY ── --%>
    <article class="detail-body">

        <%-- 도입 --%>
        <p>도시의 소음에서 벗어나 오직 파도 소리와 바람의 속삭임만 허락된 곳. 우리는 그곳을 '쉼'이라 부르기로 했습니다. 제주는 흔히 알려진 관광지 너머, 아직 발견되지 않은 고요한 공간들을 품고 있습니다.</p>

        <%-- 단독 이미지 --%>
        <div class="img-single">
            <img src="https://picsum.photos/seed/stay1/1400/788"
                 alt="스테이 거실 전경">
        </div>
        <p class="img-caption">따뜻한 온기가 남아 있는 스테이의 거실</p>

        <%-- 섹션 1 --%>
        <h3>첫 번째 장소: 스테이 밤편지</h3>
        <p>서귀포 남원읍의 작은 마을, 돌담 너머로 보이는 하얀 집. 이곳은 단순히 머무는 곳을 넘어 에디터가 아껴둔 비밀스러운 일기장 같은 공간입니다.</p>
        <p>아침이면 창가로 스며드는 귤나무 그림자가 어제의 피로를 씻어내고, 밤이 되면 마당의 모닥불 소리가 잊고 지냈던 감각을 깨워줍니다.</p>

        <%-- 2열 이미지 --%>
        <div class="img-pair">
            <div class="img-pair-item">
                <img src="https://picsum.photos/seed/jeju1/800/600"
                     alt="제주 해변 뷰">
            </div>
            <div class="img-pair-item">
                <img src="https://picsum.photos/seed/cafe1/800/600"
                     alt="스테이 내부">
            </div>
        </div>

        <%-- 인용구 --%>
        <blockquote>
            <p>"서두르지 않아도 괜찮은 이곳에서,<br>당신만의 밤편지를 써보시길 바랍니다."</p>
            <cite>Editor. Tripan</cite>
        </blockquote>

        <%-- 섹션 2 --%>
        <h3>두 번째 장소: 카페 숨비소리</h3>
        <p>성산일출봉이 한눈에 내려다보이는 절벽 위 카페. '숨비소리'는 해녀가 물 위로 올라와 내쉬는 독특한 숨소리를 뜻합니다. 그 이름처럼, 이곳에서의 한 모금 커피는 숨통을 트이게 합니다.</p>

        <%-- 단독 이미지 --%>
        <div class="img-single">
            <img src="https://picsum.photos/seed/ocean1/1400/788"
                 alt="카페 전경">
        </div>
        <p class="img-caption">성산일출봉을 배경으로 즐기는 오션뷰 커피</p>

        <p>우리가 제안하는 이번 호의 테마는 '느린 호흡'입니다. 제주의 바람이 당신의 어깨를 살며시 두드릴 때, 비로소 진짜 여행이 시작됩니다. Tripan이 엄선한 이 공간들이 당신에게 온전한 쉼이 되기를 바랍니다.</p>

    </article>





    <%-- ── 5. FOOTER BAR ── --%>
    <div class="detail-footer-bar">
        <a href="${pageContext.request.contextPath}/curation/magazine_list" class="btn-back">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2.5"
                 stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"/>
                <polyline points="12 19 5 12 12 5"/>
            </svg>
            BACK TO LIST
        </a>
        <button class="btn-share" onclick="handleShare()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2.5"
                 stroke-linecap="round" stroke-linejoin="round">
                <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/>
                <circle cx="18" cy="19" r="3"/>
                <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
                <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
            </svg>
            SHARE STORY
        </button>
    </div>

</div><%-- /detail-page --%>


<jsp:include page="../layout/footer.jsp" />


<script>
/* ── 패럴랙스 ── */
(function() {
    const hero = document.getElementById('heroParallax');
    if (!hero) return;
    let ticking = false;
    window.addEventListener('scroll', function() {
        if (!ticking) {
            requestAnimationFrame(function() {
                const y = window.pageYOffset;
                hero.style.transform = 'translateY(' + (y * 0.3) + 'px)';
                ticking = false;
            });
            ticking = true;
        }
    });
})();

/* ── 공유 ── */
function handleShare() {
    if (navigator.share) {
        navigator.share({
            title: document.title,
            url: location.href
        }).catch(function() {});
    } else {
        navigator.clipboard.writeText(location.href).then(function() {
            alert('링크가 복사되었습니다!');
        });
    }
}
</script>
