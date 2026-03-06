/*
 * member.js  —  회원 관리 목록 페이지 (main.jsp) 전용
 *
 * ★ 변경 사항
 *  - openDetailModal() → memberDetail 페이지로 직접 이동 (JSP 인라인 스크립트와 동일 동작)
 *  - filterTable / renderTable / 체크박스 / 엑셀 로직은 JSP 인라인 스크립트에서 담당하므로 제거
 *  - 남은 함수: openInfoModal, closeInfoModal, checkAdminStatus, closeModal,
 *               showReason, saveChanges, updateKPI (원본 호환용)
 */

/* ── openDetailModal: 상세/수정 버튼 클릭 → memberDetail 페이지 이동 ── */
function openDetailModal(event, btnElement) {
  event.stopPropagation();
  const row      = btnElement.closest('.member-row');
  const memberId = row ? row.getAttribute('data-memberid') : null;
  if (!memberId) {
    alert('회원 식별자를 찾을 수 없습니다.');
    return;
  }
  location.href = contextPath + '/admin/member/detail/' + memberId;
}

/* ── openInfoModal: 닉네임 클릭 시 AJAX 상세 팝업 (기존 호환용, 현재는 링크로 대체) ── */
function openInfoModal(memberId) {
  if (!memberId) { alert('회원 식별자가 없습니다.'); return; }

  fetch(contextPath + '/admin/member/detail/' + memberId)
    .then(res => {
      if (!res.ok) throw new Error('조회 실패');
      return res.json();
    })
    .then(data => {
      document.getElementById('infoNickname').innerText = data.nickname || '이름 없음';
      document.getElementById('infoEmail').innerText    = data.email    || '-';
      document.getElementById('infoUsername').innerText = data.username || '-';
      document.getElementById('infoPhone').innerText    = data.phoneNumber || '-';

      const gender = data.gender === 'M' ? '남성' : (data.gender === 'F' ? '여성' : '-');
      document.getElementById('infoGenderBirth').innerText = `${gender} / ${data.birthday || '-'}`;

      if (data.lastLoginAt) {
        document.getElementById('infoLastLogin').innerText = new Date(data.lastLoginAt).toLocaleString('ko-KR');
      } else {
        document.getElementById('infoLastLogin').innerText = '-';
      }

      document.getElementById('infoModal').style.display = 'flex';
    })
    .catch(err => {
      console.error(err);
      alert('회원 정보를 불러오는데 실패했습니다.');
    });
}

function closeInfoModal() {
  const el = document.getElementById('infoModal');
  if (el) el.style.display = 'none';
}

/* ── 권한 변경 시 상태 옵션 조정 (detailModal 내부용 — 현재 미사용이나 호환 유지) ── */
function checkAdminStatus(passedRole) {
  const role        = passedRole || (document.getElementById('modalRoleSelect') && document.getElementById('modalRoleSelect').value);
  const statusSelect = document.getElementById('modalStatusSelect');
  if (!statusSelect) return;
  const userOnlyOpts = statusSelect.querySelectorAll('.user-status-only');
  if (role === 'ROLE_ADMIN' || role === 'ADMIN') {
    userOnlyOpts.forEach(opt => opt.style.display = 'none');
    statusSelect.value = '1';
  } else {
    userOnlyOpts.forEach(opt => opt.style.display = '');
  }
}

function closeModal() {
  const el = document.getElementById('detailModal');
  if (el) el.style.display = 'none';
}

/* ── saveChanges: detailModal 내부 저장 (호환용) ── */
function saveChanges() {
  const statusEl = document.getElementById('modalStatusSelect');
  const reasonEl = document.getElementById('modalReasonInput');
  if (!statusEl || !reasonEl) return;

  const newStatus = statusEl.value;
  const reason    = reasonEl.value.trim();

  if ((newStatus === '2' || newStatus === '4') && !reason) {
    alert('활동 정지 또는 탈퇴 처리 시 반드시 사유를 입력해야 합니다.');
    reasonEl.focus();
    return;
  }

  if (confirm('회원 정보 및 권한/상태를 변경하시겠습니까?')) {
    // TODO: 실제 서버 호출로 교체
    alert('성공적으로 저장되었습니다.');
    if (typeof currentOldStatus !== 'undefined') updateKPI(currentOldStatus, newStatus);
    closeModal();
  }
}

