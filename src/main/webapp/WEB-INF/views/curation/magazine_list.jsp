<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // 실제로는 Controller에서 데이터를 받아옵니다. 
%>

<jsp:include page="../layout/header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;1,700;1,900&family=Pretendard:wght@400;600;800&display=swap" rel="stylesheet">

<style>
    :root {
        --point-blue: #89CFF0;
        --point-pink: #FFB6C1;
        --text-dark: #1A202C;
        --text-light: #718096;
        --white: #FFFFFF;
    }

    .magazine-wrapper {
        background: linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 100%);
        font-family: 'Pretendard', sans-serif;
        padding-top: 180px; /* 헤더 여백 확보 */
        padding-bottom: 120px;
        overflow-x: hidden;
    }

    .container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 40px;
    }

    /* 🖋️ 에디토리얼 헤드라인 */
    .magazine-header {
        text-align: center;
        margin-bottom: 120px;
        position: relative;
    }
    .magazine-header .vol-no {
        font-family: 'Playfair Display', serif;
        font-style: italic;
        font-weight: 700;
        font-size: 20px;
        letter-spacing: 2px;
        margin-bottom: 15px;
        display: block;
    }
    .magazine-header h1 {
        font-family: 'Playfair Display', serif;
        font-size: clamp(40px, 6vw, 72px);
        font-weight: 900;
        letter-spacing: -3px;
        color: var(--text-dark);
        margin: 0;
        line-height: 1;
    }
    .magazine-header p {
        font-size: 18px;
        color: var(--text-light);
        margin-top: 25px;
        font-weight: 500;
    }

    /* 🖼️ [SECTION 1] 히어로 아티클 */
    .hero-container {
        margin-bottom: 180px;
        position: relative;
    }
    .hero-frame {
        width: 80%;
        height: 650px;
        border-radius: 4px;
        overflow: hidden;
        position: relative;
    }
    .hero-frame img {
        width: 100%; height: 100%; object-fit: cover;
        transition: transform 1.5s ease;
    }
    .hero-content-card {
        position: absolute;
        bottom: -60px;
        right: 0;
        width: 45%;
        background: var(--white);
        padding: 60px;
        box-shadow: 30px 30px 80px rgba(137, 207, 240, 0.15);
        z-index: 10;
        border-radius: 2px;
    }
    .hero-content-card .cat {
        font-size: 13px; font-weight: 800; color: var(--point-blue);
        letter-spacing: 3px; margin-bottom: 20px; display: block;
    }
    .hero-content-card h2 {
        font-family: 'Playfair Display', serif;
        font-size: 44px; line-height: 1.2; margin-bottom: 25px;
        color: var(--text-dark); letter-spacing: -1px;
    }
    .hero-content-card p {
        font-size: 16px; color: var(--text-light); line-height: 1.8; margin-bottom: 35px;
    }
    
    .btn-read {
        display: inline-block;
        padding: 18px 40px;
        background: linear-gradient(135deg, var(--point-blue), var(--point-pink));
        color: white;
        font-weight: 800;
        text-decoration: none;
        border-radius: 50px;
        transition: 0.3s cubic-bezier(0.19, 1, 0.22, 1);
        box-shadow: 0 10px 25px rgba(137, 207, 240, 0.3);
    }
    .btn-read:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(137, 207, 240, 0.4); }

    /* 🧩 [SECTION 2] 지그재그 에디토리얼 그리드 */
    .magazine-grid {
        display: grid;
        grid-template-columns: repeat(12, 1fr);
        gap: 100px 30px; /* 수직 간격 100px 최적화 유지 */
    }

    .article-item {
        cursor: pointer;
        position: relative;
    }

    .item-v { grid-column: span 5; }
    .item-h { grid-column: 7 / span 6; margin-top: 60px; } 

    /* [⭐️ 수정 포인트] item-full: 글자를 사진 밑으로 배치하기 위해 flex-direction 변경 */
    .item-full { 
        grid-column: 2 / span 10; 
        display: flex; 
        flex-direction: column; /* 가로 -> 세로 정렬로 변경 */
        gap: 30px; /* 사진과 글자 사이 간격 */
        align-items: flex-start; 
    }

    .article-img-box {
        width: 100%;
        overflow: hidden;
        border-radius: 4px;
        margin-bottom: 20px;
        background: #eee;
    }
    
    .item-v .article-img-box { aspect-ratio: 3 / 4; }
    .item-h .article-img-box { aspect-ratio: 16 / 10; }
    
    /* [⭐️ 수정 포인트] item-full 내부 이미지 비율 및 너비 조정 */
    .item-full .article-img-box { width: 100%; aspect-ratio: 16 / 8; margin-bottom: 0; }
    .item-full .article-text-box { width: 100%; }

    .article-img-box img {
        width: 100%; height: 100%; object-fit: cover;
        transition: transform 1s;
    }
    .article-item:hover .article-img-box img { transform: scale(1.05); }

    .article-item .tag {
        font-size: 12px; font-weight: 800; color: var(--point-pink);
        letter-spacing: 2px; margin-bottom: 12px; display: block;
    }
    .article-item h3 {
        font-family: 'Playfair Display', serif;
        font-size: 30px; color: var(--text-dark); margin-bottom: 15px;
        line-height: 1.3;
    }
    .article-item p {
        font-size: 15px; color: var(--text-light); line-height: 1.7;
    }
    
    .instar3-text-gradient {
    background: linear-gradient(120deg, #A8C8E1 0%, #C2B8D9 50%, #E0BBC2 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: inline-block; 
}

    @media (max-width: 1024px) {
        .hero-frame { width: 100%; height: 450px; }
        .hero-content-card { position: static; width: 100%; padding: 40px 20px; box-shadow: none; border-bottom: 1px solid #eee; }
        .magazine-grid { display: flex; flex-direction: column; gap: 80px; }
        .item-full { padding: 0; }
    }
</style>

<div class="magazine-wrapper">
    <div class="container">
        
        <header class="magazine-header">
            <span class="vol-no instar3-text-gradient" >DIGITAL ARCHIVE VOL. 12</span>
            <h1>Tripan <span class="instar3-text-gradient">Curation</span></h1>
            <p>당신의 취향을 기록하고, 새로운 여정을 제안합니다.</p>
        </header>

        <section class="hero-container" onclick="location.href='${pageContext.request.contextPath}/magazine/detail'">
            <div class="hero-frame">
                <img src="https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=1600" alt="Jeju">
            </div>
            <div class="hero-content-card">
                <span class="cat">EDITOR'S CHOICE</span>
                <h2>제주, 온전한 쉼을 위한<br>비밀스러운 공간들</h2>
                <p>파도 소리만 들리는 프라이빗한 숙소부터 숨겨진 로컬 맛집까지, 당신의 지친 일상을 위로할 완벽한 가이드. Tripan이 선별한 제주의 진짜 모습을 만나보세요.</p>
                <a href="${pageContext.request.contextPath}/magazine/detail" class="btn-read">STORY VIEW</a>
            </div>
        </section>

        <div class="magazine-grid">
            
            <article class="article-item item-v" onclick="location.href='#'">
                <div class="article-img-box">
                    <img src="https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800" alt="Busan">
                </div>
                <span class="tag">TASTE</span>
                <h3>부산 해운대, 미식가들의<br>성지를 찾아서</h3>
                <p>입에서 녹는 최상급 한우 암소 갈비부터, 바다 내음 가득한 해산물까지. 부산의 밤을 미식으로 가득 채워보세요.</p>
            </article>

            <article class="article-item item-h" onclick="location.href='#'">
                <div class="article-img-box">
                    <img src="https://images.unsplash.com/photo-1551641506-ee5bf4cb45f1?auto=format&fit=crop&w=1000" alt="Udo">
                </div>
                <span class="tag">JOURNEY</span>
                <h3>푸른 바람을 가르며,<br>우도 자전거 여행</h3>
                <p>에메랄드빛 바다를 옆에 두고 달리는 상쾌함. 땅콩 아이스크림은 덤으로 즐겨보세요.</p>
            </article>

            <article class="article-item item-full" onclick="location.href='#'">
                <div class="article-img-box">
                    <img src="https://images.unsplash.com/photo-1578637387939-43c525550085?auto=format&fit=crop&w=1200" alt="Gyeongju">
                </div>
                <div class="article-text-box">
                    <span class="tag">SPECIAL REPORT</span>
                    <h3>경주, 고즈넉한 한옥에서의 하룻밤</h3>
                    <p>바스락거리는 이불, 따뜻한 온돌. 황리단길의 야경과 함께하는 완벽한 레트로 힐링. 시간이 멈춘 듯한 경주의 숨은 스테이를 공개합니다.</p>
                    <a href="#" style="color:var(--text-dark); font-weight:800; border-bottom: 2px solid var(--point-blue); text-decoration: none; padding-bottom: 4px; margin-top: 15px; display: inline-block;">전체보기 →</a>
                </div>
            </article>

            <article class="article-item item-v" onclick="location.href='#'">
                <div class="article-img-box">
                    <img src="https://images.unsplash.com/photo-1534351590666-13e3e96b5017?auto=format&fit=crop&w=800" alt="Yacht">
                </div>
                <span class="tag">LIFESTYLE</span>
                <h3>광안대교 야경을 전세 낸<br>프라이빗 요트 파티</h3>
                <p>사랑하는 사람과 함께 즐기는 요트 투어. 잊지 못할 부산의 밤을 계획해 보세요.</p>
            </article>
            
            <article class="article-item item-h" onclick="location.href='#'">
		        <div class="article-img-box">
		            <img src="https://images.unsplash.com/photo-1544124499-58912cbddaad?auto=format&fit=crop&w=800" alt="Seongsu">
		        </div>
		        <span class="tag">TASTE</span>
		        <h3>성수동, 바다를 담은<br>가장 신선한 한 그릇</h3>
		        <p>붉은 벽돌 사이에서 만나는 카이센동 명가. 입안 가득 퍼지는 바다의 풍미를 느껴보세요.</p>
		    </article>
		
        </div>

    </div>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const heroImg = document.querySelector('.hero-frame img');
        if(heroImg) {
            heroImg.style.transform = 'translateY(' + (scrolled * 0.05) + 'px) scale(1.1)';
        }
    });
</script>