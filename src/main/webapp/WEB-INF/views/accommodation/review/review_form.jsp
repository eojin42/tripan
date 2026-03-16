<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Tripan - 리뷰 작성</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/quill-resize-module@2.0.4/dist/resize.css" rel="stylesheet">
    
    <style>
        /* ... 기존 스타일 유지 ... */
        .review-container { 
            max-width: 800px; margin: 120px auto 80px; padding: 40px; 
            background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.8); border-radius: 24px; box-shadow: 0 12px 32px rgba(45, 55, 72, 0.04);
        }
        
        .review-title { font-size: 24px; font-weight: 900; margin-bottom: 8px; color: #2D3748; }
        .review-subtitle { font-size: 15px; color: #718096; margin-bottom: 30px; }

        /* ✨ 새롭게 추가된 예약 정보 카드 스타일 */
        .booking-summary-card {
            display: flex;
            align-items: center;
            gap: 20px;
            background: white;
            padding: 16px;
            border-radius: 16px;
            border: 1px solid #E2E8F0;
            margin-bottom: 32px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
        }
        .booking-img {
            width: 100px;
            height: 100px;
            border-radius: 12px;
            overflow: hidden;
            flex-shrink: 0;
        }
        .booking-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .booking-info { flex: 1; }
        .booking-place { font-size: 18px; font-weight: 800; color: #2D3748; margin-bottom: 4px; }
        .booking-room { font-size: 14px; font-weight: 600; color: #4A5568; margin-bottom: 8px; }
        .booking-date { 
            display: inline-block;
            font-size: 12px; 
            font-weight: 700; 
            color: #89CFF0; 
            background: rgba(137, 207, 240, 0.1);
            padding: 4px 10px;
            border-radius: 8px;
        }
        
        .form-group { margin-bottom: 24px; }
        .form-label { font-weight: 800; display: block; margin-bottom: 12px; color: var(--text-dark, #4A5568); }
        
        /* 별점 UI 스타일 */
        .star-rating { 
            display: flex; 
            flex-direction: row-reverse; 
            justify-content: flex-end; 
            font-size: 2.5rem; 
            gap: 4px;
        }
        .star-rating input { display: none; }
        .star-rating label { color: #E2E8F0; cursor: pointer; transition: color 0.2s, transform 0.2s; }
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label { color: #FFD700; } /* 선택된 별 노란색 */
        .star-rating label:hover { transform: scale(1.1); }

        /* Quill 에디터 스타일 조정 */
        #editor { height: 350px; border-radius: 0 0 12px 12px; background: white; }
        .ql-toolbar.ql-snow { border-radius: 12px 12px 0 0; background: #F8FAFC; border-color: #E2E8F0; }
        .ql-container.ql-snow { border-color: #E2E8F0; }

        .btn-submit { 
            background: linear-gradient(135deg, #89CFF0, #FFB6C1); 
            color: white; 
            border: none; 
            padding: 16px 24px; 
            border-radius: 16px; 
            font-size: 16px;
            font-weight: 800; 
            cursor: pointer; 
            width: 100%; 
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            font-family: inherit;
        }
        .btn-submit:hover { 
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(137, 207, 240, 0.4); 
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="review-container">
    <h2 class="review-title">숙소 리뷰 작성</h2>
    <p class="review-subtitle">이용하신 숙소는 어떠셨나요? 소중한 경험을 나누어주세요.</p>
    
    <div class="booking-summary-card">
        <div class="booking-img">
            <img src="${room.roomImageUrl != null ? room.roomImageUrl : '/dist/images/default_room.jpg'}" alt="객실 이미지">
        </div>
        <div class="booking-info">
            <div class="booking-place">${not empty room.placeName ? room.placeName : '파스텔 오션뷰 호텔'}</div>
            <div class="booking-room">${not empty room.roomName ? room.roomName : '디럭스 더블룸'}</div>
            <div class="booking-date">
                <i class="bi bi-calendar-check"></i> 
                ${not empty reservationInfo.checkin ? reservationInfo.checkin : '2026.03.10'} ~ 
                ${not empty reservationInfo.checkout ? reservationInfo.checkout : '2026.03.12'} 
                (${nights}박)
            </div>
        </div>
    </div>

    <form id="reviewForm" action="/accommodation/review/submit" method="post">
        <input type="hidden" name="bookingId" value="${reservationInfo.reservationId}">
        
        <input type="hidden" name="content" id="hiddenContent">

        <div class="form-group">
            <label class="form-label">별점</label>
            <div class="star-rating">
                <input type="radio" id="star5" name="rating" value="5"><label for="star5" class="bi bi-star-fill"></label>
                <input type="radio" id="star4" name="rating" value="4"><label for="star4" class="bi bi-star-fill"></label>
                <input type="radio" id="star3" name="rating" value="3" checked><label for="star3" class="bi bi-star-fill"></label>
                <input type="radio" id="star2" name="rating" value="2"><label for="star2" class="bi bi-star-fill"></label>
                <input type="radio" id="star1" name="rating" value="1"><label for="star1" class="bi bi-star-fill"></label>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">리뷰 내용</label>
            <div id="editor"></div>
        </div>

        <button type="submit" class="btn-submit">리뷰 등록하기</button>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="https://cdn.jsdelivr.net/npm/quill-resize-module@2.0.4/dist/resize.js"></script>
<script src="${pageContext.request.contextPath}/dist/posts/qeditor.js"></script>

<script>
    document.getElementById('reviewForm').addEventListener('submit', function(e) {
        // 1. 폼 기본 제출 동작 막기
        e.preventDefault();

        // 2. Quill 에디터의 HTML 콘텐츠 가져오기
        var htmlContent = document.querySelector('.ql-editor').innerHTML;

        // 내용이 비어있는지 검증 (필요시)
        if (quill.getText().trim().length === 0 && !htmlContent.includes('<img')) {
            alert("리뷰 내용을 입력해주세요.");
            return;
        }

        // 3. hidden input에 에디터 내용 세팅
        document.getElementById('hiddenContent').value = htmlContent;

        // 4. 에디터 본문에서 <img> 태그의 src 추출하기
        var tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlContent;
        var images = tempDiv.getElementsByTagName('img');

        // 추출한 이미지 URL을 hidden input으로 폼에 추가
        for (var i = 0; i < images.length; i++) {
            var src = images[i].src;
            var hiddenImgInput = document.createElement('input');
            hiddenImgInput.type = 'hidden';
            hiddenImgInput.name = 'imageUrls';
            hiddenImgInput.value = src;
            this.appendChild(hiddenImgInput);
        }

        // 5. 폼 최종 제출
        this.submit();
    });
</script>

</body>
</html>