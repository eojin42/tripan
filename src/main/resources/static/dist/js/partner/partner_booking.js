/**
 * 예약 관리 전용 스크립트
 */

let currentCancelReservationId = null;

function openCancelModal(reservationId) {
    currentCancelReservationId = reservationId; // 💡 클릭한 예약번호 저장
    document.getElementById('cancelModal').classList.add('open');
}

function closeCancelModal() {
    currentCancelReservationId = null; // 초기화
    document.getElementById('cancelModal').classList.remove('open');
    document.getElementById('cancelReason').value = '';
}

function submitCancel() {
    const reason = document.getElementById('cancelReason').value;
    
    if (!reason.trim()) { 
        alert("고객에게 안내될 취소 사유를 반드시 입력해주세요!"); 
        return; 
    }
    
    if(!confirm("정말 이 예약을 강제 취소하시겠습니까?\n고객에게 100% 전액 환불됩니다.")) {
        return;
    }

    fetch(TripanConfig.contextPath + '/partner/api/booking/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            reservationId: currentCancelReservationId, 
            reason: reason 
        })
    })
    .then(res => res.json())
    .then(data => {
        if(data.message === 'success') {
            alert("예약이 성공적으로 취소되었으며, 결제 대금이 환불 처리되었습니다.");
            location.reload(); 
        } else {
            alert("취소 실패: " + data.message);
        }
    })
    .catch(err => {
        console.error(err);
        alert("서버 통신 중 에러가 발생했습니다.");
    });
}

function openBookingDetail(btnElement) {
    const id = btnElement.getAttribute('data-id');
    const name = btnElement.getAttribute('data-name');
    const phone = btnElement.getAttribute('data-phone');
    const room = btnElement.getAttribute('data-room');
    const date = btnElement.getAttribute('data-date');
    const amount = btnElement.getAttribute('data-amount');
    const status = btnElement.getAttribute('data-status');
    const fullRequest = btnElement.getAttribute('data-request') || '요청사항 없음';

    currentCancelReservationId = id;
    
    document.getElementById('dtlResId').innerText = "RES-" + id;
    document.getElementById('dtlName').innerText = name;
    document.getElementById('dtlPhone').innerText = phone;
    document.getElementById('dtlRoom').innerText = room;
    document.getElementById('dtlDate').innerText = date;
    document.getElementById('dtlAmount').innerText = Number(amount).toLocaleString();
    document.getElementById('dtlStatus').innerText = (status === 'SUCCESS') ? '예약 확정' : '취소됨';
    
    let normalRequest = fullRequest;
    let cancelReasonText = "고객이 직접 취소한 예약입니다."; // 기본값 (고객 취소)

    if (status === 'CANCELED') {
        document.getElementById('cancelActionArea').style.display = 'none'; // 취소 폼 숨기기
        document.getElementById('dtlStatus').style.color = 'red';
        
        if (fullRequest.includes('[강제취소]')) {
            const parts = fullRequest.split('[강제취소]');
            normalRequest = parts[0].trim() || '요청사항 없음';
            cancelReasonText = "파트너 강제 취소 ➡️ " + parts[1].trim(); // 사장님이 남긴 로그
        }

        document.getElementById('cancelLogArea').style.display = 'block'; 
        document.getElementById('dtlCancelReason').innerText = cancelReasonText;
    } else {
        document.getElementById('cancelActionArea').style.display = 'block';
        document.getElementById('cancelLogArea').style.display = 'none';
        document.getElementById('dtlStatus').style.color = 'green';
    }

    document.getElementById('dtlRequest').innerText = normalRequest;

    document.getElementById('bookingDetailModal').style.display = 'flex';
}