/* ── KPI 카운트 UI 업데이트 ── */
function updateKPI(oldStatus, newStatus) {
  if (oldStatus === newStatus) return;
  const elActive = document.getElementById('kpiActive');
  const elBan    = document.getElementById('kpiBan');
  if (!elActive || !elBan) return;

  let activeCnt = parseInt(elActive.innerText.replace(/,/g, '')) || 0;
  let banCnt    = parseInt(elBan.innerText.replace(/,/g, ''))    || 0;

  if (oldStatus === '1') activeCnt--;
  else if (oldStatus === '2') banCnt--;

  if (newStatus === '1') activeCnt++;
  else if (newStatus === '2') banCnt++;

  elActive.innerText = activeCnt.toLocaleString('ko-KR');
  elBan.innerText    = banCnt.toLocaleString('ko-KR');
}

const contextPath = '${pageContext.request.contextPath}';

let filteredRows = [];
let currentPage  = 1;
const rowsPerPage = 10;
let hasSearched   = false; // ★ 1) 검색 실행 여부 플래그

/* 검색 — 버튼 클릭 시에만 목록 노출 */
function filterTable() {
  const roleFilter     = document.getElementById('searchRole').value;
  const statusFilter   = document.getElementById('searchStatus').value;
  const categoryFilter = document.getElementById('searchCategory').value;
  const rawKeyword     = document.getElementById('searchInput').value.trim();

  const keywords = rawKeyword
    ? rawKeyword.split(/[,\n]+/).map(k => k.trim().toLowerCase()).filter(Boolean)
    : [];

  hasSearched = true;

  const emptyMsg = document.getElementById('emptySearchMsg');
  if (emptyMsg) emptyMsg.style.display = 'none';

  // 체크 초기화
  document.getElementById('checkAll').checked = false;
  filteredRows = [];

  document.querySelectorAll('.member-row').forEach(row => {
    row.querySelector('.row-check').checked = false;

    const rowRole   = row.dataset.role;
    const rowStatus = row.dataset.status; // data-status 기준 (DOM 텍스트 아닌 원본값)

    let searchText = '';
    if (categoryFilter === 'id') {
      searchText = (row.querySelector('.col-id')?.innerText || '').toLowerCase();
    } else {
      searchText = (row.dataset.nickname || '').toLowerCase();
    }

    const matchRole    = roleFilter   === 'ALL' || roleFilter   === rowRole;
    const matchStatus  = statusFilter === 'ALL' || statusFilter === rowStatus;
    const matchKeyword = keywords.length === 0  || keywords.some(k => searchText.includes(k));

    if (matchRole && matchStatus && matchKeyword) filteredRows.push(row);
    row.style.display = 'none';
  });

  currentPage = 1;
  renderTable();
  onRowCheck();
}

/* 페이징 렌더링 */
function renderTable() {
  document.querySelectorAll('.member-row').forEach(r => r.style.display = 'none');

  if (!hasSearched) return; // 검색 전이면 아무것도 표시 안 함

  const tbody    = document.getElementById('memberTableBody');
  const noResult = document.getElementById('noResultMsg');

  if (filteredRows.length === 0) {
    if (!noResult) {
      tbody.insertAdjacentHTML('beforeend',
        '<tr id="noResultMsg"><td colspan="8" style="text-align:center;padding:30px;color:var(--danger);">일치하는 회원이 없습니다.</td></tr>');
    } else {
      noResult.style.display = '';
    }
    renderPagination(0);
    return;
  }
  if (noResult) noResult.style.display = 'none';

  const start = (currentPage - 1) * rowsPerPage;
  for (let i = start; i < start + rowsPerPage && i < filteredRows.length; i++) {
    filteredRows[i].style.display = '';
  }
  renderPagination(filteredRows.length);
}

