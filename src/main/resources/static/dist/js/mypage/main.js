// 유틸 및 공통 기능
function formatDate(v) {
  return v ? new Date(v).toLocaleDateString('ko-KR', { year: '2-digit', month: '2-digit', day: '2-digit' }) : '';
}

function escHtml(s) {
  return s ? String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;') : '';
}

// 마이페이지 데이터 로드
async function loadSummary() {
  try {
    const res = await fetch('/mypage/api/summary'); 
    
    if (!res.ok) {
        console.error("서버에서 요약 데이터를 주지 않습니다.");
        return;
    }
    
    const data = await res.json();
    
    // 데이터 바인딩
    const elTrips = document.getElementById('val-trips');
    if(elTrips) elTrips.textContent = data.totalTripCount ?? 0;
    
    const elRegions = document.getElementById('val-regions');
    if(elRegions) elRegions.textContent = data.visitedRegionCount ?? 0;
    
    const elHistory = document.getElementById('val-history');
    if(elHistory) elHistory.textContent = data.completedTripCount ?? 0;
    
    // 회원 통계 바인딩
    if (data.member) {
      const elFollower = document.getElementById('stat-follower');
      if(elFollower) elFollower.textContent = data.member.followerCount ?? 0;
      
      const elFollowing = document.getElementById('stat-following');
      if(elFollowing) elFollowing.textContent = data.member.followingCount ?? 0;
      
      const elBadge = document.getElementById('stat-badge');
      if(elBadge) elBadge.textContent = data.member.badgeCount ?? 0;
    }
  } catch (e) { 
      console.error("데이터 로드 에러:", e); 
  }
}

async function loadMiniMap() {
  try {
    const res = await fetch('/mypage/api/visited-regions'); 
    
    if (!res.ok) return;
    
    const list = await res.json();
    
    // 지도 색칠
    list.forEach(r => {
        document.querySelectorAll(`[data-sido="${r.sidoName}"]`).forEach(el => el.classList.add('visited'));
    });
    
    // 카운트 업데이트
    const cntEl = document.getElementById('mini-visited-cnt');
    if(cntEl) cntEl.textContent = list.length;
    
    const progEl = document.getElementById('mini-progress');
    if(progEl) progEl.style.width = Math.round((list.length / 17) * 100) + '%';
    
  } catch (e) { 
      console.error("지도 로드 에러:", e); 
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadSummary();
  loadMiniMap();
});