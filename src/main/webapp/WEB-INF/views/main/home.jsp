<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="../layout/header.jsp" />

  <main>
    <div class="hero">
      <div class="hero-img" id="heroBg">
        <img src="https://images.unsplash.com/photo-1540541338287-41700207dee6?q=80&w=2070&auto=format&fit=crop" alt="Clear Aqua Travel with Resort">
      </div>
      <div class="hero-overlay">
        <h2 class="hero-title reveal active delay-100">우리만의 완벽한 여행 지도,<br>함께 그리고 1초 만에 정산해요</h2>
        <p class="hero-subtitle reveal active delay-200">구글 문서처럼 동시에 편집하고, 인스타처럼 공유하는 실시간 소셜 플래너</p>
        
        <div class="reference-search reveal active delay-200">
          <div class="search-block">
            <span class="search-label">DESTINATION</span>
            <input type="text" class="search-input" placeholder="어디로 떠나시나요? (예: 제주도)">
          </div>
          <div class="search-block">
            <span class="search-label">DATES</span>
            <input type="text" class="search-input" placeholder="언제 떠나시나요?">
          </div>
          <div class="search-block">
            <span class="search-label">MEMBERS</span>
            <input type="text" class="search-input" placeholder="몇 명이서 가나요?">
          </div>
          <button class="btn-search-circle" aria-label="검색">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </button>
        </div>
      </div>
    </div>

    <section>
      <div class="feed-header reveal">
        <div>
          <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">실시간 인기 피드 🔥</h2>
          <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">지금 이 순간 가장 많이 담겨진 여행 코스</p>
        </div>
        <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/magazine_list'">전체보기 →</button>
      </div>
      
      <div class="carousel-wrapper reveal">
        <button class="nav-arrow prev">←</button>
        <div class="horizontal-list">
          <div class="list-item">
            <div class="list-img">
              <div class="floating-badge">❤️ 890</div>
              <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=600&q=80" alt="Busan">
            </div>
            <div class="list-info">
              <span class="tag">#부산 #해운대</span>
              <h4>부산 2박3일 핫플 뿌시기</h4>
              <p class="desc">담아오기 1,204회 기록 돌파!</p>
              <div class="author-info">
                <div class="author-pic"><img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"></div>
                @travel_holic
              </div>
            </div>
          </div>
          <div class="list-item">
            <div class="list-img">
              <div class="floating-badge">❤️ 750</div>
              <img src="https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=600&q=80" alt="Jeju">
            </div>
            <div class="list-info">
              <span class="tag">#제주도 #오션뷰</span>
              <h4>제주 동쪽 감성 숙소 투어</h4>
              <p class="desc">담아오기 980회 돌파!</p>
              <div class="author-info">
                <div class="author-pic"><img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=100&q=80"></div>
                @jeju_vibe
              </div>
            </div>
          </div>
          <div class="list-item">
            <div class="list-img">
              <div class="floating-badge">❤️ 620</div>
              <img src="https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=600&q=80" alt="Sokcho">
            </div>
            <div class="list-info">
              <span class="tag">#속초 #먹방투어</span>
              <h4>속초 1박 2일 맛집 지도</h4>
              <p class="desc">가성비 끝판왕 N빵 정산 공개</p>
              <div class="author-info">
                <div class="author-pic"><img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80"></div>
                @n_bread_master
              </div>
            </div>
          </div>
          <div class="list-item">
            <div class="list-img">
              <div class="floating-badge">❤️ 540</div>
              <img src="https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80" alt="Gangneung">
            </div>
            <div class="list-info">
              <span class="tag">#강릉 #해안도로</span>
              <h4>강릉 드라이브 코스</h4>
              <p class="desc">인생샷 보장하는 로드트립</p>
              <div class="author-info">
                <div class="author-pic"><img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80"></div>
                @world_driver
              </div>
            </div>
          </div>
        </div>
        <button class="nav-arrow next">→</button>
      </div>
    </section>

    <section>
      <div class="feed-header reveal">
        <div>
          <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">최근 살펴본 핫플 리스트 👀</h2>
          <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">나의 동선에 맞춰 추천된 감성 숙소</p>
        </div>
        <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/magazine_list'">더보기 →</button>
      </div>
      
      <div class="carousel-wrapper reveal">
        <button class="nav-arrow prev">←</button>
        <div class="horizontal-list">
          <div class="list-item stay-card">
            <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80" alt="Gangneung"></div>
            <div class="list-info">
              <h4>스테이 폴라리스 (강릉)</h4>
              <p class="desc">오션뷰 · 인피니티 풀</p>
              <p class="stay-price">₩ 180,000 ~ <span>⭐ 4.9</span></p>
            </div>
          </div>
          <div class="list-item stay-card">
            <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80" alt="Namhae"></div>
            <div class="list-info">
              <h4>루나 부티크 펜션 (남해)</h4>
              <p class="desc">프라이빗 바베큐 · 독채 풀빌라</p>
              <p class="stay-price">₩ 240,000 ~ <span>⭐ 4.8</span></p>
            </div>
          </div>
          <div class="list-item stay-card">
            <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80" alt="Gapyeong"></div>
            <div class="list-info">
              <h4>포레스트 캐빈 (가평)</h4>
              <p class="desc">감성 글램핑 · 불멍 화로대</p>
              <p class="stay-price">₩ 150,000 ~ <span>⭐ 4.7</span></p>
            </div>
          </div>
          <div class="list-item stay-card">
            <div class="list-img"><img src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=600&q=80" alt="Seoul"></div>
            <div class="list-info">
              <h4>신라 파크뷰 호텔 (서울)</h4>
              <p class="desc">시티뷰 · 라운지 억세스</p>
              <p class="stay-price">₩ 420,000 ~ <span>⭐ 4.9</span></p>
            </div>
          </div>
        </div>
        <button class="nav-arrow next">→</button>
      </div>
    </section>

    <section>
      <div class="feed-header reveal">
        <div>
          <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">Tripan TOP 10 🏆</h2>
          <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">유저 평점이 증명하는 믿고 가는 스테이</p>
        </div>
        <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/place_list'">랭킹 전체보기 →</button>
      </div>
      
      <div class="carousel-wrapper reveal">
        <button class="nav-arrow prev">←</button>
        <div class="horizontal-list">
          <div class="list-item stay-card">
            <div class="list-img">
              <div class="floating-badge" style="background: var(--text-black); color: var(--point-yellow);">👑 TOP 1</div>
              <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=600&q=80" alt="Top 1">
            </div>
            <div class="list-info">
              <h4>아만 스위트 리저브 (제주)</h4>
              <p class="desc">⭐ 4.9 · 리뷰 1,204개</p>
            </div>
          </div>
          <div class="list-item stay-card">
            <div class="list-img">
              <div class="floating-badge" style="color: var(--text-black); background: var(--bg-white);">TOP 2</div>
              <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80" alt="Top 2">
            </div>
            <div class="list-info">
              <h4>그랜드 앰배서더 풀빌라</h4>
              <p class="desc">⭐ 4.8 · 리뷰 890개</p>
            </div>
          </div>
          <div class="list-item stay-card">
            <div class="list-img">
              <div class="floating-badge" style="color: var(--text-black); background: var(--bg-white);">TOP 3</div>
              <img src="https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=600&q=80" alt="Top 3">
            </div>
            <div class="list-info">
              <h4>신라 더 파크 호텔 (서울)</h4>
              <p class="desc">⭐ 4.8 · 리뷰 750개</p>
            </div>
          </div>
        </div>
        <button class="nav-arrow next">→</button>
      </div>
    </section>
  </main>

<jsp:include page="../layout/footer.jsp" />