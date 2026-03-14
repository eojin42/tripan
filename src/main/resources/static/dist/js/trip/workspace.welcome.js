/**
 * workspace_welcome.js
 * ──────────────────────────────────────────────
 * 담당: 1회성 환영 모달 표시 & 읽음 처리
 *
 * 동작 흐름:
 *   JSP → TripController.workspace() → isFirstVisit 확인
 *   → showWelcome=true 이면 JSP에서 모달 HTML 렌더
 *   → DOMContentLoaded 시 모달 open
 *   → "시작하기" 클릭 → PATCH /trip/{tripId}/welcome/done
 *   → isFirstVisit = 0 (다음 접속부터 모달 미표시)
 *
 * 의존: workspace.ui.js (showToast)
 *       TRIP_ID, CTX_PATH, SHOW_WELCOME (JSP 주입)
 * ──────────────────────────────────────────────
 */

document.addEventListener('DOMContentLoaded', function () {
  // SHOW_WELCOME이 true이고 모달이 DOM에 있으면 열기
  if (typeof SHOW_WELCOME !== 'undefined' && SHOW_WELCOME) {
    var modal = document.getElementById('welcomeModal');
    if (modal) {
      // 잠깐 딜레이 후 표시 (페이지 로딩 완료 후)
      setTimeout(function () {
        modal.classList.add('open');
        // 배경 애니메이션
        var box = modal.querySelector('.welcome-modal-box');
        if (box) box.style.animation = 'welcomeSlideIn .5s cubic-bezier(.19,1,.22,1) forwards';
      }, 400);
    }
  }
});

function closeWelcomeModal() {
  var modal = document.getElementById('welcomeModal');
  if (modal) {
    var box = modal.querySelector('.welcome-modal-box');
    if (box) {
      box.style.transition = 'opacity .25s, transform .25s';
      box.style.opacity    = '0';
      box.style.transform  = 'scale(.95) translateY(10px)';
    }
    setTimeout(function () {
      modal.classList.remove('open');
    }, 280);
  }

  // 서버에 1회성 완료 처리
  fetch(CTX_PATH + '/trip/' + TRIP_ID + '/welcome/done', {
    method: 'PATCH'
  }).catch(function () {
    // 실패해도 UX에 영향 없음 (다음 번에 다시 시도)
    console.warn('[Welcome] 읽음 처리 실패 — 다음 접속 시 재시도');
  });
}