function renderPagination(totalRows) {
  let pc = document.getElementById('pagination-container');
  if (!pc) {
    pc = document.createElement('div');
    pc.id = 'pagination-container';
    pc.style.cssText = 'text-align:center; padding:15px 0;';
    document.querySelector('.table-responsive').appendChild(pc);
  }
  pc.innerHTML = '';
  if (totalRows === 0) return;
  const totalPages = Math.ceil(totalRows / rowsPerPage);
  for (let i = 1; i <= totalPages; i++) {
    const btn = document.createElement('button');
    btn.innerText = i;
    btn.className = i === currentPage ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm';
    btn.style.margin = '0 3px';
    btn.onclick = () => { currentPage = i; renderTable(); };
    pc.appendChild(btn);
  }
}

/* 체크박스 */
function toggleCheckAll(master) {
  document.querySelectorAll('.member-row').forEach(row => {
    if (row.style.display !== 'none') {
      row.querySelector('.row-check').checked = master.checked;
    }
  });
  onRowCheck();
}

function onRowCheck() {
  let checkedCount = 0, visibleCount = 0;
  document.querySelectorAll('.member-row').forEach(row => {
    if (row.style.display !== 'none') {
      visibleCount++;
      if (row.querySelector('.row-check').checked) checkedCount++;
    }
  });
  const bar = document.getElementById('bulkBar');
  const cnt = document.getElementById('bulkCount');
  if (checkedCount > 0) { bar.classList.add('visible'); cnt.textContent = checkedCount + '명'; }
  else                  { bar.classList.remove('visible'); }
  const ca = document.getElementById('checkAll');
  if (ca) {
    ca.checked       = visibleCount > 0 && checkedCount === visibleCount;
    ca.indeterminate = checkedCount > 0 && checkedCount < visibleCount;
  }
}

/* ID 복사 */
function copySelectedIds() {
  const ids = [];
  document.querySelectorAll('.member-row').forEach(row => {
    const cb = row.querySelector('.row-check');
    if (row.style.display !== 'none' && cb.checked) ids.push(cb.value);
  });
  navigator.clipboard.writeText(ids.join(', ')).then(() => {
    alert('✅ ' + ids.length + '개의 ID가 복사되었습니다.\n검색창에 붙여넣기 하세요.');
  }).catch(() => {
    prompt('아래 ID를 복사하세요:', ids.join(', '));
  });
}

/* 상태 일괄 변경 */
function openBulkStatusModal() {
  const cnt = document.getElementById('bulkCount').textContent;
  document.getElementById('bulkStatusDesc').textContent = cnt + '의 회원 상태를 일괄 변경합니다.';
  document.getElementById('bulkStatusReason').value = '';
  document.getElementById('bulkStatusModal').style.display = 'flex';
}
function closeBulkStatusModal() { document.getElementById('bulkStatusModal').style.display = 'none'; }

