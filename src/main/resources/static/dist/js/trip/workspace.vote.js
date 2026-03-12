/**
 * workspace.vote.js
 * ──────────────────────────────────────────────
 * 담당: 투표 CRUD 전체
 *       ← JSP 인라인 loadVotes / renderVotes / openVoteModal /
 *          submitVote / castVote / deleteVote 이동
 *          (기존 파일은 사실상 빈 파일이었음)
 *
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   API 로드 & 렌더
══════════════════════════════ */
function loadVotes() {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote')
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (rows) { renderVotes((rows || []).map(normalizeRow)); })
    .catch(function () {
      var grid = document.getElementById('voteGrid');
      if (grid) grid.innerHTML =
        '<div style="text-align:center;padding:20px;color:#bbb;font-size:13px">투표를 불러오지 못했어요</div>';
    });
}

function renderVotes(rows) {
  var grid = document.getElementById('voteGrid');
  if (!grid) return;

  if (!rows || rows.length === 0) {
    grid.innerHTML =
      '<div id="voteEmpty" style="text-align:center;padding:40px 20px;color:#A0AEC0;">' +
      '<div style="font-size:36px;margin-bottom:10px;">🗳️</div>' +
      '<div style="font-size:14px;font-weight:600;margin-bottom:4px;">투표가 없어요</div>' +
      '<div style="font-size:12px;">+ 투표 만들기로 의견을 모아보세요</div></div>';
    return;
  }

  // voteId 기준 그룹핑 (서버가 candidate별 row 반환)
  var votes = {};
  rows.forEach(function (r) {
    if (!votes[r.voteId]) {
      votes[r.voteId] = { voteId: r.voteId, title: r.title, totalVotes: r.totalVotes, candidates: [] };
    }
    votes[r.voteId].candidates.push(r);
  });

  var html = '';
  Object.values(votes).forEach(function (v) {
    var total = parseInt(v.totalVotes) || 0;
    html += '<div class="vote-card">'
      + '<div class="vote-card__emoji">🗳️</div>'
      + '<div class="vote-card__title">' + v.title + '</div>'
      + '<div class="vote-card__sub"><span>' + total + '명 참여</span></div>';

    v.candidates.forEach(function (c) {
      var cnt = parseInt(c.voteCount) || 0;
      var pct = total === 0 ? 0 : Math.round(cnt / total * 100);
      html += '<div class="vote-option">'
        + '<div class="vote-option__top">'
        + '<span class="vote-option__name">' + c.candidateName + '</span>'
        + '<span class="vote-option__pct">' + pct + '%</span>'
        + '</div>'
        + '<div class="vote-bar-bg"><div class="vote-bar-fill" style="width:' + pct + '%"></div></div>'
        + '</div>';
    });

    html += '<div class="vote-card__divider"></div><div style="display:flex;gap:6px;flex-wrap:wrap;">';
    v.candidates.forEach(function (c) {
      html += '<button class="btn-vote" style="flex:1;font-size:12px;"'
        + ' onclick="castVote(' + v.voteId + ',' + c.candidateId + ',this)">'
        + c.candidateName + '</button>';
    });
    html += '</div>'
      + '<button class="btn-vote" style="background:transparent;color:#FC8181;border:1px solid #FED7D7;font-size:11px;margin-top:6px;"'
      + ' onclick="deleteVote(' + v.voteId + ')">🗑 투표 삭제</button>'
      + '</div>';
  });

  grid.innerHTML = html;
}

/* ══════════════════════════════
   모달 열기
══════════════════════════════ */
function openVoteModal() {
  var titleEl = document.getElementById('vote-title');
  var optsEl  = document.getElementById('voteOptions');
  if (titleEl) titleEl.value = '';
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
  var inp   = document.createElement('input');
  inp.type = 'text'; inp.className = 'form-input vote-opt-input';
  inp.placeholder = '후보 ' + count; inp.style.marginBottom = '8px';
  opts.appendChild(inp);
}

/* ══════════════════════════════
   투표 생성 (POST)
══════════════════════════════ */
function submitVote() {
  var title = document.getElementById('vote-title').value.trim();
  if (!title) { alert('투표 제목을 입력해주세요'); return; }

  var candidates = Array.from(document.querySelectorAll('.vote-opt-input'))
    .map(function (i) { return i.value.trim(); })
    .filter(function (v) { return v.length > 0; });
  if (candidates.length < 2) { alert('후보지를 2개 이상 입력해주세요'); return; }

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: title, candidates: candidates })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      closeModal('createVoteModal');
      loadVotes();
      showToast('🗳️ 투표가 생성됐어요!');
    } else {
      alert(data.message || '투표 생성 실패');
    }
  });
}

/* ══════════════════════════════
   투표 참여 (POST)
══════════════════════════════ */
function castVote(voteId, candidateId, btn) {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId + '/cast', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ candidateId: candidateId })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      showToast('✅ 투표 완료!');
      loadVotes();
    } else {
      showToast('⚠️ ' + (data.message || '이미 투표하셨어요'));
    }
  });
}

/* ══════════════════════════════
   투표 삭제 (DELETE)
══════════════════════════════ */
function deleteVote(voteId) {
  if (!confirm('투표를 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId, { method: 'DELETE' })
    .then(function () { loadVotes(); showToast('🗑 투표 삭제됨'); });
}

/* ══════════════════════════════
   자동 초기 로드
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  loadVotes();
});
