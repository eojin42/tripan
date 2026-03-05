/**
 * workspace.vote.js
 * 투표
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */


function castVote(btn) {
  btn.classList.add('voted');
  btn.textContent = '✓ 투표 완료!';
  showToast('🗳️ 투표했어요!');
}

