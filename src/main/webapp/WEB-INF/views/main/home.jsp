<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tripan</title>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
  <main>
    <div class="hero">
      <div class="hero-img">
        <img src="https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?auto=format&fit=crop&w=1920&q=80" alt="Active Travel">
      </div>
      <div class="hero-overlay">
        <span class="hero-label reveal">Tripan Social Collab</span>
        <h2 class="hero-title reveal delay-100">놀면서 짜는<br>진짜 우리만의 여행</h2>
        <p class="hero-subtitle reveal delay-200">구글 문서처럼 동시에 편집하고, 인스타처럼 공유하는 실시간 여행 플래너</p>
      </div>
    </div>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>실시간 인기 피드 🔥</h2>
          <p>지금 이 순간 가장 많이 담겨진 여행 코스</p>
        </div>
        <div class="btn-more">전체보기 ➔</div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item reveal">
          <div class="list-img">
            <div class="floating-badge">❤️ 890</div>
            <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=600&q=80" alt="Trip 1">
          </div>
          <div class="list-info">
            <span class="tag">#오사카 #가성비</span>
            <h4>오사카 3박4일 미친 동선</h4>
            <p class="desc">담아오기 1,204회 기록 돌파!</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"></div>
              @travel_holic
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-100">
          <div class="list-img">
            <div class="floating-badge">❤️ 750</div>
            <img src="https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=600&q=80" alt="Trip 2">
          </div>
          <div class="list-info">
            <span class="tag">#제주도 #오션뷰카페</span>
            <h4>제주 동쪽 감성 숙소 투어</h4>
            <p class="desc">담아오기 980회 돌파!</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=100&q=80"></div>
              @jeju_vibe
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-200">
          <div class="list-img">
            <div class="floating-badge">❤️ 620</div>
            <img src="https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=600&q=80" alt="Trip 3">
          </div>
          <div class="list-info">
            <span class="tag">#다낭 #먹방투어</span>
            <h4>다낭 4박 5일 1인 50컷</h4>
            <p class="desc">가성비 끝판왕 N빵 정산 내역 공개</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80"></div>
              @n_bread_master
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-300">
          <div class="list-img">
            <div class="floating-badge">❤️ 540</div>
            <img src="https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80" alt="Trip 4">
          </div>
          <div class="list-info">
            <span class="tag">#스위스 #렌터카</span>
            <h4>스위스 알프스 드라이브</h4>
            <p class="desc">인생샷 보장하는 로드트립 코스</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80"></div>
              @world_driver
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>최근 살펴본 핫플 숙소 ✨</h2>
          <p>내 취향에 딱 맞는 테마 추천 리스트</p>
        </div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item stay-card reveal">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80" alt="Stay 1"></div>
          <div class="list-info">
            <h4>스테이 폴라리스 (강릉)</h4>
            <p class="desc">오션뷰 · 인피니티 풀</p>
            <p class="stay-price">₩ 180,000 ~</p>
          </div>
        </div>
        <div class="list-item stay-card reveal delay-100">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80" alt="Stay 2"></div>
          <div class="list-info">
            <h4>루나 부티크 펜션 (남해)</h4>
            <p class="desc">프라이빗 바베큐 · 독채 풀빌라</p>
            <p class="stay-price">₩ 240,000 ~</p>
          </div>
        </div>
        <div class="list-item stay-card reveal delay-200">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80" alt="Stay 3"></div>
          <div class="list-info">
            <h4>포레스트 캐빈 (가평)</h4>
            <p class="desc">감성 글램핑 · 불멍 화로대</p>
            <p class="stay-price">₩ 150,000 ~</p>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>Tripan TOP 10 🏆</h2>
          <p>예약 평점이 증명하는 믿고 가는 스테이</p>
        </div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item stay-card reveal">
          <div class="list-img">
            <div class="floating-badge" style="background: var(--text-black); color: var(--pop-yellow);">👑 TOP 1</div>
            <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=600&q=80" alt="Top 1">
          </div>
          <div class="list-info">
            <h4>아만 스위트 리저브 (제주)</h4>
            <p class="desc">⭐ 4.9 · 리뷰 1,204개</p>
          </div>
        </div>
        
        <div class="list-item stay-card reveal delay-100">
          <div class="list-img">
            <div class="floating-badge">TOP 2</div>
            <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80" alt="Top 2">
          </div>
          <div class="list-info">
            <h4>그랜드 앰배서더 풀빌라 (부산)</h4>
            <p class="desc">⭐ 4.8 · 리뷰 890개</p>
          </div>
        </div>
        
        <div class="list-item stay-card reveal delay-200">
          <div class="list-img">
            <div class="floating-badge">TOP 3</div>
            <img src="https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=600&q=80" alt="Top 3">
          </div>
          <div class="list-info">
            <h4>신라 더 파크 호텔 (서울)</h4>
            <p class="desc">⭐ 4.8 · 리뷰 750개</p>
          </div>
        </div>
      </div>
    </section>
  </main>

<!-- 3. Footer 불러오기 -->
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>