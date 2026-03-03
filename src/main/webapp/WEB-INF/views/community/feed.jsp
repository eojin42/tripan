<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 소셜 커뮤니티</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <style>
    /* --- ☁️ Tripan Community Theme --- */
    :root {
      /* Sky2 & Instar3 혼합 파스텔 톤 */
      --sky-blue: #89CFF0;
      --light-pink: #FFB6C1;
      --ice-melt: #A8C8E1;
      --rain-pink: #E0BBC2;
      
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --grad-sub: linear-gradient(120deg, var(--ice-melt) 0%, #C2B8D9 50%, var(--rain-pink) 100%);
      
      --bg-page: #F0F8FF; 
      --glass-bg: rgba(255, 255, 255, 0.65);
      --glass-border: rgba(255, 255, 255, 0.8);
      
      --text-black: #2D3748;
      --text-dark: #4A5568;
      --text-gray: #718096;
      --radius-xl: 24px;
      --bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
    }

    body {
      background-color: var(--bg-page);
      color: var(--text-black);
      font-family: 'Pretendard', sans-serif;
      margin: 0; padding: 0;
      background-image: 
        radial-gradient(at 0% 0%, rgba(137, 207, 240, 0.15) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(255, 182, 193, 0.15) 0px, transparent 50%);
      background-attachment: fixed;
    }

    /* 💡 3단 그리드 레이아웃 (상단 정렬 align-items: start 유지) */
    .community-container {
      max-width: 1400px;
      margin: 120px auto 60px; /* 헤더 여백 */
      padding: 0 5%;
      display: grid;
      grid-template-columns: 280px 1fr 320px;
      gap: 32px;
      align-items: start; 
    }

    /* 공통 글래스 카드 */
    .glass-card {
      background: var(--glass-bg);
      backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border);
      border-radius: var(--radius-xl);
      padding: 24px;
      box-shadow: 0 12px 32px rgba(45, 55, 72, 0.04);
      margin-bottom: 24px; /* 카드 간 기본 여백 */
    }

    /* --- [Left] 사이드바 (프로필, ⭐️메뉴, 채팅) --- */
    .profile-widget { text-align: center; }
    .profile-avatar { width: 80px; height: 80px; border-radius: 50%; border: 3px solid white; box-shadow: 0 8px 16px rgba(137, 207, 240, 0.3); margin: 0 auto 12px; overflow: hidden; }
    .profile-avatar img { width: 100%; height: 100%; object-fit: cover; }
    .profile-name { font-size: 18px; font-weight: 900; }
    .profile-stats { display: flex; justify-content: space-around; margin-top: 16px; padding-top: 16px; border-top: 1px dashed rgba(45,55,72,0.1); }
    .stat-box { display: flex; flex-direction: column; font-size: 13px; color: var(--text-gray); font-weight: 600; }
    .stat-box strong { font-size: 18px; color: var(--text-black); font-weight: 900; }

    /* 💡 신규: 좌측 네비게이션 메뉴 위젯 */
    .side-menu-widget { padding: 16px; }
    .side-nav { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px; }
    .side-nav li { border-radius: 16px; overflow: hidden; }
    .side-nav a { display: flex; align-items: center; gap: 12px; padding: 14px 20px; color: var(--text-dark); font-weight: 800; font-size: 15px; text-decoration: none; transition: all 0.3s; }
    .side-nav a:hover { background: rgba(255, 255, 255, 0.8); color: var(--sky-blue); padding-left: 24px; }
    .side-nav li.active a { background: var(--grad-main); color: white; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.4); padding-left: 20px; }

    .chat-widget h3 { font-size: 16px; font-weight: 800; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between; }
    .chat-room { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 16px; transition: background 0.3s; cursor: pointer; margin-bottom: 8px; }
    .chat-room:hover { background: rgba(255,255,255,0.9); }
    .chat-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--grad-sub); display: flex; align-items: center; justify-content: center; font-size: 20px; }
    .chat-info h4 { margin: 0; font-size: 14px; font-weight: 800; }
    .chat-info p { margin: 4px 0 0; font-size: 12px; color: var(--text-gray); }
    .live-dot { width: 8px; height: 8px; background: #FF6B6B; border-radius: 50%; box-shadow: 0 0 8px #FF6B6B; animation: pulse 1.5s infinite; }

    /* --- [Center] 메인 피드 (상단 여백 제거하여 좌/우와 높이 맞춤) --- */
    .feed-main { display: flex; flex-direction: column; gap: 24px; margin: 0px auto;} /* 카드 사이 간격 */
    
    .feed-card { padding: 0; overflow: hidden; margin-bottom: 0; }
    .feed-author { display: flex; align-items: center; justify-content: space-between; padding: 20px; }
    .author-left { display: flex; align-items: center; gap: 12px; }
    .author-left img { width: 40px; height: 40px; border-radius: 50%; }
    .author-left .name { font-weight: 800; font-size: 15px; }
    .author-left .time { font-size: 12px; color: var(--text-gray); }
    .btn-follow { padding: 6px 16px; border-radius: 20px; background: var(--bg-page); color: var(--sky-blue); font-weight: 800; font-size: 13px; border: none; cursor: pointer; transition: 0.3s; }
    .btn-follow:hover { background: var(--sky-blue); color: white; }

    .feed-img { width: 100%; aspect-ratio: 4/3; background: #ddd; position: relative; }
    .feed-img img { width: 100%; height: 100%; object-fit: cover; }
    
    .feed-content { padding: 20px; }
    .feed-text { font-size: 15px; line-height: 1.6; color: var(--text-dark); margin-bottom: 16px; }
    .feed-tags { color: var(--sky-blue); font-weight: 700; font-size: 14px; margin-bottom: 20px; }

    /* 일정 담아오기 위젯 */
    .itinerary-snippet { background: rgba(240, 248, 255, 0.5); border: 1px solid rgba(137, 207, 240, 0.3); border-radius: 16px; padding: 16px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
    .iti-info h5 { margin: 0 0 4px 0; font-size: 15px; font-weight: 800; }
    .iti-info p { margin: 0; font-size: 13px; color: var(--text-gray); font-weight: 600; }
    .btn-scrap { background: var(--grad-main); color: white; border: none; padding: 10px 20px; border-radius: 20px; font-weight: 800; font-size: 14px; cursor: pointer; box-shadow: 0 4px 16px rgba(137, 207, 240, 0.4); transition: transform 0.3s var(--bounce); display: flex; align-items: center; gap: 6px; }
    .btn-scrap:hover { transform: translateY(-3px) scale(1.05); }

    .feed-actions { display: flex; gap: 16px; padding-top: 16px; border-top: 1px solid rgba(0,0,0,0.05); }
    .action-btn { display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; color: var(--text-gray); cursor: pointer; transition: 0.3s; }
    .action-btn:hover { color: var(--light-pink); }

    /* --- [Right] 우측 위젯 (행사 & 미니게임) --- */
    .widget-header { font-size: 16px; font-weight: 800; margin-bottom: 16px; }
    
    .festival-list { display: flex; flex-direction: column; gap: 12px; margin-bottom: 8px; }
    .festival-item { display: flex; gap: 12px; align-items: center; background: rgba(255,255,255,0.8); padding: 10px; border-radius: 12px; transition: 0.3s; cursor: pointer; }
    .festival-item:hover { transform: translateX(-4px); box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    .fes-date { background: var(--grad-sub); color: white; border-radius: 8px; padding: 8px; text-align: center; line-height: 1.2; min-width: 45px; }
    .fes-date span { display: block; font-size: 10px; font-weight: 600; text-transform: uppercase; }
    .fes-date strong { font-size: 16px; font-weight: 900; }
    .fes-info h4 { margin: 0 0 4px; font-size: 13px; font-weight: 800; }
    .fes-info p { margin: 0; font-size: 11px; color: var(--text-gray); }

    /* 🎮 여행지 룰렛 미니게임 위젯 */
    .game-widget { text-align: center; padding: 32px 20px; background: var(--grad-main); color: white; border-radius: var(--radius-xl); box-shadow: 0 12px 24px rgba(255, 182, 193, 0.4); position: relative; overflow: hidden; margin-bottom: 24px; }
    .game-widget::before { content: '✈️'; font-size: 100px; position: absolute; opacity: 0.1; top: -10px; right: -20px; transform: rotate(-15deg); }
    .game-widget h3 { font-size: 20px; font-weight: 900; margin: 0 0 8px; }
    .game-widget p { font-size: 13px; font-weight: 600; opacity: 0.9; margin: 0 0 20px; }
    .btn-game { background: white; color: var(--sky-blue); font-weight: 900; font-size: 15px; border: none; padding: 12px 24px; border-radius: 24px; cursor: pointer; box-shadow: 0 8px 16px rgba(0,0,0,0.1); transition: 0.3s var(--bounce); width: 100%; }
    .btn-game:hover { transform: scale(1.05); box-shadow: 0 12px 24px rgba(0,0,0,0.15); }

    @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(255,107,107, 0.7); } 70% { box-shadow: 0 0 0 10px rgba(255,107,107, 0); } 100% { box-shadow: 0 0 0 0 rgba(255,107,107, 0); } }

    /* 반응형 */
    @media (max-width: 1024px) {
      .community-container { grid-template-columns: 1fr 300px; }
      .left-sidebar { display: none; }
    }
    @media (max-width: 768px) {
      .community-container { grid-template-columns: 1fr; margin-top: 80px; }
      .right-sidebar { display: none; }
    }
  </style>
</head>
<body>

  <jsp:include page="/WEB-INF/views/layout/header.jsp"/>

  <main class="community-container">
    
    <aside class="left-sidebar">
      <div class="glass-card profile-widget">
        <div class="profile-avatar">
          <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200" alt="My Profile">
        </div>
        <div class="profile-name">${sessionScope.member.nickname != null ? sessionScope.member.nickname : '여행자'} 님</div>
        <div class="profile-stats">
          <div class="stat-box">게시물 <strong>0</strong></div>
          <div class="stat-box">팔로워 <strong>0</strong></div>
          <div class="stat-box">팔로잉 <strong>0</strong></div>
        </div>
      </div>

      <div class="glass-card side-menu-widget">
        <ul class="side-nav">
          <li class="active"><a href="#">📝 내 피드 (팔로우)</a></li>
          <li><a href="#">🔥 인기 급상승</a></li>
          <li><a href="#">💬 자유 게시판</a></li>
        </ul>
      </div>

      <div class="glass-card chat-widget">
        <h3>실시간 지역 톡 <span class="live-dot"></span></h3>
        <div class="chat-room">
          <div class="chat-icon">🌴</div>
          <div class="chat-info">
            <h4>제주도 동행/맛집 방</h4>
            <p>현재 124명 접속 중</p>
          </div>
        </div>
        <div class="chat-room">
          <div class="chat-icon">🌊</div>
          <div class="chat-info">
            <h4>부산 해운대 핫플 공유</h4>
            <p>현재 89명 접속 중</p>
          </div>
        </div>
        <div class="chat-room">
          <div class="chat-icon">🏔️</div>
          <div class="chat-info">
            <h4>강원도 렌터카 드라이브</h4>
            <p>현재 45명 접속 중</p>
          </div>
        </div>
      </div>
    </aside>

    <section class="feed-main">
      <article class="glass-card feed-card">
        <div class="feed-author">
          <div class="author-left">
            <img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100" alt="User">
            <div>
              <div class="name">@jeju_vibe (제주 감성)</div>
              <div class="time">2시간 전</div>
            </div>
          </div>
          <button class="btn-follow">팔로잉</button>
        </div>
        
        <div class="feed-img">
          <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800" alt="Feed Image">
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
            <button class="btn-scrap" onclick="cloneItinerary(1029)">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 4H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2v-2M16 4h2a2 2 0 012 2v4M21 14H11"></path><path d="M15 10l-4 4-4-4"></path></svg>
              일정 담아오기
            </button>
          </div>

          <div class="feed-actions">
            <div class="action-btn">❤️ 좋아요 245</div>
            <div class="action-btn">💬 댓글 32</div>
            <div class="action-btn">🔗 공유</div>
          </div>
        </div>
      </article>

      <article class="glass-card feed-card">
        <div class="feed-author">
          <div class="author-left">
            <img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100" alt="User">
            <div>
              <div class="name">@travel_holic</div>
              <div class="time">5시간 전</div>
            </div>
          </div>
          <button class="btn-follow" style="background:var(--sky-blue); color:white;">팔로우</button>
        </div>
        <div class="feed-content">
          <h4 style="margin: 0 0 12px; font-size: 18px; font-weight: 800;">오사카 주유패스 진짜 본전 뽑는 루트 질문요 🙏</h4>
          <p class="feed-text">
            다음 달에 친구들 3명이서 오사카 가는데, 주유패스 2일권 끊으려고 합니다.<br>
            유니버셜은 안 가고 시내 위주로 돌 건데, 효율 최강 동선 아시는 분 일정 좀 공유(담아오기) 허락해주세요!
          </p>
          <div class="feed-tags">#오사카 #질문 #일정공유좀</div>
          
          <div class="feed-actions">
            <div class="action-btn">❤️ 좋아요 12</div>
            <div class="action-btn">💬 댓글 8</div>
          </div>
        </div>
      </article>
    </section>

    <aside class="right-sidebar">
      <div class="glass-card">
        <h3 class="widget-header">🎉 내 주변 지역 축제</h3>
        <div class="festival-list">
          <div class="festival-item">
            <div class="fes-date"><span>AUG</span><strong>15</strong></div>
            <div class="fes-info">
              <h4>광안리 M 드론 라이트쇼</h4>
              <p>부산광역시 수영구 광안해변로</p>
            </div>
          </div>
          <div class="festival-item">
            <div class="fes-date"><span>AUG</span><strong>22</strong></div>
            <div class="fes-info">
              <h4>제주 감귤 팜파티 페스타</h4>
              <p>제주 서귀포시 농업기술센터</p>
            </div>
          </div>
        </div>
      </div>

      <div class="game-widget">
        <h3>어디 갈지 고민될 땐?</h3>
        <p>Tripan AI 룰렛이 취향에 맞춰<br>완벽한 목적지를 골라드려요!</p>
        <button class="btn-game" onclick="startRoulette()">🎲 랜덤 여행지 뽑기</button>
      </div>
    </aside>

  </main>

  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

  <script>
    function cloneItinerary(itineraryId) {
      alert("✨ 일정을 내 보관함으로 담아왔습니다!\n나만의 스타일로 수정해보세요.");
    }
    function startRoulette() {
      const dests = ['여수 밤바다 낭만 투어', '경주 황리단길 카페 투어', '강원도 양양 서핑 트립', '제주도 한라산 등반'];
      const random = dests[Math.floor(Math.random() * dests.length)];
      alert("🎲 추천 결과: [" + random + "]\n관련 피드와 숙소를 검색해볼까요?");
    }
  </script>
</body>
</html>