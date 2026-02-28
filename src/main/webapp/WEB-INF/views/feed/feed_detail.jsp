<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  /*
   * Controller: CommunityController.java
   * [아키텍처 가이드] Feed, User, Tags, Itinerary Fetch Join (N+1 방지)
   */

  String feedTitle = "부산 2박3일 핫플 뚜시기 완벽 코스";
  String authorName = "@travel_holic";
  String authorAvatar = "https://picsum.photos/seed/user1/100/100";
  String createdAt = "2026-02-28 14:30";
  int viewCount = 4200;
  int likeCount = 890;
  int scrapCount = 1204;
  
  String[] tags = {"#부산", "#해운대", "#오션뷰", "#가성비", "#N빵완료"};
  String mainImage = "https://picsum.photos/seed/busan11/1200/600";
  
  // 1일차 일정 더미
  String[] day1Places = {"부산역 (KTX)", "해운대 밀면 (점심)", "시그니엘 부산 (체크인)", "해운대 블루라인파크", "더베이 101 (야경&맥주)"};
%>

<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
:root {
  --primary-blue: #0099CC;
  --primary-mint: #00A88F;
  --dark:         #1A202C;
  --mid:          #4A5568;
  --light:        #A0AEC0;
  --white:        #FFFFFF;
  --bg:           #F7F9FC;
  --bg-subtle:    #F0F4F8;
  --border:       #E8EDF4;
  --radius-lg:    20px;
  --radius-md:    12px;
  --shadow-soft:  0 8px 24px rgba(0,0,0,0.04);
  --shadow-hover: 0 12px 32px rgba(0,153,204,0.12);
  --glass-bg:     rgba(255, 255, 255, 0.9);
  --ease:         cubic-bezier(0.19,1,0.22,1);
}

body { font-family: 'Pretendard', sans-serif; background: var(--bg); color: var(--dark); margin: 0; padding: 0; }

/* 🚀 FIX: 상단 헤더 잘림 방지용 padding-top 추가 (헤더 높이에 따라 조절 가능) */
.detail-wrapper { max-width: 860px; margin: 0 auto; padding: 120px 20px 100px; }

/* ── 메인 이미지 (Hero) ── */
.feed-hero {
  position: relative; width: 100%; height: 420px; border-radius: var(--radius-lg);
  overflow: hidden; margin-bottom: 24px; box-shadow: var(--shadow-soft);
}
.feed-hero img { width: 100%; height: 100%; object-fit: cover; }
.feed-hero::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(15, 23, 42, 0.8) 0%, rgba(15, 23, 42, 0.2) 50%, transparent 100%);
}
.feed-hero-content {
  position: absolute; bottom: 32px; left: 32px; right: 32px; z-index: 2; color: var(--white);
}
.hero-tags { display: flex; gap: 8px; margin-bottom: 14px; flex-wrap: wrap; }
.hero-tag {
  background: rgba(255,255,255,0.25); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.3);
  padding: 6px 14px; border-radius: 50px; font-size: 13px; font-weight: 700; letter-spacing: -0.3px;
}
.hero-title { font-size: 34px; font-weight: 800; line-height: 1.3; letter-spacing: -0.5px; text-shadow: 0 2px 12px rgba(0,0,0,0.4); }

