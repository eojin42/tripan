/**
 * workspace.ui.js
 * ──────────────────────────────────────────────
 * 담당: 뷰 모드 전환 · 리사이저 · 탭 · 모달 · 토스트 · 방장 권한 · 초대코드 
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   뷰 모드 전환 (편집 / 분할 / 지도)
══════════════════════════════ */
var currentMode  = 'split';
var prevSidebarW = 500;

function setViewMode(mode) {
  if (mode === currentMode) return;

  var layout  = document.getElementById('wsLayout');
  var sidebar = document.getElementById('wsSidebar');

  if (currentMode === 'split') {
    prevSidebarW = parseInt(sidebar.style.width) || 500;
  }

  layout.classList.remove('mode-edit', 'mode-map');
  if (mode === 'edit') layout.classList.add('mode-edit');
  if (mode === 'map')  layout.classList.add('mode-map');

  /* ★ 편집모드: 사이드바가 full-width → data-wide 강제 true
     설정 안 하면 이전 split 모드의 좁은 너비 값이 남아
     [data-wide="false"] 규칙이 정산 카드 등에서 flex-wrap:wrap 적용됨 */
  if (mode === 'edit') {
    sidebar.setAttribute('data-wide', 'true');
  }

  if (mode === 'split') {
    requestAnimationFrame(function () { setSidebarWidth(prevSidebarW); });
  }

  // 지도 모드 진입 → 카카오맵 크기 재계산
  if (mode === 'map' && typeof triggerMapResize === 'function') {
    setTimeout(triggerMapResize, 200);
  }

  document.querySelectorAll('.view-toggle-btn').forEach(function (b) { b.classList.remove('active'); });
  var activeBtn = document.getElementById('vBtn-' + mode);
  if (activeBtn) activeBtn.classList.add('active');

  var META = {
    edit:  '📋 편집 모드 — 일정을 한눈에',
    split: '↔️ 분할 모드',
    map:   '🗺️ 지도 모드 — 동선 확인'
  };
  currentMode = mode;
  showToast(META[mode]);
}

/* 키보드 단축키: E=편집 / S=분할 / M=지도 */
document.addEventListener('keydown', function (e) {
  if (['INPUT', 'TEXTAREA', 'SELECT'].indexOf(e.target.tagName) !== -1) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  var k = e.key.toUpperCase();
  if (k === 'E') setViewMode('edit');
  if (k === 'S') setViewMode('split');
  if (k === 'M') setViewMode('map');
});

