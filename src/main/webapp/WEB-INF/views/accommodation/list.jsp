<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="../layout/header.jsp" />

<style>
  .list-page-container {
    max-width: 1400px;
    margin: 140px auto 100px;
    padding: 0 5%;
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: 40px;
  }

  /* 좌측 필터 영역 */
  .filter-sidebar {
    background: var(--bg-white);
    padding: 32px 24px;
    border-radius: var(--radius-lg);
    box-shadow: 0 12px 24px rgba(45, 55, 72, 0.04);
    border: 1px solid var(--border-light);
    height: fit-content;
    position: sticky;
    top: 100px;
  }

  .filter-group {
    margin-bottom: 32px;
    border-bottom: 1px solid var(--bg-light);
    padding-bottom: 24px;
  }
  
  .filter-group:last-child {
    border-bottom: none;
    margin-bottom: 0;
    padding-bottom: 0;
  }

  .filter-title {
    font-size: 16px;
    font-weight: 900;
    color: var(--text-black);
    margin-bottom: 16px;
  }

  .check-label {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 14px;
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 12px;
    cursor: pointer;
  }

  .check-label input[type="checkbox"] {
    width: 18px;
    height: 18px;
    accent-color: var(--point-blue);
    cursor: pointer;
  }

  /* 우측 숙소 그리드 영역 */
  .acc-grid-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
  }

  .acc-grid-header h1 {
    font-size: 24px;
    font-weight: 900;
  }

  .acc-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 32px;
  }

  /* 리스트용 카드 약간 수정 */
  .grid-card {
    width: 100%;
    min-width: unset;
  }

  @media (max-width: 992px) {
    .list-page-container {
      grid-template-columns: 1fr;
    }
    .filter-sidebar {
      position: relative;
      top: 0;
    }
  }
</style>

<main class="reveal active">
  <div class="list-page-container">
    
    <aside class="filter-sidebar">
      <form action="${pageContext.request.contextPath}/accommodation/list" method="GET" id="filterForm">
        
        <div class="filter-group">
          <h3 class="filter-title">숙소 유형</h3>
          <label class="check-label"><input type="checkbox" name="type" value="hotel"> 호텔/리조트</label>
          <label class="check-label"><input type="checkbox" name="type" value="pension"> 펜션/풀빌라</label>
          <label class="check-label"><input type="checkbox" name="type" value="guest"> 게스트하우스</label>
          <label class="check-label"><input type="checkbox" name="type" value="camping"> 캠핑/글램핑</label>
        </div>

        <div class="filter-group">
          <h3 class="filter-title">가격대 (1박 기준)</h3>
          <label class="check-label"><input type="checkbox" name="price" value="under10"> 10만원 이하</label>
          <label class="check-label"><input type="checkbox" name="price" value="10to20"> 10만원 ~ 20만원</label>
          <label class="check-label"><input type="checkbox" name="price" value="20to30"> 20만원 ~ 30만원</label>
          <label class="check-label"><input type="checkbox" name="price" value="over30"> 30만원 이상</label>
        </div>

        <div class="filter-group">
          <h3 class="filter-title">인기 시설</h3>
          <label class="check-label"><input type="checkbox" name="amenity" value="pool"> 수영장</label>
          <label class="check-label"><input type="checkbox" name="amenity" value="bbq"> 바베큐장</label>
          <label class="check-label"><input type="checkbox" name="amenity" value="parking"> 무료 주차</label>
          <label class="check-label"><input type="checkbox" name="amenity" value="wifi"> 와이파이</label>
        </div>
        
        <button type="submit" class="btn-more" style="width: 100%; text-align: center; background: var(--text-black); color: white;">
          필터 적용하기
        </button>

      </form>
    </aside>

    <section class="acc-grid-area">
      <div class="acc-grid-header">
        <h1>강릉 지역 숙소 <span style="color: var(--point-blue);">128</span>개</h1>
        
        <select style="padding: 10px 16px; border-radius: var(--radius-pill); border: 1px solid var(--border-light); font-weight: 700; outline: none; background: white;">
          <option>추천순</option>
          <option>평점 높은 순</option>
          <option>리뷰 많은 순</option>
          <option>가격 낮은 순</option>
        </select>
      </div>

      <div class="acc-grid">
        <div class="list-item stay-card grid-card" onclick="location.href='${pageContext.request.contextPath}/accommodation/detail?id=1'">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <span class="tag">#오션뷰 #인피니티풀</span>
            <h4 style="margin-top: 8px;">스테이 폴라리스 (강릉)</h4>
            <p class="desc">강문해변 도보 5분 거리</p>
            <p class="stay-price">₩ 180,000 <span>⭐ 4.9</span></p>
          </div>
        </div>

        <div class="list-item stay-card grid-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <span class="tag">#독채 #프라이빗</span>
            <h4 style="margin-top: 8px;">강릉 씨마크 리조트</h4>
            <p class="desc">전 객실 파노라마 오션뷰</p>
            <p class="stay-price">₩ 420,000 <span>⭐ 4.9</span></p>
          </div>
        </div>
        
        <div class="list-item stay-card grid-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"></div>
          <div class="list-info">
            <span class="tag">#가성비 #조식제공</span>
            <h4 style="margin-top: 8px;">세인트존스 호텔</h4>
            <p class="desc">반려동물 동반 가능 객실 보유</p>
            <p class="stay-price">₩ 125,000 <span>⭐ 4.6</span></p>
          </div>
        </div>
        </div>
      
    </section>

  </div>
</main>

<jsp:include page="../layout/footer.jsp" />