/* ── 작성자 정보 글래스모피즘 바 ── */
.author-bar {
  display: flex; align-items: center; justify-content: space-between;
  background: var(--glass-bg); backdrop-filter: blur(16px);
  padding: 16px 24px; border-radius: var(--radius-md); margin-top: -50px;
  position: relative; z-index: 10; box-shadow: 0 4px 16px rgba(0,0,0,0.06); border: 1px solid var(--white);
  margin-bottom: 40px; width: calc(100% - 48px); margin-left: auto; margin-right: auto;
}
.author-info { display: flex; align-items: center; gap: 14px; }
.author-avatar { width: 52px; height: 52px; border-radius: 50%; object-fit: cover; border: 2px solid var(--white); box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.author-meta .name { font-size: 16px; font-weight: 800; color: var(--dark); letter-spacing: -0.3px; }
.author-meta .date-view { font-size: 13px; color: var(--light); margin-top: 4px; font-weight: 500; }
.btn-follow {
  padding: 8px 22px; border-radius: 50px; font-weight: 700; font-size: 14px; cursor: pointer;
  background: var(--white); color: var(--primary-blue); border: 1.5px solid var(--primary-blue);
  transition: all 0.2s var(--ease);
}
.btn-follow:hover { background: var(--primary-blue); color: var(--white); }

/* 🚀 FIX: 본문(설명) 영역 디자인 고도화 */
.feed-body { 
  margin-bottom: 48px; 
  padding: 0 10px;
}

/* 감성적인 인용구 박스 스타일 */
.feed-story-box {
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: 32px 40px;
  box-shadow: var(--shadow-soft);
  border: 1px solid var(--border);
  position: relative;
}

.feed-story-box::before {
  content: '❝';
  position: absolute;
  top: 16px;
  left: 24px;
  font-size: 48px;
  color: var(--bg-subtle);
  font-family: serif;
  line-height: 1;
}

.story-text {
  font-size: 17px; 
  line-height: 1.85; 
  color: #333; /* 텍스트 가독성을 위해 살짝 짙게 */
  letter-spacing: -0.4px;
  position: relative;
  z-index: 2;
}

.story-text p { margin-bottom: 16px; }
.story-text p:last-child { margin-bottom: 0; }

.story-highlight {
  display: inline-block;
  background: linear-gradient(120deg, rgba(0,153,204,0.1) 0%, rgba(0,168,143,0.1) 100%);
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 700;
  color: var(--primary-blue);
}

/* ── 일정 (Itinerary) 요약 ── */
.itinerary-box {
  background: var(--white); border-radius: var(--radius-lg); padding: 36px 40px;
  box-shadow: var(--shadow-soft); border: 1px solid var(--border); margin-bottom: 40px;
}
.itinerary-header {
  font-size: 22px; font-weight: 800; color: var(--dark); margin-bottom: 24px;
  display: flex; align-items: center; gap: 8px; letter-spacing: -0.5px;
}
.day-title { font-size: 16px; font-weight: 800; color: var(--primary-blue); margin-bottom: 16px; display: inline-block; background: var(--bg-subtle); padding: 6px 14px; border-radius: 8px; }
.timeline { position: relative; padding-left: 24px; margin-bottom: 28px; }
.timeline::before {
  content: ''; position: absolute; left: 7px; top: 12px; bottom: 0;
  width: 2px; background: var(--border); border-radius: 2px;
}
.timeline-item { position: relative; margin-bottom: 20px; font-size: 16px; font-weight: 600; color: var(--mid); letter-spacing: -0.3px; display: flex; align-items: center; }
.timeline-item::before {
  content: ''; position: absolute; left: -24px; top: 50%; transform: translateY(-50%);
  width: 12px; height: 12px; border-radius: 50%; background: var(--white);
  border: 3px solid var(--primary-blue); z-index: 2;
}

/* ── 하단 액션 바 ── */
.action-bar {
  display: flex; justify-content: center; gap: 16px; border-top: 1px solid var(--border);
  padding-top: 40px; margin-bottom: 20px;
}
.btn-action {
  display: flex; align-items: center; gap: 10px; padding: 16px 36px;
  border-radius: 50px; font-size: 16px; font-weight: 800; cursor: pointer;
  border: none; transition: all 0.3s var(--ease);
}
.btn-like { background: var(--white); color: #E8849A; border: 1.5px solid #E8849A; }
.btn-like:hover { background: #FFF0F3; transform: translateY(-3px); box-shadow: 0 6px 16px rgba(232,132,154,0.15); }
.btn-scrap {
  background: linear-gradient(135deg, var(--primary-blue), var(--primary-mint));
  color: var(--white); box-shadow: 0 6px 20px rgba(0,168,143,0.25);
}
.btn-scrap:hover { transform: translateY(-3px); box-shadow: var(--shadow-hover); }

/* ── 반응형 ── */
@media (max-width: 768px) {
  .detail-wrapper { padding-top: 80px; }
  .feed-hero { height: 340px; border-radius: 0; margin-left: -20px; width: 100vw; }
  .author-bar { width: 100%; margin-top: -30px; border-radius: 0; border-left: none; border-right: none; }
  .feed-story-box { padding: 24px; border-radius: var(--radius-md); }
  .itinerary-box { padding: 24px; border-radius: var(--radius-md); }
}
</style>

<div class="detail-wrapper">
  
  <%-- Hero Section --%>
  <div class="feed-hero">
    <img src="<%= mainImage %>" alt="Cover Image">
    <div class="feed-hero-content">
      <div class="hero-tags">
        <% for(String tag : tags) { %>
          <span class="hero-tag"><%= tag %></span>
        <% } %>
      </div>
      <h1 class="hero-title"><%= feedTitle %></h1>
    </div>
  </div>

  <%-- Author Glass Bar --%>
  <div class="author-bar">
    <div class="author-info">
      <img src="<%= authorAvatar %>" alt="Avatar" class="author-avatar">
      <div class="author-meta">
        <div class="name"><%= authorName %></div>
        <div class="date-view"><%= createdAt %> · 조회 <%= viewCount %></div>
      </div>
    </div>
    <button class="btn-follow" onclick="toggleFollow(this)">팔로우</button>
  </div>

  <%-- Content Body (설명 부분 디자인 업그레이드) --%>
  <div class="feed-body">
    <div class="feed-story-box">
      <div class="story-text">
        <p>이번 주말, 친구들과 부산으로 훌쩍 떠났습니다! 바다도 보고 맛있는 것도 엄청 먹고 왔어요.</p>
        <p>특히 숙소가 에메랄드 빛 바다 뷰라서 너무 좋았네요. 영수증은 전부 <span class="story-highlight">Tripan 가계부로 N빵</span>해서 깔끔하게 정산했습니다.</p>
        <p>아래 일정 그대로 담아가시면 후회 없으실 거예요! 🌊💙</p>
      </div>
    </div>
  </div>

  <%-- Itinerary Snippet --%>
  <div class="itinerary-box">
    <div class="itinerary-header">🗺️ 추천 일정 요약 (1일차)</div>
    <div class="day-title">Day 1 - 도착 및 야경 투어</div>
    <div class="timeline">
      <% for(String place : day1Places) { %>
      <div class="timeline-item"><%= place %></div>
      <% } %>
    </div>
    <div style="text-align:center; margin-top: 16px; padding-top: 20px; border-top: 1px dashed var(--border);">
      <span style="font-size:14px; color:var(--light); font-weight: 500;">💡 일정을 담아가시면 2, 3일차 전체 코스와 상세 가계부(비용) 내역을 확인하고 내 마음대로 수정할 수 있습니다.</span>
    </div>
  </div>

  <%-- Actions --%>
  <div class="action-bar">
    <button class="btn-action btn-like" onclick="toggleLike(this)">
      <span class="icon">🤍</span> 좋아요 <%= likeCount %>
    </button>
    <button class="btn-action btn-scrap" onclick="executeDeepCopy()">
      <span class="icon">📥</span> 내 일정으로 담아오기 
    </button>
  </div>

</div>

<jsp:include page="../layout/footer.jsp" />

<script>
  function toggleFollow(btn) {
    const isFollowing = btn.classList.contains('active');
    if (isFollowing) {
      btn.classList.remove('active');
      btn.textContent = '팔로우';
      btn.style.background = 'var(--white)';
      btn.style.color = 'var(--primary-blue)';
    } else {
      btn.classList.add('active');
      btn.textContent = '팔로잉';
      btn.style.background = 'var(--bg-subtle)';
      btn.style.color = 'var(--mid)';
      btn.style.borderColor = 'transparent';
    }
  }

  function toggleLike(btn) {
    const icon = btn.querySelector('.icon');
    if (icon.textContent === '🤍') {
      icon.textContent = '❤️';
      btn.style.background = '#FFF0F3';
    } else {
      icon.textContent = '🤍';
      btn.style.background = 'var(--white)';
    }
  }

  function executeDeepCopy() {
    if(confirm("이 일정을 내 작업 공간으로 복사하시겠습니까?\n복사 후 자유롭게 편집하고 친구를 초대해 N빵할 수 있습니다.")) {
      alert('✅ 일정이 성공적으로 담겼습니다! 내 여행 메뉴에서 확인하세요.');
    }
  }
</script>