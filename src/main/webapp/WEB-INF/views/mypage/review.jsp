<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 나의 리뷰 기록</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root {
      --sky-blue:#89CFF0;--sky-blue-light:#E6F4FF;--light-pink:#FFB6C1;
      --grad-main:linear-gradient(135deg,var(--sky-blue),var(--light-pink));
      --bg-page:#F0F8FF;--glass-bg:rgba(255,255,255,0.65);--glass-border:rgba(255,255,255,0.8);
      --text-black:#2D3748;--text-dark:#4A5568;--text-gray:#718096;
      --border-light:#E2E8F0;--radius-xl:24px;--bounce:cubic-bezier(0.34,1.56,0.64,1);
    }
    body { background:var(--bg-page);font-family:'Pretendard',sans-serif;margin:0;padding:0;background-image:radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0px,transparent 50%),radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0px,transparent 50%);background-attachment:fixed; }
    .mypage-container { max-width:1400px;width:90%;margin:120px auto 80px;display:grid;grid-template-columns:280px 1fr;gap:40px;align-items:start; }
    .glass-card { background:var(--glass-bg);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:24px;box-shadow:0 12px 32px rgba(45,55,72,.04); }
    .sidebar { position:sticky;top:120px;display:flex;flex-direction:column;gap:20px; }
    .profile-avatar { width:88px;height:88px;border-radius:50%;border:4px solid white;box-shadow:0 8px 16px rgba(137,207,240,.3);margin:0 auto 14px;overflow:hidden;background:white; }
    .profile-avatar img { width:100%;height:100%;object-fit:cover; }
    .profile-avatar-default { width:100%;height:100%;background:var(--grad-main);display:flex;align-items:center;justify-content:center;color:white;font-size:28px;font-weight:900; }
    .profile-name { font-size:20px;font-weight:900;margin-bottom:4px;text-align:center; }
    .profile-bio  { font-size:13px;color:var(--text-gray);margin-bottom:16px;line-height:1.4;text-align:center; }
    .btn-edit-profile { background:white;color:var(--text-dark);border:1px solid var(--border-light);padding:8px 16px;border-radius:20px;font-size:13px;font-weight:700;cursor:pointer;transition:all .2s;width:100%;font-family:inherit; }
    .btn-edit-profile:hover { background:var(--text-black);color:white;border-color:transparent; }
    .profile-stats { display:flex;justify-content:space-around;margin-top:20px;padding-top:20px;border-top:1px dashed rgba(45,55,72,.1); }
    .stat-box { display:flex;flex-direction:column;align-items:center;font-size:12px;color:var(--text-gray);font-weight:600;padding:4px 8px;border-radius:8px;transition:.2s;gap:2px; }
    .stat-box:hover { background:rgba(137,207,240,.15);color:var(--sky-blue);cursor:pointer;transform:translateY(-2px); }
    .stat-box strong { font-size:18px;color:var(--text-black);font-weight:900; }
    .side-nav { list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:6px; }
    .side-nav li { border-radius:16px;overflow:hidden; }
    .side-nav a { display:flex;align-items:center;gap:12px;padding:13px 20px;color:var(--text-dark);font-weight:700;font-size:14px;text-decoration:none;transition:all .3s; }
    .side-nav a i { font-size:16px;width:20px;text-align:center;flex-shrink:0; }
    .side-nav a:hover { background:rgba(255,255,255,.8);color:var(--sky-blue);padding-left:24px; }
    .side-nav li.active a { background:var(--grad-main);color:white;box-shadow:0 4px 12px rgba(137,207,240,.4); }
    .side-nav li.active a i { color:white; }
    .content-area { display:flex;flex-direction:column;gap:24px;padding-top:20px; }
    .page-title { font-size:24px;font-weight:800;margin:0 0 4px; }
    .page-subtitle { font-size:14px;color:var(--text-gray);font-weight:500;margin:0 0 24px; }

    /* 섹션 제목 */
    .section-label { font-size:13px;font-weight:800;color:var(--text-gray);letter-spacing:.05em;text-transform:uppercase;margin:0 0 12px;display:flex;align-items:center;gap:8px; }
    .section-label::after { content:'';flex:1;height:1px;background:var(--border-light); }

    /* 미작성 리뷰 배너 */
    .pending-list { display:flex;flex-direction:column;gap:10px;margin-bottom:8px; }
    .pending-card {
      background:linear-gradient(135deg,rgba(255,182,193,.08),rgba(137,207,240,.08));
      border:1.5px dashed rgba(137,207,240,.5);
      border-radius:16px;padding:16px 20px;
      display:flex;align-items:center;justify-content:space-between;gap:12px;
      transition:.2s;
    }
    .pending-card:hover { border-color:var(--sky-blue);background:rgba(137,207,240,.06); }
    .pending-info { display:flex;align-items:center;gap:12px; }
    .pending-icon { width:40px;height:40px;border-radius:12px;background:var(--grad-main);display:flex;align-items:center;justify-content:center;color:white;font-size:16px;flex-shrink:0; }
    .pending-name { font-size:14px;font-weight:800;color:var(--text-black);margin-bottom:2px; }
    .pending-date { font-size:11px;color:var(--text-gray);font-weight:600; }
    .btn-write-review { background:var(--grad-main);color:white;border:none;padding:8px 16px;border-radius:12px;font-size:12px;font-weight:800;cursor:pointer;font-family:inherit;transition:.2s;white-space:nowrap; }
    .btn-write-review:hover { opacity:.85;transform:translateY(-1px); }

    /* 리뷰 카드 */
    .review-list { display:flex;flex-direction:column;gap:16px; }
    .review-card {
      background:white;border-radius:20px;padding:22px 24px;
      border:1px solid var(--border-light);box-shadow:0 4px 16px rgba(0,0,0,.02);
      transition:all .3s;position:relative;
    }
    .review-card:hover { box-shadow:0 8px 24px rgba(137,207,240,.1);border-color:rgba(137,207,240,.3); }
    .review-header { display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:12px;gap:12px; }
    .review-place { font-size:15px;font-weight:800;color:var(--text-black);display:flex;align-items:center;gap:6px; }
    .review-place i { color:var(--sky-blue);font-size:14px; }
    .review-stars { display:flex;gap:2px;margin-bottom:6px; }
    .review-stars i { font-size:13px;color:#FFB800; }
    .review-stars i.empty { color:#E2E8F0; }
    .review-date { font-size:11px;color:var(--text-gray);font-weight:600;flex-shrink:0; }
    .review-content { font-size:14px;color:var(--text-dark);line-height:1.7;margin-bottom:12px;word-break:break-word; }
    .review-images { display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px; }
    .review-img { width:72px;height:72px;border-radius:12px;object-fit:cover;border:1px solid var(--border-light);cursor:pointer;transition:.2s; }
    .review-img:hover { transform:scale(1.05); }
    .review-footer { display:flex;align-items:center;justify-content:space-between; }
    .review-type-tag { font-size:10px;font-weight:800;padding:3px 10px;border-radius:20px;background:var(--sky-blue-light);color:var(--sky-blue); }
    .review-actions { display:flex;gap:8px; }
    .btn-edit-review {
      background:none;border:1px solid var(--border-light);color:var(--text-gray);
      padding:5px 12px;border-radius:10px;font-size:11px;font-weight:800;
      cursor:pointer;font-family:inherit;transition:.2s;
    }
    .btn-edit-review:hover { background:var(--sky-blue-light);color:var(--sky-blue);border-color:var(--sky-blue); }
    .btn-delete-review {
      background:none;border:1px solid #FFE0E0;color:#FF6B6B;
      padding:5px 12px;border-radius:10px;font-size:11px;font-weight:800;
      cursor:pointer;font-family:inherit;transition:.2s;
    }
    .btn-delete-review:hover { background:#FF6B6B;color:white;border-color:#FF6B6B; }

    .empty-state { text-align:center;padding:60px 20px;color:var(--text-gray); }
    .empty-state i { font-size:48px;display:block;margin-bottom:16px;opacity:.2;color:var(--sky-blue); }
    .empty-state p { font-size:14px;font-weight:600;margin:0; }
    .spin { width:28px;height:28px;border:3px solid rgba(137,207,240,.2);border-top-color:var(--sky-blue);border-radius:50%;animation:sp .7s linear infinite;margin:30px auto;display:block; }
    @keyframes sp { to { transform:rotate(360deg); } }

    /* 모달 공통 */
    .modal-overlay { position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.4);backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;z-index:9999;opacity:0;visibility:hidden;transition:.3s; }
    .modal-overlay.active { opacity:1;visibility:visible; }
    .confirm-modal { background:white;width:90%;max-width:360px;border-radius:24px;padding:28px;box-shadow:0 20px 40px rgba(0,0,0,.1);transform:translateY(20px);transition:.4s var(--bounce); }
    .modal-overlay.active .confirm-modal { transform:translateY(0); }
    .confirm-modal h3 { font-size:17px;font-weight:800;margin:0 0 8px; }
    .confirm-modal p { font-size:13px;color:var(--text-gray);margin:0 0 20px;line-height:1.6; }
    .confirm-btns { display:flex;gap:10px; }
    .btn-cancel { flex:1;padding:12px;border-radius:14px;border:1px solid var(--border-light);background:white;font-size:14px;font-weight:700;cursor:pointer;font-family:inherit;transition:.2s; }
    .btn-cancel:hover { background:#F8FAFC; }
    .btn-confirm-del { flex:1;padding:12px;border-radius:14px;border:none;background:#FF6B6B;color:white;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;transition:.2s; }
    .btn-confirm-del:hover { background:#FF4444; }

    /* 수정 모달 */
    .edit-modal { background:white;width:90%;max-width:520px;border-radius:24px;padding:28px;box-shadow:0 20px 40px rgba(0,0,0,.1);transform:translateY(20px);transition:.4s var(--bounce); }
    .modal-overlay.active .edit-modal { transform:translateY(0); }
    .edit-modal h3 { font-size:17px;font-weight:800;margin:0 0 20px; }
    .star-selector { display:flex;gap:6px;margin-bottom:16px; }
    .star-selector i { font-size:28px;color:#E2E8F0;cursor:pointer;transition:.2s; }
    .star-selector i.on { color:#FFB800; }
    .star-selector i:hover { transform:scale(1.2); }
    .edit-textarea { width:100%;box-sizing:border-box;border:1px solid var(--border-light);border-radius:14px;padding:14px;font-size:14px;font-family:inherit;line-height:1.7;resize:vertical;min-height:120px;outline:none;transition:.2s; }
    .edit-textarea:focus { border-color:var(--sky-blue);box-shadow:0 0 0 3px rgba(137,207,240,.15); }
    .edit-btns { display:flex;gap:10px;margin-top:16px; }
    .btn-confirm-edit { flex:1;padding:12px;border-radius:14px;border:none;background:var(--grad-main);color:white;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;transition:.2s; }
    .btn-confirm-edit:hover { opacity:.85; }

    @media(max-width:1024px){ .mypage-container { grid-template-columns:1fr; } .sidebar { position:relative;top:0; } }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
  <jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="review"/>
  </jsp:include>

  <div class="content-area">
    <div>
      <h2 class="page-title">나의 리뷰 기록</h2>
      <p class="page-subtitle">내가 작성한 장소 리뷰를 모아볼 수 있어요</p>
    </div>

    <!-- 미작성 리뷰 섹션 -->
    <div id="pending-section" style="display:none;">
      <div class="section-label"><i class="bi bi-pencil-square" style="color:var(--light-pink);"></i> 아직 리뷰를 작성하지 않았어요</div>
      <div class="pending-list" id="pending-list"></div>
    </div>

    <!-- 작성된 리뷰 섹션 -->
    <div>
      <div class="section-label" id="written-label" style="display:none;"><i class="bi bi-chat-square-text" style="color:var(--sky-blue);"></i> 작성한 리뷰</div>
      <div id="review-list-area"><div class="spin"></div></div>
    </div>
  </div>
</main>

<!-- 삭제 확인 모달 -->
<div class="modal-overlay" id="deleteModal">
  <div class="confirm-modal">
    <h3>리뷰를 삭제할까요?</h3>
    <p>삭제된 리뷰는 복구할 수 없어요.</p>
    <div class="confirm-btns">
      <button class="btn-cancel" onclick="closeModal('deleteModal')">취소</button>
      <button class="btn-confirm-del" onclick="confirmDelete()">삭제</button>
    </div>
  </div>
</div>

<!-- 수정 모달 -->
<div class="modal-overlay" id="editModal">
  <div class="edit-modal">
    <h3>리뷰 수정</h3>
    <div class="star-selector" id="edit-stars">
      <i class="bi bi-star-fill on" data-v="1"></i>
      <i class="bi bi-star-fill on" data-v="2"></i>
      <i class="bi bi-star-fill on" data-v="3"></i>
      <i class="bi bi-star-fill on" data-v="4"></i>
      <i class="bi bi-star-fill on" data-v="5"></i>
    </div>
    <textarea class="edit-textarea" id="edit-content" placeholder="리뷰 내용을 입력해주세요"></textarea>
    <div class="edit-btns">
      <button class="btn-cancel" onclick="closeModal('editModal')">취소</button>
      <button class="btn-confirm-edit" onclick="confirmEdit()">수정 완료</button>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script>
  var pendingDeleteId = null;
  var pendingDeleteEl = null;
  var editingReviewId = null;
  var editRating = 5;

  // ── 미작성 리뷰 로드 ──
  async function loadPendingReviews() {
    try {
      var res = await fetch('${pageContext.request.contextPath}/mypage/api/pending-reviews');
      if (!res.ok) return;
      var list = await res.json();
      if (!list || !list.length) return;

      var section = document.getElementById('pending-section');
      var area    = document.getElementById('pending-list');
      section.style.display = '';

      var icons = { 'ATTRACTION':'bi-geo-alt-fill', 'RESTAURANT':'bi-cup-straw', 'ACCOMMODATION':'bi-building', 'default':'bi-map-fill' };

      area.innerHTML = list.map(function(r) {
        var icon = icons[r.placeCategory] || icons['default'];
        var dateStr = r.checkOutDate ? '방문: ' + r.checkOutDate : (r.checkInDate ? '방문: ' + r.checkInDate : '');
        return '<div class="pending-card">' +
          '<div class="pending-info">' +
            '<div class="pending-icon"><i class="bi ' + icon + '"></i></div>' +
            '<div>' +
              '<div class="pending-name">' + escHtml(r.placeName) + '</div>' +
              '<div class="pending-date">' + escHtml(dateStr) + '</div>' +
            '</div>' +
          '</div>' +
          '<button class="btn-write-review" onclick="goWriteReview(' + r.reservationId + ',' + r.placeId + ')"><i class="bi bi-pencil"></i> 리뷰 쓰기</button>' +
        '</div>';
      }).join('');
    } catch(e) {}
  }

  function goWriteReview(reservationId, placeId) {
    location.href = '${pageContext.request.contextPath}/accommodation/detail/' + placeId + '?reservationId=' + reservationId + '#review';
  }

  // ── 작성된 리뷰 로드 ──
  async function loadReviews() {
    var area = document.getElementById('review-list-area');
    try {
      var res = await fetch('${pageContext.request.contextPath}/mypage/api/reviews');
      if (!res.ok) throw new Error();
      var list = await res.json();

      if (!list || !list.length) {
        area.innerHTML = '<div class="empty-state"><i class="bi bi-chat-square-text"></i><p>작성한 리뷰가 없어요</p></div>';
        return;
      }

      document.getElementById('written-label').style.display = '';

      area.innerHTML = '<div class="review-list">' +
        list.map(function(r) {
          var stars = '';
          for (var i = 1; i <= 5; i++) {
            stars += '<i class="bi bi-star-fill' + (i <= (r.rating || 0) ? '' : ' empty') + '"></i>';
          }
          // images 필드: 콤마 구분 문자열 → 배열
          var imgList = r.images ? r.images.split(',').filter(function(s){ return s.trim(); }) : [];
          var imgs = '';
          if (imgList.length) {
            imgs = '<div class="review-images">' +
              imgList.slice(0,5).map(function(img) {
                return '<img class="review-img" src="' + escHtml(img.trim()) + '" alt="" loading="lazy">';
              }).join('') +
            '</div>';
          }
          return '<div class="review-card" id="review-' + r.reviewId + '">' +
            '<div class="review-header">' +
              '<div>' +
                '<div class="review-place"><i class="bi bi-geo-alt-fill"></i>' + escHtml(r.placeName || '장소 정보 없음') + '</div>' +
                '<div class="review-stars">' + stars + '</div>' +
              '</div>' +
              '<span class="review-date">' + fmtDate(r.createdAt) + '</span>' +
            '</div>' +
            '<div class="review-content">' + escHtml(r.content) + '</div>' +
            imgs +
            '<div class="review-footer">' +
              '<span class="review-type-tag">' + escHtml(r.placeCategory || '장소') + '</span>' +
              '<div class="review-actions">' +
                '<button class="btn-edit-review" onclick="openEditModal(' + r.reviewId + ',' + (r.rating||5) + ',this)"><i class="bi bi-pencil"></i> 수정</button>' +
                '<button class="btn-delete-review" onclick="askDelete(' + r.reviewId + ', this)"><i class="bi bi-trash3"></i> 삭제</button>' +
              '</div>' +
            '</div>' +
          '</div>';
        }).join('') +
      '</div>';
    } catch(e) {
      area.innerHTML = '<div class="empty-state"><i class="bi bi-exclamation-circle"></i><p>리뷰를 불러올 수 없어요</p></div>';
    }
  }

  // ── 삭제 ──
  function askDelete(id, btn) {
    pendingDeleteId = id;
    pendingDeleteEl = btn.closest('.review-card');
    document.getElementById('deleteModal').classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  async function confirmDelete() {
    if (!pendingDeleteId) return;
    try {
      var res = await fetch('${pageContext.request.contextPath}/mypage/api/reviews/' + pendingDeleteId, { method: 'DELETE' });
      if (!res.ok) throw new Error();
      if (pendingDeleteEl) {
        pendingDeleteEl.style.transition = 'all .3s';
        pendingDeleteEl.style.opacity = '0';
        pendingDeleteEl.style.transform = 'translateX(20px)';
        setTimeout(function() { if (pendingDeleteEl) pendingDeleteEl.remove(); }, 300);
      }
      closeModal('deleteModal');
    } catch(e) { alert('삭제에 실패했어요'); closeModal('deleteModal'); }
    pendingDeleteId = null; pendingDeleteEl = null;
  }

  // ── 수정 모달 ──
  function openEditModal(reviewId, rating, btn) {
    editingReviewId = reviewId;
    editRating = rating || 5;

    // 현재 리뷰 내용 가져오기
    var card    = btn.closest('.review-card');
    var content = card.querySelector('.review-content').textContent;
    document.getElementById('edit-content').value = content;

    // 별점 세팅
    setEditStars(editRating);

    document.getElementById('editModal').classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  function setEditStars(val) {
    editRating = val;
    document.querySelectorAll('#edit-stars i').forEach(function(s) {
      s.classList.toggle('on', parseInt(s.dataset.v) <= val);
    });
  }

  document.querySelectorAll('#edit-stars i').forEach(function(s) {
    s.addEventListener('click', function() { setEditStars(parseInt(s.dataset.v)); });
    s.addEventListener('mouseover', function() {
      document.querySelectorAll('#edit-stars i').forEach(function(x) {
        x.classList.toggle('on', parseInt(x.dataset.v) <= parseInt(s.dataset.v));
      });
    });
    s.addEventListener('mouseleave', function() { setEditStars(editRating); });
  });

  async function confirmEdit() {
    if (!editingReviewId) return;
    var content = document.getElementById('edit-content').value.trim();
    if (!content) { alert('리뷰 내용을 입력해주세요'); return; }

    try {
      var res = await fetch('${pageContext.request.contextPath}/mypage/api/reviews/' + editingReviewId, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rating: editRating, content: content })
      });
      if (!res.ok) throw new Error();

      // 화면 즉시 반영
      var card = document.getElementById('review-' + editingReviewId);
      if (card) {
        card.querySelector('.review-content').textContent = content;
        var stars = card.querySelectorAll('.review-stars i');
        stars.forEach(function(s, i) { s.classList.toggle('empty', i >= editRating); });
      }
      closeModal('editModal');
    } catch(e) { alert('수정에 실패했어요'); }
    editingReviewId = null;
  }

  function closeModal(id) {
    document.getElementById(id).classList.remove('active');
    document.body.style.overflow = '';
    if (id === 'deleteModal') { pendingDeleteId = null; pendingDeleteEl = null; }
    if (id === 'editModal')   { editingReviewId = null; }
  }

  function fmtDate(v) {
    if (!v) return '';
    return new Date(v).toLocaleDateString('ko-KR', { year:'numeric', month:'2-digit', day:'2-digit' });
  }
  function escHtml(s) { if (!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  document.addEventListener('DOMContentLoaded', function() {
    loadPendingReviews();
    loadReviews();
  });
</script>
</body>
</html>
