<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tripan - 입점 신청 완료</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">

    <style>
        :root {
            /* 3색 몽환 테마 토큰 */
            --tp-ice: #A8C8E1; --tp-orchid: #C2B8D9; --tp-rose: #E0BBC2;
            --tp-grad: linear-gradient(120deg, var(--tp-ice) 0%, var(--tp-orchid) 50%, var(--tp-rose) 100%);
            --tp-bg-page: #FDFDFD;
        }

        body { 
            font-family: 'Pretendard', sans-serif; 
            background-color: var(--tp-bg-page); 
            color: #111;
            margin: 0;
        }

        /* ── 전체 레이아웃 (헤더/푸터 사이 여백) ── */
        .complete-wrapper {
            padding-top: 100px; /* 고정 헤더 간격 */
            padding-bottom: 120px;
            min-height: calc(100vh - 80px); /* 푸터 제외 영역 확보 */
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* ── 완료 카드 스타일 ── */
        .complete-content-card {
            background: #fff;
            padding: 80px 40px;
            border-radius: 40px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.03);
            max-width: 650px;
            width: 100%;
            text-align: center;
            border: 1px solid #f1f3f5;
        }

        /* 아이콘 섹션 */
        .success-icon-box {
            width: 90px; height: 90px;
            background: var(--tp-grad);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 45px;
            margin-bottom: 35px;
            box-shadow: 0 10px 25px rgba(168, 200, 225, 0.4);
        }

        h1 { font-size: 34px; font-weight: 900; margin-bottom: 20px; letter-spacing: -1.5px; }
        h1 span { background: var(--tp-grad); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        
        .complete-msg { font-size: 18px; color: #777; font-weight: 600; line-height: 1.6; margin-bottom: 40px; }

        /* 🌟 타이머 박스 (연회색 배색 적용) */
        .timer-badge {
            font-size: 15px;
            color: #B0B8C1; /* 플레이스홀더 색상 */
            font-weight: 600;
            background: #F8F9FA; /* 배색 적용 */
            padding: 15px 30px;
            border-radius: 100px;
            display: inline-block;
        }
        #sec-timer { font-weight: 900; color: var(--tp-orchid); }

        /* 하단 링크 */
        .quick-link {
            margin-top: 35px;
            display: inline-block;
            color: #999;
            font-weight: 800;
            text-decoration: underline;
            text-underline-offset: 4px;
            font-size: 14px;
        }
        .quick-link:hover { color: #111; transition: 0.3s; }
    </style>
</head>
<body>

    <%-- 1. 소비자 메인 헤더 연결 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="complete-wrapper container">
        <div class="complete-content-card">
            <div class="success-icon-box">✓</div>
            
            <h1>제안서 제출이 <span>성공적으로</span> 완료되었습니다</h1>
            <p class="complete-msg">
                트리판과 함께해주셔서 감사합니다.<br>
                보내주신 소중한 정보는 담당자가 신속히 검토하여<br>
                기재하신 연락처로 안내해 드리겠습니다.
            </p>
            
            <div class="timer-badge">
                <span id="sec-timer">5</span>초 후에 메인 페이지로 자동으로 이동합니다.
            </div>
            
            <br>
            <a href="${pageContext.request.contextPath}/" class="quick-link">기다리지 않고 바로 이동하기</a>
        </div>
    </div>

    <%-- 2. 소비자 메인 푸터 연결 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />

    <script>
        let timeLeft = 5;
        const countSpan = document.getElementById('sec-timer');
        const mainPath = "${pageContext.request.contextPath}/";

        const applyTimer = setInterval(() => {
            timeLeft--;
            countSpan.innerText = timeLeft;

            if (timeLeft <= 0) {
                clearInterval(applyTimer);
                window.location.href = mainPath;
            }
        }, 1000);
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>
</body>
</html>