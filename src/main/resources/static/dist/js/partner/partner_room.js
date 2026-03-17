function openRoomModal() {
  document.getElementById('roomModal').style.display = 'flex';
}

function closeRoomModal() {
  document.getElementById('roomModal').style.display = 'none';
}

function saveRoom() {
    const roomData = {
        roomName: document.querySelector('input[placeholder="예: 오션뷰 스위트룸"]').value,
        roombasecount: document.querySelectorAll('input[type="number"]')[0].value,
        maxCapacity: document.querySelectorAll('input[type="number"]')[1].value,
        roomCount: document.querySelectorAll('input[type="number"]')[2].value,
        amount: document.querySelector('input[placeholder="예: 150000"]').value,
        roomintro: document.querySelector('textarea').value
    };

	    fetch(TripanConfig.contextPath + '/partner/api/room/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(roomData)
    })
    .then(res => res.json())
    .then(data => {
        if (data.message === 'success') {
            alert('🎉 새 객실이 성공적으로 등록되었습니다!');
            closeRoomModal();
            location.reload(); 
        } else {
            alert('객실 등록에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('서버와의 통신에 문제가 발생했습니다.');
    });
}