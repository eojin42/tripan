// 🌟 토글 스위치 클릭 시 글자와 색상이 변하는 감성 UI 로직
function updateToggleUI() {
    const isActive = document.getElementById('isActive').checked;
    const statusText = document.getElementById('activeStatusText');
    
    if (isActive) {
        statusText.innerText = '온라인 (노출 중) 🟢';
        statusText.style.color = '#4A44F2';
    } else {
        statusText.innerText = '오프라인 (숨김) ⚪';
        statusText.style.color = '#A0AEC0';
    }
}

// 🌟 체크박스 토글
function toggleOtherInput() {
    const checkBox = document.getElementById('hasOtherFacility');
    const inputField = document.getElementById('otherFacilityName');
    
    if (checkBox.checked) {
        inputField.style.display = 'block'; 
        inputField.focus();
    } else {
        inputField.style.display = 'none';
        inputField.value = ''; 
    }
}

// 🌟 에러 해결 및 AJAX 저장 로직
function saveFacilityInfo() {
    // 혹시 모를 null 에러 방지를 위해 요소가 있는지 한 번 더 확인하는 방어 코드 추가!
    const checkinEl = document.getElementById('checkinTime');
    const checkoutEl = document.getElementById('checkoutTime');
    const parkingEl = document.getElementById('parkinglodging');
    
    if (!checkinEl || !checkoutEl) {
        alert("시스템 오류: 입력 필드를 찾을 수 없습니다.");
        return;
    }

    const requestData = {
        placeId: document.getElementById('placeId').value,
        isActive: document.getElementById('isActive').checked ? 1 : 0, 
        
        checkinTime: checkinEl.value,
        checkoutTime: checkoutEl.value,
        parkinglodging: parkingEl.value,
        
        fitness: document.getElementById('fitness').checked ? 1 : 0,
        chkcooking: document.getElementById('chkcooking').checked ? 1 : 0,
        barbecue: document.getElementById('barbecue').checked ? 1 : 0,
        beverage: document.getElementById('beverage').checked ? 1 : 0,
        karaoke: document.getElementById('karaoke').checked ? 1 : 0,
        publicpc: document.getElementById('publicpc').checked ? 1 : 0,
        sauna: document.getElementById('sauna').checked ? 1 : 0,
        otherFacility: document.getElementById('hasOtherFacility').checked ? document.getElementById('otherFacilityName').value.trim() : ""
    };

    fetch('/api/partner/accommodation/facility', { 
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json',
            'AJAX': 'true' 
        },
        body: JSON.stringify(requestData)
    })
    .then(res => res.json())
    .then(data => {
        if(data.success) {
            alert('숙소 설정이 성공적으로 저장되었습니다. 🎉');
        } else {
            alert('저장에 실패했습니다: ' + data.message);
        }
    })
    .catch(err => {
        console.error(err);
        alert('서버 통신 중 오류가 발생했습니다.');
    });
}