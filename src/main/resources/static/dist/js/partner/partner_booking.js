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

function openBookingDetail(id, name, phone, room, date, amount, status) {
	
	currentCancelReservationId = id;
	
    document.getElementById('dtlResId').innerText = "RES-" + id;
    document.getElementById('dtlName').innerText = name;
    document.getElementById('dtlPhone').innerText = phone;
    document.getElementById('dtlRoom').innerText = room;
    document.getElementById('dtlDate').innerText = date;
    document.getElementById('dtlAmount').innerText = Number(amount).toLocaleString();
    document.getElementById('dtlStatus').innerText = (status === 'SUCCESS') ? '예약 확정' : '취소됨';
    
    if (status === 'CANCELED') {
        document.getElementById('cancelActionArea').style.display = 'none';
        document.getElementById('dtlStatus').style.color = 'red';
    } else {
        document.getElementById('cancelActionArea').style.display = 'block';
        document.getElementById('dtlStatus').style.color = 'green';
    }

    document.getElementById('bookingDetailModal').style.display = 'flex';
}