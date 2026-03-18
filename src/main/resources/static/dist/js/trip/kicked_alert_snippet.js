/**
 * kicked_alert_snippet.js
 * ──────────────────────────────────────────────
 * my_trips.jsp (또는 my-trips 페이지) 하단 </body> 직전에 붙여넣으세요.
 *
 * 역할: workspace.ws.js 에서 강퇴 시 ?kicked=true 쿼리로 리다이렉트된 경우
 *       도착 페이지에서 안전하게 알림을 띄우고 URL을 깔끔하게 정리합니다.
 * ──────────────────────────────────────────────
 */
(function () {
  var params = new URLSearchParams(window.location.search);

  if (params.get('kicked') === 'true') {
    // ① URL에서 ?kicked=true 제거 (뒤로가기 시 알림 재표시 방지)
    var cleanUrl = window.location.pathname;
    if (history.replaceState) {
      history.replaceState(null, '', cleanUrl);
    }

    // ② DOMContentLoaded 이후 확실하게 alert 표시
    //    (페이지 렌더링이 완전히 끝난 뒤 실행되도록 보장)
    function showKickedAlert() {
      alert('🚨 방장에 의해 여행에서 강퇴되었습니다.\n이 여행방에는 다시 입장하실 수 없습니다.');
    }

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', showKickedAlert);
    } else {
      // 이미 DOM이 준비됐으면 바로 실행 (약간의 딜레이로 UI 안정화)
      setTimeout(showKickedAlert, 100);
    }
  }
})();
