/**
 * 파트너 센터 메인 (대시보드) 전용 스크립트
 */

document.addEventListener('DOMContentLoaded', () => {
    
    const chartCanvas = document.getElementById('mainDashboardChart');
    
    if (chartCanvas) {
        Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
        
        new Chart(chartCanvas.getContext('2d'), {
            type: 'line',
            data: {
                labels: ['월', '화', '수', '목', '금', '토', '일'],
                datasets: [{
                    label: '예약 건수',
                    data: [12, 19, 3, 5, 2, 3, 7], // TODO: 나중에 DB 데이터로 교체
                    borderColor: '#3B6EF8',
                    backgroundColor: 'rgba(59,110,248,0.1)',
                    fill: true,
                    tension: 0.4,
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { 
                    legend: { display: false } 
                }
            }
        });
    }

});

// 쿠폰 발행 모달 스크립트
function openCouponModal() {
    document.getElementById('couponModal').classList.add('open');
}

function closeCouponModal() {
    document.getElementById('couponModal').classList.remove('open');
}

// 파트너 정보 저장 함수 (partner_main.js)
function savePartnerInfo() {
    const data = {
        contactName: document.getElementById('contactName').value,
        contactPhone: document.getElementById('contactPhone').value,
        bankName: document.getElementById('bankName').value,
        accountNumber: document.getElementById('accountNumber').value,
        partnerIntro: document.getElementById('partnerIntro').value
    };

    fetch(TripanConfig.contextPath + '/partner/api/info/update', {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json',
            'AJAX': 'true' 
        },
        body: JSON.stringify(data)
    })
    .then(res => {
        if (res.status === 401) {
            showToast('세션이 만료되었습니다. 로그인 페이지로 이동합니다.', 'error');
            setTimeout(() => { location.href = TripanConfig.contextPath + '/partner/login'; }, 1500);
            throw new Error('Session Expired');
        }
        return res.json();
    })
    .then(resData => {
        if(resData.message === 'success') {
            showToast('성공적으로 저장되었습니다! 🎉', 'success');
        } else {
            showToast('저장에 실패했습니다.', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        // showToast('서버 오류가 발생했습니다.', 'error');
    });
}


// 🌟 토스트 알림 띄워주는 공통 함수
function showToast(message, type = 'success') {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast-msg ${type}`;
    toast.innerText = message;
    container.appendChild(toast);

    setTimeout(() => toast.classList.add('show'), 10);

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300); 
    }, 3000);
}