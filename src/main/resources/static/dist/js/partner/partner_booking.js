/**
 * 예약 관리 전용 스크립트 (강제 취소 등)
 */

// 1. 강제 취소 모달 열기
function openCancelModal(reservationId) {
    console.log("취소 대상 예약번호:", reservationId);
    document.getElementById('cancelModal').classList.add('open');
}

// 2. 강제 취소 모달 닫기
function closeCancelModal() {
    document.getElementById('cancelModal').classList.remove('open');
    // 닫을 때 입력했던 텍스트 초기화
    document.getElementById('cancelReason').value = '';
}

// 3. 취소 사유 제출 및 확정
function submitCancel() {
    const reason = document.getElementById('cancelReason').value;
    
    if (!reason.trim()) { 
        alert("취소 사유를 반드시 입력해주세요!"); 
        return; 
    }
    
    /* 🌟 나중에 백엔드와 연결할 때 쓸 AJAX 코드 미리 적어둡니다!
    fetch(TripanConfig.contextPath + '/partner/booking/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: reason })
    }).then(res => res.json())
      .then(data => { ...처리... });
    */

    alert("취소 사유가 등록되며 예약이 강제 취소되었습니다.\n사유: " + reason);
    closeCancelModal();
}