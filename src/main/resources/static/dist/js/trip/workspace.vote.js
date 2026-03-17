/**
 * workspace.vote.js
 * ──────────────────────────────────────────────
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH, LOGIN_MEMBER_ID
 */

/* ══════════════════════════════
   로컬 투표 상태 { voteId → candidateId }
   서버 myVotedCandidateId 가 우선, 이건 페이지 내 즉시 반영용 폴백
══════════════════════════════ */
var _myVotes = {};

/* ══════════════════════════════
   투표 목록 로드
══════════════════════════════ */
function loadVotes() {
  var memberParam = (typeof LOGIN_MEMBER_ID !== 'undefined' && LOGIN_MEMBER_ID !== null)
    ? '?memberId=' + LOGIN_MEMBER_ID : '';

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote' + memberParam)
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (rows) {
      // normalizeRow 적용 (Oracle 대문자 키 → camelCase)
      var normalized = (rows || []).map(function(r) { return normalizeRow(r); });
      renderVotes(normalized);
    })
    .catch(function () {
      var grid = document.getElementById('voteGrid');
      if (grid) grid.innerHTML =
        '<div class="vote-empty-state">' +
        '<div style="font-size:32px;margin-bottom:8px;">😢</div>' +
        '<div style="font-size:13px;color:#A0AEC0;">투표를 불러오지 못했어요</div>' +
        '</div>';
    });
}

/* ══════════════════════════════
   렌더링
══════════════════════════════ */
function renderVotes(rows) {
  var grid = document.getElementById('voteGrid');
  if (!grid) return;

  if (!rows || rows.length === 0) {
    grid.innerHTML =
      '<div class="vote-empty-state">' +
      '<div style="font-size:40px;margin-bottom:12px;">🗳️</div>' +
      '<div style="font-size:14px;font-weight:700;color:#4A5568;margin-bottom:6px;">투표가 없어요</div>' +
      '<div style="font-size:12px;color:#A0AEC0;">+ 투표 만들기로 의견을 모아보세요</div>' +
      '</div>';
    return;
  }

  /* voteId 기준 그룹핑 */
  var votes = {};
  rows.forEach(function (r) {
    /* ★ Oracle은 NUMBER를 문자열/숫자 혼용 반환 → String으로 통일 */
    var vid = String(r.voteId || r.VOTEID || '');
    if (!vid) return;

    if (!votes[vid]) {
      votes[vid] = {
        voteId:             vid,
        title:              r.title  || r.TITLE  || '',
        deadline:           r.deadline || r.DEADLINE || null,
        /* ★ Oracle 숫자 1/0 → Number로 올 수 있음 */
        isClosed:           Number(r.isClosed || r.ISCLOSED || 0) === 1,
        totalVotes:         r.totalVotes || r.TOTALVOTES || 0,
        /* ★ 서버에서 오는 myVotedCandidateId: 숫자 또는 문자열 → String으로 통일 */
        myVotedCandidateId: r.myVotedCandidateId != null ? String(r.myVotedCandidateId) : null,
        candidates: []
      };
    }
    votes[vid].candidates.push(r);
  });

  var html = '';
  Object.values(votes).forEach(function (v) {
    var total    = parseInt(v.totalVotes) || 0;
    var isClosed = v.isClosed;

    /* ★ 서버 응답 우선 → 로컬 폴백 */
    var myVotedId = v.myVotedCandidateId || _myVotes[v.voteId] || null;
    var alreadyVoted = !!myVotedId;

    /* ── 카드 ── */
    html += '<div class="vote-card' + (isClosed ? ' vote-card--closed' : '') + '">';

    /* 헤더 */
    html += '<div class="vote-card__header">';
    html +=   '<div class="vote-card__title-row">';
    html +=     '<span class="vote-card__icon">' + (isClosed ? '🔒' : '🗳️') + '</span>';
    html +=     '<span class="vote-card__title">' + _esc(v.title) + '</span>';
    html +=   '</div>';

    /* 배지 + 참여수 */
    html +=   '<div class="vote-card__meta">';
    if (isClosed) {
      html += '<span class="vote-badge vote-badge--closed">마감됨</span>';
    } else if (v.deadline) {
      html += '<span class="vote-badge vote-badge--open">⏰ ' + v.deadline + ' 마감</span>';
    } else {
      html += '<span class="vote-badge vote-badge--open">진행중</span>';
    }
    if (alreadyVoted && !isClosed) {
      html += '<span class="vote-badge vote-badge--voted">✓ 투표완료</span>';
    }
    html +=   '<span class="vote-card__count">' + total + '명 참여</span>';
    html +=   '</div>';
    html += '</div>'; /* vote-card__header */

    /* ── 후보 바 ── */
    v.candidates.forEach(function (c) {
      /* candidateId도 String 통일 */
      var cid  = String(c.candidateId || c.CANDIDATEID || '');
      var cnt  = parseInt(c.voteCount || c.VOTECOUNT || 0);
      var pct  = total === 0 ? 0 : Math.round(cnt / total * 100);
      var isMyPick = alreadyVoted && myVotedId === cid;
      var cName    = c.candidateName || c.CANDIDATENAME || '';
      var voters   = (c.voterNames   || c.VOTERNAMES   || '').toString().trim();

      html += '<div class="vote-option' + (isMyPick ? ' vote-option--mine' : '') + '">';
      html +=   '<div class="vote-option__top">';
      html +=     '<span class="vote-option__name">';
      if (isMyPick) html += '<span class="vote-option__check">✓</span> ';
      html +=     _esc(cName) + '</span>';
      html +=     '<span class="vote-option__pct' + (isMyPick ? ' vote-option__pct--mine' : '') + '">'
                + pct + '%' + (isClosed && isMyPick ? ' 🏆' : '') + '</span>';
      html +=   '</div>';
      html +=   '<div class="vote-bar-bg">';
      html +=     '<div class="vote-bar-fill'
                + (isMyPick ? ' vote-bar-fill--mine' : (isClosed ? ' vote-bar-fill--closed' : ''))
                + '" style="width:' + pct + '%"></div>';
      html +=   '</div>';
      /* 투표자 목록 */
      if (voters) {
        html += '<div class="vote-option__voters">👤 ' + _esc(voters) + '</div>';
      }
      html += '</div>'; /* vote-option */
    });

    /* ── 투표 버튼 행 ── */
    html += '<div class="vote-card__divider"></div>';
    /* 버튼 행 + 휴지통 아이콘 나란히 */
    html += '<div class="vote-actions-row">';
    html += '<div class="vote-btn-row">';
    v.candidates.forEach(function (c) {
      var cid      = String(c.candidateId || c.CANDIDATEID || '');
      var cName    = c.candidateName || c.CANDIDATENAME || '';
      var isMyPick = alreadyVoted && myVotedId === cid;

      var cls = '', dis = '', ttl = '';
      if (isClosed) {
        cls = isMyPick ? ' voted' : ' voted-gray';
        dis = ' disabled'; ttl = ' title="투표가 마감됐어요"';
      } else if (alreadyVoted) {
        cls = isMyPick ? ' voted' : ' voted-gray';
        dis = ' disabled';
        ttl = isMyPick ? ' title="내가 선택한 후보"' : ' title="이미 투표하셨어요"';
      }
      html += '<button class="btn-vote' + cls + '"' + dis + ttl
            + ' onclick="castVote(\'' + v.voteId + '\',' + cid + ',this)">'
            + _esc(cName) + '</button>';
    });
    html += '</div>'; /* vote-btn-row */
    html += '<button class="btn-vote-icon-delete" onclick="deleteVote(\'' + v.voteId + '\')" title="투표 삭제">🗑️</button>';
    html += '</div>'; /* vote-actions-row */
    html += '</div>'; /* vote-card */
  });

  grid.innerHTML = html;
}

