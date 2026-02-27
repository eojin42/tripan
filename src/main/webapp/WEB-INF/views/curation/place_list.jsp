<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> destinations = new ArrayList<>();
    
    // --- 📸 관광지 데이터 ---
    destinations.add(Map.of("id", 1, "name", "제주 우도 해안길 자전거 투어", "desc", "에메랄드빛 바다를 옆에 두고 달리는 힐링 코스. 땅콩 아이스크림은 필수!", "image", "https://images.unsplash.com/photo-1551641506-ee5bf4cb45f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("자연", "바다", "액티비티"), "category", "관광지", "rating", 4.9));
    destinations.add(Map.of("id", 2, "name", "부산 광안리 요트 투어", "desc", "광안대교 야경과 함께하는 프라이빗 요트 파티. 인생샷 보장!", "image", "https://images.unsplash.com/photo-1534351590666-13e3e96b5017?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("야경", "바다", "로맨틱"), "category", "관광지", "rating", 4.8));
    destinations.add(Map.of("id", 3, "name", "강릉 안목해변 커피거리", "desc", "향긋한 커피 내음과 푸른 동해바다의 완벽한 조화. 조용한 힐링 코스.", "image", "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("감성", "휴식", "바다"), "category", "관광지", "rating", 4.7));
    destinations.add(Map.of("id", 4, "name", "경주 대릉원 & 황리단길", "desc", "천년 고도 경주에서 즐기는 레트로 감성 투어.", "image", "https://images.unsplash.com/photo-1578637387939-43c525550085?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("역사", "사진", "뚜벅이"), "category", "관광지", "rating", 4.9));

    // --- 🛌 숙소 데이터 ---
    destinations.add(Map.of("id", 5, "name", "제주 파르나스 호텔", "desc", "절벽 위에서 바라보는 끝없는 오션뷰. 인피니티 풀에서 인생샷을 남겨보세요.", "image", "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("호캉스", "오션뷰", "수영장"), "category", "숙소", "rating", 4.9));
    destinations.add(Map.of("id", 6, "name", "부산 힐튼 아난티 코브", "desc", "이국적인 풍경의 럭셔리 리조트. 프라이빗한 휴식을 원한다면.", "image", "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("럭셔리", "휴양", "가족여행"), "category", "숙소", "rating", 4.8));
    destinations.add(Map.of("id", 7, "name", "서울 신라호텔", "desc", "도심 속 최고의 호캉스. 남산 타워 뷰와 어번 아일랜드의 조화.", "image", "https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("도심", "호캉스", "파인다이닝"), "category", "숙소", "rating", 4.9));
    destinations.add(Map.of("id", 8, "name", "전주 한옥마을 다락", "desc", "고즈넉한 한옥에서의 하룻밤. 따뜻한 온돌방과 정갈한 조식.", "image", "https://images.unsplash.com/photo-1515096788709-a3cf4ce0a4a6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("감성숙소", "한옥", "힐링"), "category", "숙소", "rating", 4.7));

    // --- 🍽️ 식당 데이터 ---
    destinations.add(Map.of("id", 9, "name", "제주 흑돼지 전문점 '돈사돈'", "desc", "육즙 가득한 두툼한 흑돼지 구이. 멜젓에 찍어 먹는 환상의 맛.", "image", "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("맛집", "흑돼지", "로컬"), "category", "식당", "rating", 4.6));
    destinations.add(Map.of("id", 10, "name", "부산 해운대 '거대갈비'", "desc", "입에서 녹는 최상급 한우 암소 갈비. 특별한 날을 위한 최고의 선택.", "image", "https://images.unsplash.com/photo-1600891964092-4316c288032e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("소고기", "파인다이닝", "기념일"), "category", "식당", "rating", 4.8));
    destinations.add(Map.of("id", 11, "name", "강릉 '동화가든' 짬뽕순두부", "desc", "불향 가득한 얼큰한 짬뽕 국물에 부드러운 순두부의 조화.", "image", "https://images.unsplash.com/photo-1585032226651-759b368d7246?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("노포", "매운맛", "웨이팅"), "category", "식당", "rating", 4.5));
    destinations.add(Map.of("id", 12, "name", "서울 성수동 '오복수산'", "desc", "신선한 해산물이 듬뿍 올라간 카이센동 명가. 비주얼과 맛 모두 완벽.", "image", "https://images.unsplash.com/photo-1544124499-58912cbddaad?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "tags", Arrays.asList("해산물", "핫플", "일식"), "category", "식당", "rating", 4.7));
%>

<jsp:include page="../layout/header.jsp" />

<style>
    /* 기존 스타일 완벽 유지 */
    .recommend-wrapper {
        min-height: 100vh;
        background: linear-gradient(135deg, #F0F8FF 0%, #FFF0F5 100%);
        font-family: 'Pretendard', sans-serif;
        padding-bottom: 80px;
        padding-top: 140px; 
        display: flex; 
        gap: 50px; 
        max-width: 1600px; 
        margin: 0 auto;
        padding-left: 4%; 
        padding-right: 4%;
    }

    .sidebar-column { width: 250px; flex-shrink: 0; }

    .sidebar {
        position: sticky; top: 140px; margin-top: 165px; 
        background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(16px);
        border: 1px solid rgba(137, 207, 240, 0.4); border-radius: 24px;
        padding: 24px 16px; box-shadow: 0 10px 30px rgba(137, 207, 240, 0.15);
    }

    .category-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px; }

    .btn-category {
        width: 100%; text-align: left; padding: 14px 20px; background: transparent;
        border: none; border-radius: 14px; font-size: 16px; font-weight: 700;
        color: #4A5568; cursor: pointer; transition: all 0.3s ease;
    }

    .btn-category:hover { background: #F0F8FF; color: #2D3748; transform: translateX(4px); }
    .btn-category.active { background: linear-gradient(135deg, #89CFF0, #FFB6C1); color: white; box-shadow: 0 6px 16px rgba(137, 207, 240, 0.35); transform: none; }

    .main-column { flex: 1; min-width: 0; display: flex; flex-direction: column; }
    .hero-section { margin: 0 0 40px 0; padding: 0; width: 100%; }
    .hero-title { font-size: 38px; font-weight: 900; color: #2D3748; margin: 0 0 12px 0; }
    .hero-subtitle { font-size: 17px; color: #4A5568; margin: 0 0 30px 0; }

    .search-container {
        width: 100%; max-width: 650px; margin: 0; display: flex;
        background: rgba(255, 255, 255, 0.9); border: 1px solid rgba(137, 207, 240, 0.5);
        border-radius: 50px; padding: 8px 8px 8px 24px; box-shadow: 0 16px 32px rgba(137, 207, 240, 0.15);
    }

    .search-input { flex: 1; border: none; background: transparent; font-size: 16px; outline: none; color: #2D3748; font-weight: 500; }
    .search-input::placeholder { color: #A0AEC0; }

    .btn-search {
        background: linear-gradient(135deg, #89CFF0, #FFB6C1); color: white; border: none;
        padding: 12px 36px; border-radius: 40px; font-weight: 800; font-size: 15px;
        cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
    }
    .btn-search:hover { transform: translateY(-2px); box-shadow: 0 8px 16px rgba(137, 207, 240, 0.4); }

    .destination-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 32px; width: 100%; }

    .destination-card {
        background: rgba(255, 255, 255, 0.95); border-radius: 20px; overflow: hidden;
        box-shadow: 0 8px 24px rgba(137, 207, 240, 0.15); border: 1px solid rgba(255, 255, 255, 0.8);
        transition: transform 0.3s ease, box-shadow 0.3s ease; display: flex; flex-direction: column;
    }
    .destination-card:hover { transform: translateY(-6px); box-shadow: 0 20px 40px rgba(137, 207, 240, 0.25); }

    .card-image-box { position: relative; height: 230px; overflow: hidden; }
    .card-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease; }
    .destination-card:hover .card-image { transform: scale(1.05); }

    .btn-heart {
        position: absolute; top: 16px; right: 16px; background: rgba(255, 255, 255, 0.4);
        backdrop-filter: blur(8px); border: none; border-radius: 50%; width: 36px; height: 36px;
        display: flex; justify-content: center; align-items: center; cursor: pointer; transition: all 0.3s ease; fill: #FFFFFF;
    }
    .btn-heart:hover { background: rgba(255, 255, 255, 0.9); transform: scale(1.1); fill: #FFB6C1; }
    .btn-heart.liked { fill: #FFB6C1; background: #FFFFFF; box-shadow: 0 4px 12px rgba(255, 182, 193, 0.4); }

    .card-content { padding: 22px; display: flex; flex-direction: column; flex-grow: 1; }
    .tags { display: flex; gap: 6px; margin-bottom: 12px; flex-wrap: wrap; }
    .tag { font-size: 13px; font-weight: 700; color: #89CFF0; background: rgba(137, 207, 240, 0.1); padding: 5px 12px; border-radius: 8px; }
    .title { margin: 0 0 8px 0; font-size: 20px; font-weight: 800; color: #2D3748; line-height: 1.3; }
    .desc { font-size: 14px; color: #718096; line-height: 1.5; margin: 0 0 24px 0; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; flex-grow: 1; }

    .card-footer { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #E2E8F0; padding-top: 16px; mt-auto; }
    .rating { font-size: 15px; font-weight: 800; color: #4A5568; }
    
    /* 상세보기 버튼으로 스타일 텍스트 최적화 */
    .btn-detail {
        background: linear-gradient(135deg, #89CFF0, #FFB6C1); color: white; border: none;
        padding: 8px 20px; border-radius: 10px; font-weight: 800; font-size: 14px; 
        cursor: pointer; transition: opacity 0.3s, transform 0.2s; display: flex; align-items: center; gap: 4px;
    }
    .btn-detail:hover { opacity: 0.9; transform: translateX(2px); }

    .hidden { display: none !important; }

    @media (max-width: 1024px) {
        .recommend-wrapper { flex-direction: column; padding-top: 100px; gap: 24px; }
        .sidebar-column { width: 100%; }
        .sidebar { margin-top: 0; position: static; background: transparent; border: none; box-shadow: none; padding: 0; }
        .category-list { flex-direction: row; overflow-x: auto; padding-bottom: 10px; }
        .btn-category { width: auto; white-space: nowrap; padding: 10px 18px; background: rgba(255, 255, 255, 0.7); border: 1px solid #E2E8F0; }
        .btn-category:hover { transform: translateY(-2px); }
        .hero-title { font-size: 32px; }
    }

    @media (max-width: 768px) {
        .destination-grid { grid-template-columns: 1fr; }
        .hero-title { font-size: 26px; }
        .hero-subtitle { font-size: 15px; }
    }
</style>

<div class="recommend-wrapper">
    
    <div class="sidebar-column">
        <aside class="sidebar">
            <ul class="category-list">
                <li><button class="btn-category active" onclick="filterCategory('전체', this)">전체보기</button></li>
                <li><button class="btn-category" onclick="filterCategory('관광지', this)">📸 관광지</button></li>
                <li><button class="btn-category" onclick="filterCategory('숙소', this)">🛌 숙소</button></li>
                <li><button class="btn-category" onclick="filterCategory('식당', this)">🍽️ 맛집</button></li>
            </ul>
        </aside>
    </div>

    <main class="main-column">
        <section class="hero-section">
            <h1 class="hero-title">어디로 떠나볼까요? ✈️</h1>
            <p class="hero-subtitle">원하는 키워드나 카테고리로 Tripan의 모든 장소를 검색해보세요.</p>
            
            <div class="search-container">
                <input type="text" id="searchInput" class="search-input" placeholder="관심있는 여행지나 #태그를 검색해보세요 (예: 제주, 호캉스)" onkeyup="filterSearch()">
                <button class="btn-search" onclick="filterSearch()">검색</button>
            </div>
        </section>

        <div class="destination-grid" id="cardContainer">
            <% for(Map<String, Object> dest : destinations) { %>
            <article class="destination-card item-card" data-category="<%= dest.get("category") %>" data-title="<%= dest.get("name") %>" data-tags="<%= String.join(" ", (List<String>)dest.get("tags")) %>">
                <div class="card-image-box">
                    <img src="<%= dest.get("image") %>" alt="<%= dest.get("name") %>" class="card-image" />
                    <button class="btn-heart" onclick="this.classList.toggle('liked')">
                        <svg viewBox="0 0 24 24" width="24" height="24">
                            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                        </svg>
                    </button>
                </div>

                <div class="card-content">
                    <div class="tags">
                        <% for(String tag : (List<String>) dest.get("tags")) { %>
                            <span class="tag">#<%= tag %></span>
                        <% } %>
                    </div>
                    <h2 class="title"><%= dest.get("name") %></h2>
                    <p class="desc"><%= dest.get("desc") %></p>
                    
                    <div class="card-footer">
                        <div class="rating">⭐ <%= dest.get("rating") %></div>
                        <button class="btn-detail" onclick="location.href='${pageContext.request.contextPath}/curation/detail'">
                            상세보기 &rarr;
                        </button>
                    </div>
                </div>
            </article>
            <% } %>
        </div>
    </main>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
    let currentCategory = '전체';

    function filterCategory(category, element) {
        currentCategory = category;
        document.querySelectorAll('.btn-category').forEach(btn => btn.classList.remove('active'));
        element.classList.add('active');
        applyFilters();
    }

    function filterSearch() {
        applyFilters();
    }

    function applyFilters() {
        const searchText = document.getElementById('searchInput').value.toLowerCase();
        const cards = document.querySelectorAll('.item-card');

        cards.forEach(card => {
            const cardCategory = card.getAttribute('data-category');
            const cardTitle = card.getAttribute('data-title').toLowerCase();
            const cardTags = card.getAttribute('data-tags').toLowerCase();

            const matchCategory = (currentCategory === '전체' || cardCategory === currentCategory);
            const matchSearch = (cardTitle.includes(searchText) || cardTags.includes(searchText));

            if (matchCategory && matchSearch) {
                card.classList.remove('hidden');
            } else {
                card.classList.add('hidden');
            }
        });
    }
</script>