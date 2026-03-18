function openRoomModal() {
  document.getElementById('roomModal').style.display = 'flex';
}

function closeRoomModal() {
  document.getElementById('roomModal').style.display = 'none';
}

function saveRoom() {
    const roomData = {  };

    fetch(TripanConfig.contextPath + '/partner/api/room/save', {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json',
            'AJAX': 'true'
        },
        body: JSON.stringify(roomData)
    })
    .then(res => {
        if (res.status === 401) {
            showToast('세션이 만료되었습니다. 로그인 페이지로 이동합니다.', 'error');
            setTimeout(() => { location.href = TripanConfig.contextPath + '/partner/login'; }, 1500);
            throw new Error('Session Expired');
        }
        return res.json();
    })
    .then(data => {
        if (data.message === 'success') {
            showToast('🎉 새 객실이 성공적으로 등록되었습니다!', 'success');
            closeRoomModal();
            setTimeout(() => { location.reload(); }, 1000); 
        } else {
            showToast('객실 등록에 실패했습니다.', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('서버와의 통신에 문제가 발생했습니다.', 'error');
    });
}