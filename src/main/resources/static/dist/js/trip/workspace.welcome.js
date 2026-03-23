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

    // ★ 담아오기 안내 모달 (isScraped) — 일반 환영 모달보다 우선
    var scrapModal = document.getElementById('scrapWelcomeModal');
    if (scrapModal) {
      setTimeout(function () {
        scrapModal.classList.add('open');
        var box = scrapModal.querySelector('.welcome-modal-box');
        if (box) box.style.animation = 'welcomeSlideIn .5s cubic-bezier(.19,1,.22,1) forwards';
      }, 400);
      return; // 담아오기 모달이 있으면 일반 환영 모달은 열지 않음
    }

    var modal = document.getElementById('welcomeModal');
    if (modal) {
      setTimeout(function () {
        modal.classList.add('open');
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

function closeScrapWelcomeModal() {
  var modal = document.getElementById('scrapWelcomeModal');
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

  // 읽음 처리 (일반 환영 모달과 동일한 API)
  fetch(CTX_PATH + '/trip/' + TRIP_ID + '/welcome/done', {
    method: 'PATCH'
  }).catch(function () {
    console.warn('[ScrapWelcome] 읽음 처리 실패');
  });
}