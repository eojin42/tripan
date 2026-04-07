
(function () {
  var params = new URLSearchParams(window.location.search);

  if (params.get('kicked') === 'true') {
    // URL에서 ?kicked=true 제거 (뒤로가기 시 알림 재표시 방지)
    var cleanUrl = window.location.pathname;
    if (history.replaceState) {
      history.replaceState(null, '', cleanUrl);
    }

    // DOMContentLoaded 이후 확실하게 alert 표시
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
