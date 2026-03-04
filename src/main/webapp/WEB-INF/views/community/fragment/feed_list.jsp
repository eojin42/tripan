<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<style>
  /* 피드 카드 전용 스타일 */
  .feed-card { padding: 0; overflow: hidden; margin-bottom: 0; }
  .feed-author { display: flex; align-items: center; justify-content: space-between; padding: 24px 28px; }
  .author-left { display: flex; align-items: center; gap: 14px; }
  .author-left img { width: 44px; height: 44px; border-radius: 50%; }
  .author-left .name { font-weight: 800; font-size: 16px; }
  .author-left .time { font-size: 13px; color: var(--text-gray); margin-top: 2px; }
  
  .btn-follow { padding: 8px 18px; border-radius: 20px; background: var(--bg-page); color: var(--sky-blue); font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: 0.3s; }
  .btn-follow:hover { background: var(--sky-blue); color: white; }

  .feed-img { width: 100%; aspect-ratio: 16/9; max-height: 550px; background: #ddd; position: relative; }
  .feed-img img { width: 100%; height: 100%; object-fit: cover; }
  
  .feed-content { padding: 24px 28px 28px; }
  .feed-text { font-size: 16px; line-height: 1.7; color: var(--text-dark); margin-bottom: 20px; word-break: keep-all; }
  .feed-tags { color: var(--sky-blue); font-weight: 700; font-size: 15px; margin-bottom: 24px; }

  .itinerary-snippet { background: rgba(240, 248, 255, 0.5); border: 1px solid rgba(137, 207, 240, 0.3); border-radius: 16px; padding: 20px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
  .iti-info h5 { margin: 0 0 6px 0; font-size: 16px; font-weight: 800; }
  .iti-info p { margin: 0; font-size: 14px; color: var(--text-gray); font-weight: 600; }
  .btn-scrap { background: var(--grad-main); color: white; border: none; padding: 12px 24px; border-radius: 50px; font-weight: 800; font-size: 15px; cursor: pointer; box-shadow: 0 4px 16px rgba(137, 207, 240, 0.4); transition: transform 0.3s var(--bounce); display: flex; align-items: center; gap: 8px; }
  .btn-scrap:hover { transform: translateY(-3px) scale(1.05); }

  .feed-actions { display: flex; gap: 20px; padding-top: 20px; border-top: 1px solid rgba(0,0,0,0.05); }
  .action-btn { display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700; color: var(--text-gray); cursor: pointer; transition: 0.3s; }
  .action-btn:hover { color: var(--light-pink); }

  .infinite-scroll-trigger {
    padding: 30px; text-align: center; color: var(--sky-blue);
    font-size: 15px; font-weight: 800; margin-bottom: 20px;
    opacity: 0.8; transition: opacity 0.3s;
  }
</style>

<div id="feedListContainer" style="display: flex; flex-direction: column; gap: 24px;">

  <!-- 피드 카드 1 -->
  <article class="glass-card feed-card">
    <div class="feed-author">
      <div class="author-left">
        <img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100" alt="User">
        <div>
          <div class="name">@jeju_vibe (제주 감성)</div>
          <div class="time">2시간 전</div>
        </div>
      </div>
      <button class="btn-follow" onclick="checkAuthAndRun(() => alert('팔로우 완료!'))">팔로잉</button>
    </div>
    <div class="feed-img">
      <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=1200" alt="Feed Image">
    </div>
    <div class="feed-content">
      <p class="feed-text">
        이번 주말 다녀온 제주 동쪽 해안도로 드라이브 코스 완벽 정리! 🚗💨<br>
        날씨까지 너무 완벽해서 사진 100장 찍고 옴. 제가 짠 일정 그대로 복사해서 가시면 절대 실패 안 합니다. 맛집 N빵 내역도 포함!
      </p>
      <div class="feed-tags">#제주도 #해안도로 #주말여행 #가계부공개</div>
      
      <div class="itinerary-snippet">
        <div class="iti-info">
          <h5>📍 제주 동쪽 2박 3일 힐링 코스</h5>
          <p>장소 12곳 · 예상 경비 25만원/인</p>
        </div>
        <button class="btn-scrap" onclick="checkAuthAndRun(() => alert('✨ 일정을 내 보관함으로 담아왔습니다!'))">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 4H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2v-2M16 4h2a2 2 0 012 2v4M21 14H11"></path><path d="M15 10l-4 4-4-4"></path></svg>
          일정 담아오기
        </button>
      </div>

      <div class="feed-actions">
        <div class="action-btn" onclick="checkAuthAndRun(() => alert('좋아요!'))">❤️ 좋아요 245</div>
        <div class="action-btn" onclick="checkAuthAndRun(() => alert('댓글 창 열기'))">💬 댓글 32</div>
        <div class="action-btn">🔗 공유</div>
      </div>
    </div>
  </article>

  <!-- 피드 카드 2 -->
  <article class="glass-card feed-card">
    <div class="feed-author">
      <div class="author-left">
        <img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100" alt="User">
        <div>
          <div class="name">@travel_holic</div>
          <div class="time">5시간 전</div>
        </div>
      </div>
      <button class="btn-follow" style="background:var(--sky-blue); color:white;" onclick="checkAuthAndRun(() => alert('팔로우 완료!'))">팔로우</button>
    </div>
    <div class="feed-content">
      <h4 style="margin: 0 0 14px; font-size: 20px; font-weight: 800;">오사카 주유패스 진짜 본전 뽑는 루트 질문요 🙏</h4>
      <p class="feed-text">
        다음 달에 친구들 3명이서 오사카 가는데, 주유패스 2일권 끊으려고 합니다.<br>
        유니버셜은 안 가고 시내 위주로 돌 건데, 효율 최강 동선 아시는 분 일정 좀 공유(담아오기) 허락해주세요!
      </p>
      <div class="feed-tags">#오사카 #질문 #일정공유좀</div>
      <div class="feed-actions">
        <div class="action-btn" onclick="checkAuthAndRun(() => alert('좋아요!'))">❤️ 좋아요 12</div>
        <div class="action-btn" onclick="checkAuthAndRun(() => alert('댓글 창 열기'))">💬 댓글 8</div>
      </div>
    </div>
  </article>

</div>

<!-- 무한 스크롤 타겟 -->
<div id="infiniteScrollTarget" class="infinite-scroll-trigger">
  아래로 스크롤하여 더 보기...
</div>