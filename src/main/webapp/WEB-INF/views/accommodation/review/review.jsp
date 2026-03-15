<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripan - 리뷰 작성</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  
  <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">

  <style>
    :root {
      --sky-blue: #89CFF0; --text-black: #2D3748; --text-dark: #4A5568; --text-gray: #718096;
      --border-light: #E2E8F0; --bg-page: #F0F8FF;
    }
    body { background: var(--bg-page); font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    
    .review-wrapper { max-width: 800px; margin: 120px auto 80px; padding: 0 20px; }
    .page-title { font-size: 24px; font-weight: 800; color: var(--text-black); margin-bottom: 8px; }
    .page-subtitle { font-size: 15px; color: var(--text-gray); margin-bottom: 32px; }

    .review-card {
      background: #fff; border: 1px solid var(--border-light); border-radius: 20px;
      padding: 40px; box-shadow: 0 12px 32px rgba(45,55,72,.04);
    }

    /* 숙소 요약 정보 */
    .place-summary { display: flex; gap: 20px; align-items: center; padding-bottom: 24px; border-bottom: 1px solid var(--border-light); margin-bottom: 32px; }
    .place-img { width: 80px; height: 80px; border-radius: 12px; object-fit: cover; }
    .place-info h3 { margin: 0 0 8px 0; font-size: 18px; font-weight: 800; color: var(--text-black); }
    .place-info p { margin: 0; font-size: 14px; color: var(--text-gray); }

    /* 별점 UI */
    .rating-section { text-align: center; margin-bottom: 32px; }
    .rating-title { font-size: 16px; font-weight: 700; color: var(--text-black); margin-bottom: 12px; }
    .star-wrap { display: flex; justify-content: center; gap: 8px; font-size: 40px; color: var(--border-light); cursor: pointer; }
    .star-wrap i { transition: color 0.2s, transform 0.2s; }
    .star-wrap i:hover { transform: scale(1.1); }
    .star-wrap i.active { color: #F6E05E; /* 별점 노란색 */ }

    /* Quill 에디터 커스텀 */
    .editor-wrap { margin-bottom: 32px; }
    .ql-toolbar.ql-snow { border: 1px solid var(--border-light); border-radius: 12px 12px 0 0; background: #F8FAFC; padding: 12px; }
    .ql-container.ql-snow { border: 1px solid var(--border-light); border-radius: 0 0 12px 12px; height: 300px; font-family: 'Pretendard', sans-serif; font-size: 15px; }
    .ql-editor:focus { border-color: var(--sky-blue); }

    .btn-wrap { display: flex; justify-content: flex-end; gap: 12px; }
    .btn-cancel { padding: 14px 24px; background: white; border: 1px solid var(--border-light); border-radius: 12px; font-size: 15px; font-weight: 700; color: var(--text-dark); cursor: pointer; }
    .btn-submit { padding: 14px 32px; background: var(--text-black); border: none; border-radius: 12px; font-size: 15px; font-weight: 700; color: white; cursor: pointer; transition: background 0.2s; }
    .btn-submit:hover { background: var(--sky-blue); }
  </style>
</head>
<body>

<jsp:include page="${pageContext.request.contextPath}/layout/header.jsp" />

<main class="review-wrapper">
  <div class="page-header">
    <h2 class="page-title">리뷰 작성</h2>
    <p class="page-subtitle">머무르셨던 공간에서의 기억을 공유해주세요.</p>
  </div>

  <div class="review-card">
    <div class="place-summary">
      <img src="${place.imageUrl}" class="place-img" onerror="this.src='https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600'">
      <div class="place-info">
        <h3>${place.placeName}</h3>
        <p>${reservation.checkIn} ~ ${reservation.checkOut} · ${reservation.roomName}</p>
      </div>
    </div>

    <div class="rating-section">
      <div class="rating-title">숙소는 어떠셨나요?</div>
      <div class="star-wrap" id="starRating">
        <i class="bi bi-star-fill" data-val="1"></i>
        <i class="bi bi-star-fill" data-val="2"></i>
        <i class="bi bi-star-fill" data-val="3"></i>
        <i class="bi bi-star-fill" data-val="4"></i>
        <i class="bi bi-star-fill" data-val="5"></i>
      </div>
    </div>

    <div class="editor-wrap">
      <div id="editor"></div>
    </div>

    <div class="btn-wrap">
      <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
      <button type="button" class="btn-submit" onclick="submitReview()">리뷰 등록</button>
    </div>
  </div>
</main>

<jsp:include page="${pageContext.request.contextPath}/layout/footer.jsp" />

<script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
<script>
  let currentRating = 0;
  const reservationId = '${reservation.reservationId}'; // 컨트롤러에서 받아온 예약ID
  const placeId = '${place.placeId}';

  // 1. 별점 로직
  const stars = document.querySelectorAll('#starRating i');
  stars.forEach(star => {
    star.addEventListener('click', function() {
      currentRating = parseInt(this.getAttribute('data-val'));
      stars.forEach(s => {
        if (parseInt(s.getAttribute('data-val')) <= currentRating) {
          s.classList.add('active');
        } else {
          s.classList.remove('active');
        }
      });
    });
  });

  // 2. Quill 에디터 초기화
  const quill = new Quill('#editor', {
    theme: 'snow',
    placeholder: '숙소의 청결도, 위치, 서비스 등에 대한 솔직한 후기를 남겨주세요.',
    modules: {
      toolbar: {
        container: [
          [{ 'header': [1, 2, false] }],
          ['bold', 'italic', 'underline'],
          [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          ['image']
        ],
        handlers: {
          'image': imageHandler
        }
      }
    }
  });

  // 3. 이미지 업로드 핸들러 (작성하신 QuillEditorController 사용)
  function imageHandler() {
    const input = document.createElement('input');
    input.setAttribute('type', 'file');
    input.setAttribute('accept', 'image/*');
    input.click();

    input.onchange = function () {
      const file = input.files[0];
      if (file) {
        const formData = new FormData();
        formData.append('imageFile', file);

        fetch('/editor/upload', {
          method: "POST",
          body: formData,
        })
        .then(res => res.json())
        .then(data => {
          if (data.state === "true" && data.imageUrl) {
            const range = quill.getSelection();
            // 에디터 본문에 이미지 삽입
            quill.insertEmbed(range.index, 'image', data.imageUrl);
          } else {
            alert('이미지 업로드에 실패했습니다.');
          }
        })
        .catch(err => console.error("업로드 에러:", err));
      }
    };
  }

  // 4. 리뷰 등록 및 이미지 추출 로직 🌟
  function submitReview() {
    if (currentRating === 0) {
      alert("별점을 선택해주세요.");
      return;
    }

    const contentHtml = quill.root.innerHTML;
    const contentText = quill.getText().trim();

    if (contentText.length === 0 && !contentHtml.includes('<img')) {
      alert("리뷰 내용을 입력해주세요.");
      return;
    }

    // 🌟 핵심: HTML 본문에서 이미지 URL(src)만 추출하여 배열로 생성
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = contentHtml;
    const imgTags = tempDiv.querySelectorAll('img');
    const imageUrls = Array.from(imgTags).map(img => img.src);

    // 백엔드로 보낼 데이터 준비
    const requestData = {
      reservationId: reservationId,
      placeId: placeId,
      rating: currentRating,
      content: contentHtml,      // 에디터 본문 (통째로 저장)
      images: imageUrls          // 추출된 이미지 URL 배열 (DB의 REVIEW_IMAGE 테이블에 Insert 용도)
    };

    fetch('/review/api/write', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestData)
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        alert("리뷰가 성공적으로 등록되었습니다!");
        location.href = '/mypage/schedule';
      } else {
        alert(data.message || "리뷰 등록 중 오류가 발생했습니다.");
      }
    })
    .catch(err => alert("서버 통신 에러가 발생했습니다."));
  }
</script>
</body>
</html>