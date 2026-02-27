<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Map<String, Object> place = new HashMap<>();
    place.put("id", 5);
    place.put("name", "제주 파르나스 호텔");
    place.put("desc", "제주 중문 바다를 품은 럭셔리 호캉스. 국내 최장 110m 인피니티 풀에서 황홀한 선셋과 함께 인생샷을 남겨보세요. 전 객실에서 제주 바다의 파도 소리를 들을 수 있습니다.");
    
    // 이미지 슬라이더 데이터
    List<String> images = Arrays.asList(
        "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
        "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
        "https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
        "https://images.unsplash.com/photo-1551882547-ff40c0d12c5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80"
    );
    place.put("images", images);
    
    place.put("tags", Arrays.asList("호캉스", "오션뷰", "인피니티풀"));
    place.put("category", "숙소"); 
    place.put("rating", 4.9);
    place.put("reviewCount", 128);
    
    // 📍 [핵심 추가] 캡처본 반영을 위한 상세 위치 및 연락처 데이터
    place.put("address", "제주특별자치도 서귀포시 중문관광로72번길 100");
    place.put("parkingInfo", "건물 외부에 전용 주차장(무료)이 마련되어 있습니다.");
    place.put("phone", "010-4099-3948");
    place.put("email", "cksud2@naver.com");
    place.put("instagram", "@___nightletter");
    place.put("naver", "cksud2");

    // 객실 리스트
    List<Map<String, Object>> rooms = new ArrayList<>();
    rooms.add(Map.of("id", 101, "name", "디럭스 오션뷰", "price", 350000, "capacity", 2, "image", "https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"));
    rooms.add(Map.of("id", 102, "name", "프리미어 스위트", "price", 650000, "capacity", 4, "image", "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"));
%>

<jsp:include page="../layout/header.jsp" />

