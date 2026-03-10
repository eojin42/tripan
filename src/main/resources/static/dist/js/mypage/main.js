// 유틸 함수
function formatDate(v) {
  if (!v) return '';
  return new Date(v).toLocaleDateString('ko-KR', { year: '2-digit', month: '2-digit', day: '2-digit' });
}

function escHtml(s) {
  if (!s) return '';
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// 모달 제어 함수
function closeModal(id) {
  document.getElementById(id).classList.remove('active');
  document.body.style.overflow = 'auto';
}

function closeModalByOverlay(id, e) {
  if (e.target === document.getElementById(id)) {
    closeModal(id);
  }
}

// 배지 SVG 아이콘 매핑
const BADGE_SVGS = {
  'default':    '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>',
  'explorer':   '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>',
  'photo':      '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>',
  'food':       '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/></svg>',
  'mountain':   '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M8 3l4 8 5-5 5 15H2L8 3z"/></svg>',
  'map':        '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>',
  'star':       '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>',
  'heart':      '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>',
  'sun':        '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>'
};

function getBadgeSvg(b) {
  if (b.badgeImageUrl) {
    return `<img src="${escHtml(b.badgeImageUrl)}" alt="" class="badge-icon">`;
  }
  const key = (b.badgeType || b.badgeCategory || '').toLowerCase();
  if (BADGE_SVGS[key]) return BADGE_SVGS[key];
  
  const name = (b.badgeName || '');
  if (name.includes('탐험') || name.includes('바다')) return BADGE_SVGS['explorer'];
  if (name.includes('포토') || name.includes('사진')) return BADGE_SVGS['photo'];
  if (name.includes('맛집') || name.includes('음식')) return BADGE_SVGS['food'];
  if (name.includes('산') || name.includes('등산')) return BADGE_SVGS['mountain'];
  if (name.includes('지도') || name.includes('정복')) return BADGE_SVGS['map'];
  if (name.includes('별') || name.includes('스타')) return BADGE_SVGS['star'];
  return BADGE_SVGS['default'];
}

// 데이터 로드 함수 (요약 통계, 다가오는 여행)
async function loadSummary() {
  try {
    const res = await fetch('/mypage/api/summary');
    if (!res.ok) throw new Error();
    const data = await res.json();

    // 1. 통계 카드 업데이트
    document.getElementById('val-trips').textContent   = data.totalTripCount ?? 0;
    document.getElementById('val-regions').textContent = data.visitedRegionCount ?? 0;
    document.getElementById('val-history').textContent = data.completedTripCount ?? 0;
    
    document.getElementById('val-avgdays').textContent = data.avgTripDays != null 
      ? (Number.isInteger(data.avgTripDays) ? data.avgTripDays : data.avgTripDays.toFixed(1)) + '일' 
      : '0일';

    // 사이드바 통계 업데이트
    if (data.member) {
      document.getElementById('stat-follower').textContent  = data.member.followerCount ?? 0;
      document.getElementById('stat-following').textContent = data.member.followingCount ?? 0;
      document.getElementById('stat-badge').textContent     = data.member.badgeCount ?? 0;
      
      const initEl = document.getElementById('avatar-initial');
      if (initEl && data.member.nickname) {
        initEl.textContent = data.member.nickname.charAt(0);
      }
    }

    // 다가오는 여행 배너 렌더링
    renderUpcoming(data);

  } catch (e) {
    // API 실패 시 기본값(0)으로 초기화
    ['val-trips', 'val-regions', 'val-avgdays', 'val-history'].forEach(id => {
      document.getElementById(id).textContent = '0';
    });
    ['stat-follower', 'stat-following', 'stat-badge'].forEach(id => {
      document.getElementById(id).textContent = '0';
    });
    renderUpcoming(null);
  }
}

// 다가오는 여행 배너 렌더링
function renderUpcoming(data) {
  const area = document.getElementById('upcoming-area');
  const trip = data?.upcomingTrip;

  if (trip) {
    const dday = Math.ceil((new Date(trip.startDate) - new Date()) / 86400000);
    area.innerHTML = `
      <div class="upcoming-banner" onclick="location.href='/mypage/schedule'">
        <i class="bi bi-airplane-fill"></i>
        <div class="up-info">
          <div class="up-lbl">✈️ 다가오는 여행</div>
          <div class="up-name">${escHtml(trip.tripName)}</div>
          <div class="up-date">
            <i class="bi bi-calendar3" style="font-size:11px"></i> 
            ${escHtml(formatDate(trip.startDate))} ~ ${escHtml(formatDate(trip.endDate))}
            ${trip.regionName ? ` · ${escHtml(trip.regionName)}` : ''}
          </div>
        </div>
        <div class="up-dday">D-${dday}</div>
      </div>
    `;
  } else {
    area.innerHTML = `
      <div class="upcoming-none">
        <div class="upcoming-none-icon"><i class="bi bi-calendar3"></i></div>
        <div class="upcoming-none-text">
          <h4>다가오는 여행</h4>
          <p>일주일 내 예정된 여행이 없어요</p>
        </div>
      </div>
    `;
  }
}

// 내 채팅 내역 로드
function loadMyChatList() {
  const url = typeof TripanConfig !== 'undefined' 
    ? `${TripanConfig.apiBaseUrl}/chat/rooms/private` 
    : '/api/chat/rooms/private'; // Fallback path

  fetch(url)
    .then(res => {
      if (!res.ok) throw new Error("채팅 목록을 불러오지 못했습니다.");
      return res.json();
    })
    .then(rooms => {
      const listEl = document.getElementById('mypageChatList');
      if (!rooms || rooms.length === 0) {
        listEl.innerHTML = '<p style="text-align:center; color:var(--text-gray); font-size:12px; margin:0;">진행 중인 1:1 대화가 없습니다.</p>';
        return;
      }
      
      listEl.innerHTML = rooms.slice(0, 3).map(room => `
        <div class="mypage-chat-item" onclick="if(window.forceOpenChat) forceOpenChat('${room.chatRoomId}', 'PRIVATE')">
          <div class="mypage-chat-icon">👤</div>
          <div style="flex:1; overflow:hidden;">
            <div style="font-size:13px; font-weight:800; color:var(--text-black); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${escHtml(room.chatRoomName)}</div>
            <div style="font-size:11px; color:var(--text-gray); margin-top:2px;">최근 대화 확인하기</div>
          </div>
          <i class="bi bi-chevron-right" style="color:var(--text-gray); font-size:12px;"></i>
        </div>
      `).join('');
    })
    .catch(err => {
      document.getElementById('mypageChatList').innerHTML = '<p style="text-align:center; color:var(--text-gray); font-size:12px; margin:0;">목록을 불러오지 못했습니다.</p>';
    });
}

// 미니 지도 로드
async function loadMiniMap() {
  try {
    const res = await fetch('/mypage/api/visited-regions');
    if (!res.ok) return;
    const list = await res.json();

    // 방문 지역 색칠
    list.forEach(r => {
      document.querySelectorAll(`[data-sido="${r.sidoName}"]`).forEach(el => {
        el.classList.add('visited');
      });
    });

    // 통계 업데이트 (전체 17개 시/도 기준)
    const cnt = list.length;
    document.getElementById('mini-visited-cnt').textContent = cnt;
    document.getElementById('mini-progress').style.width = Math.round((cnt / 17) * 100) + '%';

    // 방문 태그 생성 (최대 5개 표시)
    let tags = list.slice(0, 5).map(r => {
      const shortName = r.sidoName.replace(/특별자치도|광역시|특별시|특별자치시/g, '');
      return `<span class="mini-visited-tag">${escHtml(shortName)}</span>`;
    }).join('');
    
    if (list.length > 5) {
      tags += `<span class="mini-visited-tag">+${list.length - 5}</span>`;
    }
    
    document.getElementById('mini-visited-tags').innerHTML = tags || '<span style="font-size:12px;color:var(--text-gray);">아직 방문 기록이 없어요</span>';

  } catch (e) {
    console.error("미니 지도 로드 실패:", e);
  }
}

// 모달: 팔로워/팔로잉
async function openFollowModal(type) {
  const modal = document.getElementById('followModal');
  const title = document.getElementById('follow-modal-title');
  const body  = document.getElementById('follow-modal-body');

  title.textContent = type === 'follower' ? '팔로워' : '팔로잉';
  body.innerHTML = '<div class="modal-loading"><div class="spin"></div>불러오는 중...</div>';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  try {
    const url = type === 'follower' ? '/mypage/api/followers' : '/mypage/api/following';
    const res = await fetch(url);
    if (!res.ok) throw new Error();
    const list = await res.json();

    if (!list || list.length === 0) {
      body.innerHTML = `<div class="modal-empty"><i class="bi bi-people"></i><p>${type === 'follower' ? '팔로워가' : '팔로잉이'} 없어요</p></div>`;
      return;
    }

    body.innerHTML = '<div class="user-list">' + list.map(u => `
      <div class="user-item">
        <div class="user-pic">
          ${u.profileImage ? `<img src="${escHtml(u.profileImage)}" alt="">` : escHtml((u.nickname || '?').charAt(0))}
        </div>
        <div>
          <div class="user-name">${escHtml(u.nickname || '')}</div>
          <div class="user-id">@${escHtml(u.loginId || '')}</div>
        </div>
        ${u.followingBack ? '<span style="margin-left:auto;font-size:10px;font-weight:800;color:var(--sky-blue);background:rgba(137,207,240,.15);padding:2px 8px;border-radius:20px;">맞팔</span>' : ''}
      </div>
    `).join('') + '</div>';

  } catch (e) {
    body.innerHTML = '<div class="modal-empty"><i class="bi bi-exclamation-circle"></i><p>불러오기에 실패했어요</p></div>';
  }
}

// 모달: 배지
async function openBadgeModal() {
  const modal = document.getElementById('badgeModal');
  const body  = document.getElementById('badge-modal-body');

  body.innerHTML = '<div class="modal-loading"><div class="spin"></div>불러오는 중...</div>';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  try {
    const res = await fetch('/mypage/api/badges');
    if (!res.ok) throw new Error();
    const list = await res.json();
    const earned = list.filter(b => b.earned);

    if (!earned.length) {
      body.innerHTML = '<div class="modal-empty"><i class="bi bi-award"></i><p>아직 획득한 배지가 없어요</p></div>';
      return;
    }

    body.innerHTML = '<div class="badge-grid">' + earned.map(b => `
      <div class="badge-item ${b.equipped ? 'active' : ''}" onclick="equipBadge(${b.badgeId}, this)">
        ${getBadgeSvg(b)}
        <span class="badge-name">${escHtml(b.badgeName)}</span>
      </div>
    `).join('') + '</div>';

  } catch (e) {
    body.innerHTML = '<div class="modal-empty"><i class="bi bi-exclamation-circle"></i><p>불러오기에 실패했어요</p></div>';
  }
}

async function equipBadge(badgeId, el) {
  try {
    const res = await fetch(`/mypage/api/badges/${badgeId}/equip`, { method: 'PUT' });
    if (!res.ok) throw new Error();
    
    document.querySelectorAll('.badge-item').forEach(item => item.classList.remove('active'));
    el.classList.add('active');
  } catch (e) {
    alert('배지 장착에 실패했어요');
  }
}

// 초기 로딩 설정
document.addEventListener('DOMContentLoaded', () => {
  loadSummary();
  loadMiniMap();
  loadMyChatList();
});