function applyBulkStatus() {
  const newStatus = document.getElementById('bulkStatusSelect').value;
  const reason    = document.getElementById('bulkStatusReason').value.trim();

  if ((newStatus === '2' || newStatus === '4') && !reason) {
    alert('정지/탈퇴 처리 시 사유를 입력해야 합니다.');
    document.getElementById('bulkStatusReason').focus();
    return;
  }

  // TODO: fetch POST /admin/member/bulk-status

  const statusUI = {
    '1': { html: '<span class="badge badge-done">정상</span>' },
    '2': { html: '<span class="badge badge-danger">BAN(정지)</span>' },
    '3': { html: '<span class="badge" style="background:#fef3c7;color:#b45309;">휴면</span>' },
    '4': { html: '<span class="badge" style="background:var(--bg);color:var(--muted)">탈퇴 완료</span>' }
  };
  const s = statusUI[newStatus];

  let changedCount = 0;
  const changedRows = [];

  document.querySelectorAll('.member-row').forEach(row => {
    const cb = row.querySelector('.row-check');
    if (row.style.display !== 'none' && cb.checked) {
      //  data-status 원본값 업데이트 → 이후 재검색 기준으로 사용
      row.dataset.status = newStatus;
      // UI 배지 갱신
      const statusCell = row.querySelector('.col-status');
      if (statusCell && s) statusCell.innerHTML = s.html;
      cb.checked = false;
      changedCount++;
      changedRows.push(row);
    }
  });

  // filteredRows에서 제거 → 현재 조회 결과에서 즉시 빠져나감
  filteredRows = filteredRows.filter(r => !changedRows.includes(r));
  changedRows.forEach(r => r.style.display = 'none');

  onRowCheck();
  currentPage = 1;
  renderPagination(filteredRows.length);
  closeBulkStatusModal();
  alert('✅ ' + changedCount + '명의 상태가 변경되었습니다.');
}

/*  엑셀 다운로드 — filteredRows 기반으로 정확히 추출 */
function downloadFilteredExcel(selectedOnly) {
  let rowsToExport = [];

  if (selectedOnly) {
    document.querySelectorAll('.member-row').forEach(row => {
      const cb = row.querySelector('.row-check');
      if (row.style.display !== 'none' && cb && cb.checked) rowsToExport.push(row);
    });
  } else {
    // 검색 결과 전체 (페이지 무관) — filteredRows 사용
    rowsToExport = filteredRows;
  }

  if (rowsToExport.length === 0) {
    alert('다운로드할 데이터가 없습니다. 먼저 검색을 실행해주세요.');
    return;
  }

  const statusMap = { '1':'정상', '2':'정지', '3':'휴면', '4':'탈퇴' };

  // data-* 속성에서 직접 추출 (innerText 대신 원본 데이터 사용)
  let csv = '\uFEFF' + 'ID,닉네임,권한,상태,위반지표,가입일\n';
  rowsToExport.forEach(row => {
    const id        = (row.querySelector('.col-id')?.innerText   || '').trim();
    const nickname  = (row.dataset.nickname || '').trim();
    const role      = (row.dataset.role     || '').trim();
    const statusTxt = statusMap[row.dataset.status] || row.dataset.status;
    const report    = (row.querySelectorAll('td')[6]?.innerText  || '-').trim();
    const date      = (row.querySelector('.date-cell')?.innerText || '').trim();
    csv += `"${id}","${nickname}","${role}","${statusTxt}","${report}","${date}"\n`;
  });

  const blob = new Blob([csv], { type:'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = '회원목록_' + new Date().toISOString().slice(0,10) + '.csv';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

/* 날짜 정렬 */
let dateSortAsc = true;
function sortByDate() {
  if (filteredRows.length === 0) return;
  filteredRows.sort((a, b) => {
    const da = new Date(a.querySelector('.date-cell')?.innerText.trim());
    const db = new Date(b.querySelector('.date-cell')?.innerText.trim());
    return dateSortAsc ? da - db : db - da;
  });
  dateSortAsc = !dateSortAsc;
  const icon = document.getElementById('dateSortIcon');
  if (icon) icon.textContent = dateSortAsc ? '↑' : '↓';
  currentPage = 1;
  renderTable();
}

/* 상세/수정 → memberDetail 페이지 이동 */
function goToDetail(event, memberId) {
  event.stopPropagation();
  location.href = contextPath + '/admin/member/detail/' + memberId;
}

function showReason(event, reason) {
  event.stopPropagation();
  alert('처리 사유\n\n' + (reason || '기록된 사유가 없습니다.'));
}

function closeInfoModal() { document.getElementById('infoModal').style.display = 'none'; }

window.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) {
    closeBulkStatusModal();
    document.getElementById('infoModal').style.display   = 'none';
    document.getElementById('detailModal').style.display = 'none';
  }
});