/* ══════════════════════════════
   사이드바 리사이저
══════════════════════════════ */
(function () {
  var sidebar = document.getElementById('wsSidebar');
  var resizer = document.getElementById('wsResizer');
  var label   = document.getElementById('sidebarWidthLabel');
  var MIN = 260, MAX = 860, DEFAULT = 500;
  var startX, startW, isDragging = false;

  var tip = document.createElement('div');
  tip.className = 'resize-tooltip';
  document.body.appendChild(tip);

  function setWidth(w) {
    w = Math.round(Math.max(MIN, Math.min(MAX, w)));
    sidebar.style.width = w + 'px';
    if (label) label.textContent = w + 'px';
    sidebar.setAttribute('data-wide', w >= 480 ? 'true' : 'false');
  }
  function showTip(x, y, w) {
    tip.textContent = Math.round(w) + 'px';
    tip.style.left  = (x + 14) + 'px';
    tip.style.top   = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  if (resizer) {
    resizer.addEventListener('mousedown', function (e) {
      e.preventDefault();
      isDragging = true;
      startX = e.clientX;
      startW = sidebar.getBoundingClientRect().width;
      resizer.classList.add('dragging');
      document.body.classList.add('resizing');
      showTip(e.clientX, e.clientY, startW);
    });
  }
  document.addEventListener('mousemove', function (e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setWidth(w);
    showTip(e.clientX, e.clientY, w);
  });
  document.addEventListener('mouseup', function () {
    if (!isDragging) return;
    isDragging = false;
    if (resizer) resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
    showToast('↔ ' + Math.round(sidebar.getBoundingClientRect().width) + 'px 로 조절됨');
  });
  if (resizer) {
    resizer.addEventListener('dblclick', function () {
      sidebar.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
      setWidth(DEFAULT);
      setTimeout(function () { sidebar.style.transition = ''; }, 320);
      showToast('↔ 기본 너비로 초기화됨');
    });
  }

  window.setSidebarWidth = function (w) {
    sidebar.style.transition = 'width .28s cubic-bezier(.19,1,.22,1)';
    setWidth(w);
    setTimeout(function () { sidebar.style.transition = ''; }, 300);
  };

  setWidth(DEFAULT);
})();

/* ══════════════════════════════
   편집모드 추천 패널 리사이저
══════════════════════════════ */
(function () {
  var panel   = document.getElementById('editRecommendPanel');
  var resizer = document.getElementById('editRpResizer');
  if (!resizer) return;
  var MIN = 200, MAX = 560, DEFAULT = 500;
  var startX, startW, isDragging = false;

  var tip = document.createElement('div');
  tip.className = 'resize-tooltip';
  document.body.appendChild(tip);

  function setW(w) {
    w = Math.round(Math.max(MIN, Math.min(MAX, w)));
    panel.style.width = w + 'px';
  }
  function showTip(x, y, w) {
    tip.textContent = Math.round(w) + 'px';
    tip.style.left  = (x + 14) + 'px';
    tip.style.top   = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  resizer.addEventListener('mousedown', function (e) {
    e.preventDefault();
    isDragging = true;
    startX = e.clientX;
    startW = panel.getBoundingClientRect().width;
    resizer.classList.add('dragging');
    document.body.classList.add('resizing');
    showTip(e.clientX, e.clientY, startW);
  });
  document.addEventListener('mousemove', function (e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setW(w);
    showTip(e.clientX, e.clientY, w);
  });
  document.addEventListener('mouseup', function () {
    if (!isDragging) return;
    isDragging = false;
    resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
  });
  resizer.addEventListener('dblclick', function () {
    panel.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
    setW(DEFAULT);
    setTimeout(function () { panel.style.transition = ''; }, 320);
  });
})();

/* ══════════════════════════════
   탭 전환
══════════════════════════════ */
function switchPanel(name, btn) {
  document.querySelectorAll('.sidebar-panel').forEach(function (p) { p.classList.remove('active'); });
  document.querySelectorAll('.ws-tab').forEach(function (t) { t.classList.remove('active'); });
  var panel = document.getElementById('panel-' + name);
  if (panel) panel.classList.add('active');
  if (btn) btn.classList.add('active');
}

/* ══════════════════════════════
   모달
══════════════════════════════ */
function openModal(id) {
  var el = document.getElementById(id);
  if (el) el.classList.add('open');
}
function closeModal(id) {
  var el = document.getElementById(id);
  if (el) el.classList.remove('open');
}
document.querySelectorAll('.modal-overlay').forEach(function (el) {
  el.addEventListener('click', function (e) {
    if (e.target === this) this.classList.remove('open');
  });
});

/* ══════════════════════════════
   토스트 (하단 스택)
══════════════════════════════ */
function showToast(msg) {
  var wrap = document.getElementById('toastWrap');
  if (!wrap) return;
  var t = document.createElement('div');
  t.className   = 'toast';
  t.textContent = msg;
  wrap.appendChild(t);
  setTimeout(function () {
    t.style.transition = 'opacity .3s, transform .3s';
    t.style.opacity    = '0';
    t.style.transform  = 'translateY(10px)';
    setTimeout(function () { t.remove(); }, 300);
  }, 2200);
}

/* ══════════════════════════════
   초대 링크 복사 및 초대코드 재발급 
══════════════════════════════ */
function copyInviteLink() {
    var input = document.getElementById('inviteLinkInput');
    if(input) {
        input.select();
        document.execCommand('copy');
        if (typeof wsToast === 'function') wsToast('초대 링크가 복사되었습니다 🔗');
        else alert('초대 링크가 복사되었습니다.');
    }
}


function refreshInviteCode() {
  if(!confirm("초대 코드를 재발급하시겠습니까?")) return;
  // CTX_PATH가 없으면 빈문자열 처리
  var url = (typeof CTX_PATH !== 'undefined' ? CTX_PATH : '') + '/trip/' + TRIP_ID + '/invite-code';
  
  fetch(url, { method: 'PATCH' })
  .then(function(res) { 
      if(res.status === 404) throw new Error("404 에러: 서버 경로를 확인하세요.");
      return res.json(); 
  })
  .then(function(data) {
      if(data.success) {
          document.getElementById('inviteLinkInput').value = 
              window.location.origin + (CTX_PATH || '') + '/trip/invite/' + data.newCode;
          wsToast('새로운 초대 코드가 발급되었습니다 🔄');
      } else alert(data.message);
  }).catch(function(e){ alert(e.message); });
}


/* ══════════════════════════════════════════════
   동행자 관리 모달 관련 함수 (권한, 강퇴, 나가기)
══════════════════════════════════════════════ */

// 멤버 권한 변경
function onChangeMemberRole(selectEl, memberId) {
  var newRole = selectEl.value;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/members/' + memberId + '/role', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ role: newRole })
  })
  .then(function(res) { return res.json(); })
  .then(function(data) {
      if (data.success) {
          if (typeof showToast === 'function') showToast('권한이 변경되었습니다.');
      } else {
          alert('권한 변경 실패: ' + data.message);
      }
  })
  .catch(function() { alert('오류가 발생했습니다.'); });
}

