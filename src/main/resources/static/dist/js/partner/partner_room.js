function openRoomModal() {
  document.getElementById('roomModal').style.display = 'flex';
}

function closeRoomModal() {
  document.getElementById('roomModal').style.display = 'none';
  document.getElementById('roomForm').reset(); // 닫을 때 폼 초기화
}

function saveRoom() {
    const formData = new FormData();
    
    formData.append('roomName', document.getElementById('roomName').value);
    formData.append('roombasecount', document.getElementById('roombasecount').value);
    formData.append('maxCapacity', document.getElementById('maxCapacity').value);
    formData.append('roomCount', document.getElementById('roomCount').value);
    formData.append('amount', document.getElementById('amount').value);
    formData.append('roomintro', document.getElementById('roomintro').value);

    const isActive = document.querySelector('input[name="isActive"]:checked');
    if(isActive) formData.append('isActive', isActive.value);

    document.querySelectorAll('input[name="facility"]').forEach(checkbox => {
        formData.append(checkbox.value, checkbox.checked ? "1" : "0"); 
    });

    const fileInput = document.getElementById('roomImages');
    const maxFiles = 5;

    if (fileInput.files.length === 0) {
        showToast('최소 1장 이상의 객실 사진을 등록해주세요!', 'error');
        return; 
    }
    
    if (fileInput.files.length > maxFiles) {
        showToast(`객실 사진은 최대 ${maxFiles}장까지만 등록할 수 있습니다.`, 'error');
        return; 
    }
    
    for (let i = 0; i < fileInput.files.length; i++) {
        formData.append('images', fileInput.files[i]); 
    }

    fetch(TripanConfig.contextPath + '/partner/api/room/save', {
        method: 'POST',
        headers: { 
            'AJAX': 'true' 
        },
        body: formData 
    })
    .then(res => {
        if (res.status === 401) {
            showToast('세션이 만료되었습니다. 로그인 페이지로 이동합니다.', 'error');
            setTimeout(() => { location.href = TripanConfig.contextPath + '/member/login'; }, 1500);
            throw new Error('Session Expired');
        }
        return res.json();
    })
    .then(data => {
        if (data.message === 'success') {
            showToast('🎉 새 객실과 사진이 성공적으로 등록되었습니다!', 'success');
            closeRoomModal();
            setTimeout(() => { location.reload(); }, 1000); 
        } else {
            showToast('객실 등록에 실패했습니다. 다시 시도해주세요.', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}