<style>
    /* 전체 배경 */
    .detail-wrapper {
        min-height: 100vh; background: linear-gradient(135deg, #F0F8FF 0%, #FFF0F5 100%);
        font-family: 'Pretendard', sans-serif; padding-bottom: 100px; padding-top: 140px; 
    }
    .content-container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }

    /* 🖼️ 이미지 슬라이더 */
    .carousel-container {
        position: relative; width: 100%; height: 500px; border-radius: 20px;
        overflow: hidden; margin-bottom: 40px; box-shadow: 0 16px 32px rgba(137, 207, 240, 0.15);
    }
    .carousel-track { display: flex; height: 100%; transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
    .carousel-slide { min-width: 100%; height: 100%; }
    .carousel-slide img { width: 100%; height: 100%; object-fit: cover; }
    .carousel-btn {
        position: absolute; top: 50%; transform: translateY(-50%); background: rgba(255, 255, 255, 0.5);
        backdrop-filter: blur(8px); color: #2D3748; border: none; width: 48px; height: 48px;
        border-radius: 50%; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center; z-index: 10;
    }
    .carousel-btn:hover { background: rgba(255, 255, 255, 0.9); }
    .carousel-btn.prev { left: 24px; } .carousel-btn.next { right: 24px; }
    .carousel-indicator {
        position: absolute; bottom: 24px; right: 24px; background: rgba(0, 0, 0, 0.6);
        backdrop-filter: blur(4px); color: white; padding: 8px 16px; border-radius: 30px; font-size: 14px; z-index: 10;
    }

    /* 🌟 하단 레이아웃 분할 */
    .detail-split { display: flex; gap: 40px; }

    /* 📌 좌측 정보 영역 */
    .main-info {
        flex: 1; min-width: 0; background: rgba(255, 255, 255, 0.95);
        border-radius: 24px; padding: 40px; box-shadow: 0 16px 32px rgba(137, 207, 240, 0.1); border: 1px solid rgba(255, 255, 255, 0.8);
    }

    .header-tags { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
    .tag { font-size: 14px; font-weight: 700; color: #89CFF0; background: rgba(137, 207, 240, 0.15); padding: 6px 14px; border-radius: 8px; }
    
    .place-title { font-size: 34px; font-weight: 900; color: #2D3748; margin-bottom: 12px; line-height: 1.2; }
    .place-address { font-size: 16px; color: #718096; display: flex; align-items: center; gap: 6px; margin-bottom: 24px; }
    
    .divider { height: 1px; background: #E2E8F0; margin: 40px 0; }
    .section-title { font-size: 22px; font-weight: 800; color: #2D3748; margin-bottom: 20px; }
    .place-desc { font-size: 16px; color: #4A5568; line-height: 1.7; }

    /* ==========================================================
       🛁 [신규] 편의시설 영역 (캡처본 스타일 적용)
       ========================================================== */
    .amenity-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 24px;
        margin-bottom: 16px;
    }
    .amenity-item {
        display: flex; align-items: center; gap: 10px;
        font-size: 17px; font-weight: 600; color: #2D3748;
    }
    .amenity-icon {
        width: 28px; height: 28px; fill: none; stroke: #4A5568; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
    }
    .amenity-note {
        font-size: 14px; color: #A0AEC0; margin-top: 10px;
    }

    /* ==========================================================
       📍 [신규] 스테이 위치 및 주변 정보 영역 (캡처본 스타일 적용)
       ========================================================== */
    .location-info-text {
        font-size: 16px; color: #4A5568; line-height: 1.7; margin-bottom: 24px;
    }
    .contact-list {
        list-style: none; padding: 0; margin: 0;
        display: flex; flex-direction: column; gap: 12px;
    }
    .contact-item {
        display: flex; align-items: center; gap: 10px;
        font-size: 16px; color: #4A5568; font-weight: 500;
    }
    .contact-icon {
        width: 20px; height: 20px; fill: none; stroke: #718096; stroke-width: 1.5;
        display: flex; justify-content: center; align-items: center;
    }

    /* 🛏️ 객실 리스트 */
    .room-card { display: flex; border: 1px solid #E2E8F0; border-radius: 16px; overflow: hidden; margin-bottom: 20px; transition: transform 0.2s; }
    .room-img { width: 240px; height: 180px; object-fit: cover; }
    .room-info { padding: 24px; flex: 1; display: flex; flex-direction: column; justify-content: center; }
    .room-name { font-size: 20px; font-weight: 800; color: #2D3748; margin-bottom: 8px; }
    .room-capa { font-size: 14px; color: #718096; margin-bottom: auto; }
    .room-price-box { display: flex; justify-content: space-between; align-items: flex-end; }
    .room-price { font-size: 24px; font-weight: 900; color: #2D3748; }

    /* 📌 우측 사이드바 (Action Panel) */
    .action-panel {
        width: 380px; flex-shrink: 0; position: sticky; top: 140px; height: fit-content;
        background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(16px);
        border-radius: 24px; padding: 32px; box-shadow: 0 20px 40px rgba(137, 207, 240, 0.15); border: 1px solid rgba(255, 255, 255, 0.8);
    }
    .panel-rating { display: flex; align-items: center; gap: 8px; font-size: 18px; font-weight: 800; color: #2D3748; margin-bottom: 24px; }
    .panel-rating span { color: #718096; font-size: 14px; font-weight: 500; text-decoration: underline; cursor: pointer; }

    .date-picker { border: 1px solid #E2E8F0; border-radius: 12px; padding: 16px; margin-bottom: 24px; }
    .date-picker p { font-size: 13px; color: #718096; font-weight: 700; margin-bottom: 4px; }
    .date-picker div { font-size: 16px; font-weight: 800; color: #2D3748; }

    .btn-primary {
        width: 100%; background: linear-gradient(135deg, #89CFF0, #FFB6C1); color: white; border: none;
        padding: 18px; border-radius: 16px; font-weight: 900; font-size: 18px; cursor: pointer; transition: opacity 0.2s, transform 0.2s; margin-bottom: 12px;
    }
    .btn-primary:hover { opacity: 0.9; transform: translateY(-2px); }

    .btn-secondary {
        width: 100%; background: transparent; color: #4A5568; border: 2px solid #E2E8F0;
        padding: 16px; border-radius: 16px; font-weight: 800; font-size: 16px; cursor: pointer; transition: all 0.2s;
    }
    .btn-secondary:hover { background: #F7FAFC; border-color: #CBD5E0; }

    @media (max-width: 1024px) {
        .detail-split { flex-direction: column; }
        .action-panel { width: 100%; position: static; }
        .room-card { flex-direction: column; }
        .room-img { width: 100%; height: 200px; }
    }
</style>

<div class="detail-wrapper">
    <div class="content-container">
        
        <div class="carousel-container">
            <div class="carousel-track" id="carouselTrack">
                <% 
                   List<String> imageUrls = (List<String>) place.get("images");
                   for(String imgUrl : imageUrls) { 
                %>
                    <div class="carousel-slide"><img src="<%= imgUrl %>" alt="<%= place.get("name") %>"></div>
                <% } %>
            </div>
            <button class="carousel-btn prev" onclick="moveSlide(-1)">&#10094;</button>
            <button class="carousel-btn next" onclick="moveSlide(1)">&#10095;</button>
            <div class="carousel-indicator" id="carouselIndicator">1 / <%= imageUrls.size() %> | 더 보기</div>
        </div>

        <div class="detail-split">
            <div class="main-info">
                <div class="header-tags">
                    <span class="tag" style="background: #2D3748; color: white;"><%= place.get("category") %></span>
                    <% for(String tag : (List<String>) place.get("tags")) { %>
                        <span class="tag">#<%= tag %></span>
                    <% } %>
                </div>
                
                <h1 class="place-title"><%= place.get("name") %></h1>

                <div class="divider"></div>

                <h2 class="section-title">어떤 곳인가요?</h2>
                <p class="place-desc"><%= place.get("desc") %></p>

                <div class="divider"></div>

                <%-- 🛁 [캡처본 반영] 편의시설 영역 --%>
                <% if ("숙소".equals(place.get("category"))) { %>
                    <h2 class="section-title">편의시설</h2>
                    <div class="amenity-grid">
                        <div class="amenity-item">
                            <svg class="amenity-icon" viewBox="0 0 24 24"><path d="M4 10v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-9M2 10h20M7 10V6a2 2 0 0 1 2-2h6M16 21v2M8 21v2M13 6v4"/></svg>
                            반신욕
                        </div>
                        <div class="amenity-item">
                            <svg class="amenity-icon" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>
                            빔프로젝터 또는 TV
                        </div>
                        <div class="amenity-item">
                            <svg class="amenity-icon" viewBox="0 0 24 24"><path d="M5 10h14a1 1 0 0 1 1 1v4a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5v-4a1 1 0 0 1 1-1zM2 10h20M12 3v7M9 5v5M15 5v5"/></svg>
                            취사
                        </div>
                    </div>
                    <p class="amenity-note">* 객실별 제공 여부 상세 페이지 참고</p>

                    <div class="divider"></div>
                <% } %>

                <%-- 📍 [캡처본 반영] 스테이 위치 및 주변 정보 영역 --%>
                <h2 class="section-title">스테이 위치 및 주변 정보</h2>
                <p class="location-info-text">
                    <%= place.get("name") %>의 위치는 [ <%= place.get("address") %> ] 입니다.<br>
                    <%= place.get("parkingInfo") %>
                </p>

                <ul class="contact-list">
                    <li class="contact-item">
                        <svg class="contact-icon" viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        <%= place.get("phone") %>
                    </li>
                    <li class="contact-item">
                        <svg class="contact-icon" viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <%= place.get("email") %>
                    </li>
                    <li class="contact-item">
                        <svg class="contact-icon" viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
                        <%= place.get("instagram") %>
                    </li>
                    <li class="contact-item">
                        <span class="contact-icon" style="font-weight: 900; font-size: 18px; color: #4A5568; stroke: none; fill: currentColor;">N</span>
                        <%= place.get("naver") %>
                    </li>
                </ul>

                <div class="divider"></div>

                <% if ("숙소".equals(place.get("category"))) { %>
                    <h2 class="section-title">객실 선택</h2>
                    <% for(Map<String, Object> room : rooms) { %>
                    <div class="room-card">
                        <img src="<%= room.get("image") %>" class="room-img" alt="객실 사진">
                        <div class="room-info">
                            <div class="room-name"><%= room.get("name") %></div>
                            <div class="room-capa">기준 <%= room.get("capacity") %>인 (최대 <%= (int)room.get("capacity") + 1 %>인)</div>
                            <div class="room-price-box">
                                <div class="room-price">₩<%= String.format("%,d", room.get("price")) %> <span style="font-size: 14px; font-weight: 500; color: #718096;">/ 1박</span></div>
                                <button style="padding: 10px 20px; background: #2D3748; color: white; border-radius: 8px; font-weight: 700; border: none; cursor: pointer;">선택</button>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <div class="divider"></div>
                <% } %>
                
                <h2 class="section-title">지도 및 길찾기</h2>
                <div style="width: 100%; height: 300px; background: #E2E8F0; border-radius: 16px; display: flex; justify-content: center; align-items: center; color: #A0AEC0; font-weight: 700;">
                    (여기에 카카오 맵 API가 렌더링 됩니다)
                </div>

            </div>

            <div class="action-panel">
                <div class="panel-rating">⭐ <%= place.get("rating") %> <span>(리뷰 <%= place.get("reviewCount") %>개)</span></div>

                <% if ("숙소".equals(place.get("category"))) { %>
                    <div class="date-picker">
                        <p>체크인 - 체크아웃</p>
                        <div>2026.03.15 (금) - 2026.03.16 (토)</div>
                    </div>
                    <button class="btn-primary" onclick="alert('PG사 결제창으로 이동합니다.')">객실 예약하기</button>
                    <button class="btn-secondary" onclick="alert('내 여행 일정(보드)에 핀을 꽂았습니다!')">🗺️ 내 여행 일정에 담기</button>
                <% } else { %>
                    <p style="color: #718096; font-size: 15px; margin-bottom: 24px; line-height: 1.5;">
                        이곳은 예약 상품이 아닙니다.<br>나만의 여행 일정표에 담아 방문 일정을 계획해보세요!
                    </p>
                    <button class="btn-primary" onclick="alert('내 여행 일정(보드)에 핀을 꽂았습니다!')">🗺️ 내 여행 일정에 담기</button>
                <% } %>
                
                <button style="width: 100%; background: transparent; border: none; color: #A0AEC0; font-weight: 700; margin-top: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                    찜하기 목록에 저장
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
    let currentSlide = 0;
    const totalSlides = <%= imageUrls.size() %>;
    const track = document.getElementById('carouselTrack');
    const indicator = document.getElementById('carouselIndicator');

    function moveSlide(direction) {
        currentSlide += direction;
        if (currentSlide < 0) currentSlide = totalSlides - 1;
        else if (currentSlide >= totalSlides) currentSlide = 0;
        
        track.style.transform = `translateX(-${currentSlide * 100}%)`;
        indicator.innerHTML = `${currentSlide + 1} / ${totalSlides} | 더 보기`;
    }
</script>