// 멤버 강퇴
function onKickMember(memberId) {
  // 방장에게 경고창 띄우기
  if (!confirm('정말 이 멤버를 강퇴하시겠습니까?\n🚨 강퇴된 멤버는 이 여행에 다시는 초대할 수 없습니다!')) return;

  // ★ MEMBER_DICT에서 강퇴 대상 닉네임 조회해서 body에 포함
  var targetNickname = (typeof MEMBER_DICT !== 'undefined' && MEMBER_DICT[memberId])
    ? MEMBER_DICT[memberId] : '';
  
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/members/' + memberId + '/kick', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ targetNickname: targetNickname })
  })
  .then(function(res) { return res.json(); })
  .then(function(data) {
      if (data.success) {
          alert(data.message);
          location.reload(); 
      } else alert('강퇴 실패: ' + data.message);
  })
  .catch(function() { alert('오류가 발생했습니다.'); });
}

// 스스로 방 나가기
function onLeaveTrip() {
  if (!confirm('정말 이 여행에서 나가시겠습니까?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/members/leave', {
      method: 'DELETE'
  })
  .then(function(res) { return res.json(); })
  .then(function(data) {
      if (data.success) {
          alert(data.message);
          window.location.href = CTX_PATH + '/trip/my_trips'; 
      } else alert('나가기 실패: ' + data.message);
  })
  .catch(function() { alert('오류가 발생했습니다.'); });
}

/* ══════════════════════════════
   Oracle 대문자 키 → camelCase 정규화
══════════════════════════════ */
function normalizeRow(row) {
  if (!row || typeof row !== 'object') return row;
  var known = {
    /* 체크리스트 */
    'checklistid':'checklistId', 'tripid':'tripId', 'itemname':'itemName',
    'ischecked':'isChecked', 'checkmanager':'checkManager',
    /* 투표 */
    'voteid':'voteId', 'candidateid':'candidateId',
    'candidatename':'candidateName', 'votecount':'voteCount', 'totalvotes':'totalVotes',
    'myvotedcandidateid':'myVotedCandidateId',
    'isclosed':'isClosed', 'deadline':'deadline', 'voternames':'voterNames',
    /* 알림 */
    'notificationid':'notificationId', 'receiverid':'receiverId', 'senderid':'senderId',
    'isread':'isRead', 'createdat':'createdAt', 'timeago':'timeAgo',
    /* 지출 */
    'expenseid':'expenseId', 'payerid':'payerId', 'expensedate':'expenseDate',
    'isprivate':'isPrivate', 'payernickname':'payerNickname',
    'receipturl':'receiptUrl',         
    'paymenttype':'paymentType',
    'receipt_url':'receiptUrl',
    /* 분담자 */
    'participantid':'participantId', 'memberid':'memberId',
    'membernickname':'memberNickname', 'nickname':'nickname',
    'shareamount':'shareAmount', 'paidamount':'paidAmount',
    'shareamount':'shareAmount', 'totalamount':'totalAmount',
    'displayname':'displayName', 'extnickname':'extNickname',
    /* 정산 */
    'settlementid':'settlementId', 'frommemberid':'fromMemberId',
    'tomemberid':'toMemberId', 'settledat':'settledAt',
    'frommembernickname':'fromMemberNickname', 'tomembernickname':'toMemberNickname',
    'fromnickname':'fromNickname', 'tonickname':'toNickname',
    'batchid':'batchId',
    'settlestatus':'settleStatus',
    'settledbatchid':'settledBatchId',
    /* 공통 */
    'title':'title', 'message':'message', 'type':'type', 'category':'category',
    'amount':'amount', 'description':'description', 'status':'status',
    'memo':'memo', 'balance':'balance'  
  };
  var out = {};
  Object.keys(row).forEach(function (k) {
    var mapped = known[k.toLowerCase()];
    out[mapped || k] = row[k];
  });
  return out;
}

/* ══════════════════════════════
   이미지 뷰어 (Lightbox) 
══════════════════════════════ */
function openImageViewer(src) {
  var viewer = document.getElementById('imageViewerModal');
  var img = document.getElementById('viewerImage');
  if(viewer && img) {
    img.src = src;
    viewer.classList.add('open');
  }
}

function closeImageViewer() {
  var viewer = document.getElementById('imageViewerModal');
  if(viewer) {
    viewer.classList.remove('open');
    // 애니메이션 끝난 후 src 초기화 (깜빡임 방지)
    setTimeout(() => { document.getElementById('viewerImage').src = ""; }, 200); 
  }
}