function _esc(str) {
  if (!str) return '';
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ══════════════════════════════
   모달 열기
══════════════════════════════ */
function openVoteModal() {
  var titleEl    = document.getElementById('vote-title');
  var optsEl     = document.getElementById('voteOptions');
  var deadlineEl = document.getElementById('vote-deadline');
  if (titleEl)    titleEl.value = '';
  if (deadlineEl) deadlineEl.value = '';
  if (optsEl) {
    optsEl.innerHTML =
      '<input type="text" class="form-input vote-opt-input" placeholder="후보 1" style="margin-bottom:8px">' +
      '<input type="text" class="form-input vote-opt-input" placeholder="후보 2" style="margin-bottom:8px">';
  }
  openModal('createVoteModal');
}

function addVoteOption() {
  var opts  = document.getElementById('voteOptions');
  var count = opts.querySelectorAll('.vote-opt-input').length + 1;
  if (count > 6) { showToast('⚠️ 후보는 최대 6개까지 가능해요'); return; }
  var inp = document.createElement('input');
  inp.type = 'text'; inp.className = 'form-input vote-opt-input';
  inp.placeholder = '후보 ' + count; inp.style.marginBottom = '8px';
  opts.appendChild(inp);
  inp.focus();
}

/* ══════════════════════════════
   투표 생성 (POST)
══════════════════════════════ */
function submitVote() {
  var title = ((document.getElementById('vote-title') || {}).value || '').trim();
  if (!title) { showToast('⚠️ 투표 제목을 입력해주세요'); return; }

  var candidates = Array.from(document.querySelectorAll('.vote-opt-input'))
    .map(function (i) { return i.value.trim(); })
    .filter(function (v) { return v.length > 0; });
  if (candidates.length < 2) { showToast('⚠️ 후보지를 2개 이상 입력해주세요'); return; }

  var deadlineVal = ((document.getElementById('vote-deadline') || {}).value || '').trim();
  var deadline    = deadlineVal || null;

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote', {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ title: title, candidates: candidates, deadline: deadline })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      closeModal('createVoteModal');
      loadVotes();
      showToast('🗳️ 투표가 생성됐어요!');
    } else {
      showToast('⚠️ ' + (data.message || '투표 생성 실패'));
    }
  });
}

/* ══════════════════════════════
   투표 참여 (POST)
══════════════════════════════ */
function castVote(voteId, candidateId, btn) {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId + '/cast', {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ candidateId: candidateId })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      _myVotes[String(voteId)] = String(candidateId);
      showToast('✅ 투표 완료!');
      loadVotes();
    } else {
      showToast('⚠️ ' + (data.message || '이미 투표하셨어요'));
      if (!_myVotes[String(voteId)] && data.candidateId) {
        _myVotes[String(voteId)] = String(data.candidateId);
      }
      loadVotes();
    }
  });
}

/* ══════════════════════════════
   투표 삭제 (DELETE)
══════════════════════════════ */
function deleteVote(voteId) {
  if (!confirm('투표를 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId, { method: 'DELETE' })
    .then(function () {
      delete _myVotes[String(voteId)];
      loadVotes();
      showToast('🗑 투표 삭제됨');
    });
}

/* ══════════════════════════════
   초기 로드
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  loadVotes();
});
