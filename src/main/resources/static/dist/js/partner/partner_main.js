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

// 파트너 정보 저장 함수
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
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resData => {
        if(resData.message === 'success') {
            alert('성공적으로 저장되었습니다! 🎉');
        } else {
            alert('저장에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('서버 오류가 발생했습니다.');
    });
}