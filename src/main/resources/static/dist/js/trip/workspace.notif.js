/**
 * workspace.notif.js
 * 알림 드롭다운 · 초대 수락/거절 · 초대링크
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */


function toggleNotif() {
  var dd = document.getElementById('notifDropdown');
  var dim = document.getElementById('notifDim');
  var isOpen = dd.classList.contains('open');
  if (isOpen) {
    dd.classList.remove('open');
    dim.classList.remove('open');
  } else {
    dd.classList.add('open');
    dim.classList.add('open');
  }
}
function closeNotif() {
  document.getElementById('notifDropdown').classList.remove('open');
  document.getElementById('notifDim').classList.remove('open');
}
function clearAllNotif() {
  document.querySelectorAll('.notif-item.unread').forEach(function(el){ el.classList.remove('unread'); });
  document.querySelectorAll('.notif-item-unread-dot').forEach(function(el){ el.style.display='none'; });
  document.getElementById('notifDot').style.display = 'none';
  showToast('✅ 알림을 모두 읽었어요');
}
/* [DB] trip_member.invitation_status → ACCEPTED 로 UPDATE */
function acceptInvite(itemId) {
  var actions = document.getElementById(itemId + '-actions');
  if (actions) {
    actions.innerHTML = '<span style="font-size:12px;font-weight:700;color:#276749;">✓ 수락 완료</span>';
  }
  var item = document.getElementById(itemId);
  if (item) item.classList.remove('unread');
  showToast('✅ 초대를 수락했어요!');
  closeNotif();
}
/* [DB] trip_member 레코드 DELETE */
function declineInvite(itemId) {
  var item = document.getElementById(itemId);
  if (item) {
    item.style.transition = 'opacity .3s';
    item.style.opacity = '0';
    setTimeout(function(){ item.remove(); }, 300);
  }
  showToast('🚫 초대를 거절했어요');
  closeNotif();
}

