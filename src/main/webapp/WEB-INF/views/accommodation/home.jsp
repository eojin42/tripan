<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="../layout/header.jsp" />

<style>
  /* 숙소 홈 전용 스타일 */
  .acc-hero {
    position: relative;
    width: 100%;
    height: 60vh;
    min-height: 500px;
    border-radius: 0 0 48px 48px;
    overflow: hidden;
    margin-bottom: 80px;
  }
  
  .acc-category-wrap {
    display: flex;
    justify-content: center;
    gap: 32px;
    margin-bottom: 80px;
    flex-wrap: wrap;
  }
  
  .category-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    transition: all 0.3s var(--bounce);
    color: var(--text-gray);
  }
  
  .category-item:hover, .category-item.active {
    color: var(--text-black);
    transform: translateY(-5px);
  }
  
  .category-icon {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: var(--bg-white);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    box-shadow: 0 8px 24px rgba(45, 55, 72, 0.06);
    border: 1px solid var(--border-light);
  }
  
  .category-item.active .category-icon {
    background: linear-gradient(135deg, var(--point-blue), var(--point-coral));
    border: none;
    color: white;
  }

  .category-name {
    font-size: 15px;
    font-weight: 800;
  }
</style>

<main>
  <div class="acc-hero reveal active">
    <div class="hero-img">
      <img src="https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=2000&q=80" alt="Accommodation Hero">
    </div>
    <div class="hero-overlay">
      <h2 class="hero-title">어디서 머물고 싶으신가요?</h2>
      
      <form action="${pageContext.request.contextPath}/accommodation/list" method="GET" class="reference-search">
        <div class="search-block">
          <span class="search-label">LOCATION</span>
          <input type="text" name="keyword" class="search-input" placeholder="여행지나 숙소명">
        </div>
        <div class="search-block">
          <span class="search-label">CHECK-IN / OUT</span>
          <input type="text" name="dates" class="search-input" placeholder="날짜 추가">
        </div>
        <div class="search-block">
          <span class="search-label">GUESTS</span>
          <input type="number" name="guests" class="search-input" placeholder="인원 추가" min="1">
        </div>
        <button type="submit" class="btn-search-circle" aria-label="검색">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </button>
      </form>
    </div>
  </div>

  <section class="reveal">
    <div class="acc-category-wrap">
      <div class="category-item active">
        <div class="category-icon">✨</div>
        <span class="category-name">전체보기</span>
      </div>
      <div class="category-item">
        <div class="category-icon">🌊</div>
        <span class="category-name">오션뷰</span>
      </div>
      <div class="category-item">
        <div class="category-icon">🏕️</div>
        <span class="category-name">글램핑</span>
      </div>
      <div class="category-item">
        <div class="category-icon">🏊‍♀️</div>
        <span class="category-name">풀빌라</span>
      </div>
      <div class="category-item">
        <div class="category-icon">🏙️</div>
        <span class="category-name">도심호캉스</span>
      </div>
    </div>

    <div class="feed-header">
      <div>
        <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">이번 주말, 여기 어때요? 🧳</h2>
        <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">Tripan 유저들이 가장 많이 스크랩한 숙소</p>
      </div>
      <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/accommodation/list'">전체보기 →</button>
    </div>
    
    <div class="carousel-wrapper">
      <div class="horizontal-list">
        <div class="list-item stay-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail?id=1'">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <h4>스테이 폴라리스 (강릉)</h4>
            <p class="desc">오션뷰 · 인피니티 풀</p>
            <p class="stay-price">₩ 180,000 ~ <span>⭐ 4.9</span></p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <h4>루나 부티크 펜션 (남해)</h4>
            <p class="desc">프라이빗 바베큐 · 독채 풀빌라</p>
            <p class="stay-price">₩ 240,000 ~ <span>⭐ 4.8</span></p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <h4>포레스트 캐빈 (가평)</h4>
            <p class="desc">감성 글램핑 · 불멍 화로대</p>
            <p class="stay-price">₩ 150,000 ~ <span>⭐ 4.7</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</main>

<jsp:include page="../layout/footer.jsp" />