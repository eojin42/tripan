<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="../layout/header.jsp" />

<style>
  /* --- 메인 히어로 스타일 --- */
  .acc-hero {
    position: relative; width: 100%; height: 60vh; min-height: 500px;
    border-radius: 0 0 48px 48px; overflow: hidden; margin-bottom: 80px;
  }
  .hero-overlay {
    position: absolute; inset: 0; z-index: 2;
    background: linear-gradient(180deg, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.4) 100%); 
    display: flex; flex-direction: column; justify-content: center; align-items: center; color: white;
  }
  
  /* ✅ 클래스명 변경: .region-search-box -> .hero-main-search */
  .hero-main-search {
    background: var(--bg-white); width: 90%; max-width: 700px;
    border-radius: var(--radius-lg); padding: 32px 40px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15); text-align: center;
    transform: translateY(60px); color: var(--text-black);
    cursor: pointer; transition: transform 0.3s;
  }
  .hero-main-search:hover { transform: translateY(55px); }

  .hero-search-title { font-size: 24px; font-weight: 900; margin-bottom: 24px; }
  
  .hero-input-fake {
    display: flex; justify-content: space-between; align-items: center;
    padding: 16px 24px; border: 1px solid var(--text-black);
    border-radius: var(--radius-sm); background: var(--bg-white);
    font-size: 18px; font-weight: 800;
  }

  /* 카테고리 스타일 */
  .acc-category-wrap { display: flex; justify-content: center; gap: 32px; margin-bottom: 80px; flex-wrap: wrap; }
  .category-item { display: flex; flex-direction: column; align-items: center; gap: 12px; cursor: pointer; transition: all 0.3s; color: var(--text-gray); }
  .category-item:hover, .category-item.active { color: var(--text-black); transform: translateY(-5px); }
  .category-icon { width: 64px; height: 64px; border-radius: 50%; background: var(--bg-white); display: flex; align-items: center; justify-content: center; font-size: 28px; box-shadow: 0 8px 24px rgba(45, 55, 72, 0.06); border: 1px solid var(--border-light); }
  .category-item.active .category-icon { background: linear-gradient(135deg, var(--point-blue), var(--point-coral)); border: none; color: white; }

  @media (max-width: 768px) {
    .hero-main-search { width: 92%; padding: 24px; }
    .hero-input-fake { font-size: 15px; padding: 14px 16px; }
    .acc-hero { height: 50vh; min-height: 400px; border-radius: 0 0 32px 32px; }
  }
</style>

<main>
  <div class="acc-hero reveal active">
    <div class="hero-img">
      <img src="https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=2000&q=80" alt="Hero">
    </div>
    <div class="hero-overlay">
      <div class="hero-main-search" onclick="openModal('region')">
        <h3 class="hero-search-title">어디로 떠날까요?</h3>
        <div class="hero-input-fake">
          <span>📍 지역, 일정, 인원 선택</span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </div>
      </div>
    </div>
  </div>

  <section class="reveal">
    <div class="acc-category-wrap">
      <div class="category-item active"><div class="category-icon">✨</div><span style="font-weight:800; font-size:15px;">전체보기</span></div>
      <div class="category-item"><div class="category-icon">🌊</div><span style="font-weight:800; font-size:15px;">오션뷰</span></div>
      <div class="category-item"><div class="category-icon">🏕️</div><span style="font-weight:800; font-size:15px;">글램핑</span></div>
      <div class="category-item"><div class="category-icon">🏊‍♀️</div><span style="font-weight:800; font-size:15px;">풀빌라</span></div>
      <div class="category-item"><div class="category-icon">🏙️</div><span style="font-weight:800; font-size:15px;">호캉스</span></div>
    </div>

    <div class="feed-header" style="display:flex; justify-content:space-between; margin-bottom:24px;">
      <div>
        <h2 style="font-size:28px; font-weight:900; margin-bottom:8px;">이번 주말, 여기 어때요? 🧳</h2>
        <p style="font-size:15px; font-weight:600; color:var(--text-dark);">Tripan 유저들이 가장 많이 스크랩한 숙소</p>
      </div>
      <button class="btn-more" style="background:var(--bg-beige); border:none; padding:10px 20px; border-radius:20px; font-weight:800; cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/accommodation/list'">전체보기 →</button>
    </div>
    
    <div class="carousel-wrapper">
       <div class="horizontal-list" style="display:flex; gap:24px; overflow-x:auto; padding-bottom:20px;">
        <div class="list-item stay-card" style="min-width:300px; cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail?id=1'">
          <div style="border-radius:16px; overflow:hidden; margin-bottom:12px;">
            <img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600" style="width:100%; aspect-ratio:4/3; object-fit:cover;">
          </div>
          <h4>스테이 폴라리스 (강릉)</h4>
          <p style="color:var(--text-gray); font-size:14px;">오션뷰 · 인피니티 풀</p>
          <p style="font-weight:900; margin-top:4px;">₩ 180,000 ~</p>
        </div>
       </div>
    </div>
  </section>
</main>

<jsp:include page="../accommodation/searchModal.jsp" />
<jsp:include page="../layout/footer.jsp" />