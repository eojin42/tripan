/**
 * 파트너 센터 메인 (대시보드) 통합 스크립트
 */

const SIDEBAR_KEY = 'partnerSidebarCollapsed'; //

function toggleSidebar() { //
    const layout = document.querySelector('.admin-layout');
    if (!layout) return;
    
    const isCollapsed = layout.classList.toggle('collapsed');
    localStorage.setItem(SIDEBAR_KEY, isCollapsed);
}

document.addEventListener('DOMContentLoaded', () => {
    
    const layout = document.querySelector('.admin-layout');
    const sidebar = document.querySelector('.sidebar');

    if (localStorage.getItem(SIDEBAR_KEY) === 'true' && layout) {
        if (sidebar) sidebar.style.transition = 'none';
        
        layout.classList.add('collapsed');
        
        setTimeout(() => {
            if (sidebar) sidebar.style.transition = 'width 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
        }, 50);
    }

    const menuItems = document.querySelectorAll('.sidebar .menu-item');
    menuItems.forEach(item => {
        item.addEventListener('click', () => {
            localStorage.setItem(SIDEBAR_KEY, 'false');
            if (layout) layout.classList.remove('collapsed');
        });
    });

    const chartCanvas = document.getElementById('mainDashboardChart'); //
    if (chartCanvas) {
        Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
        
        new Chart(chartCanvas.getContext('2d'), {
            type: 'line',
            data: {
                labels: ['월', '화', '수', '목', '금', '토', '일'],
                datasets: [{
                    label: '예약 건수',
                    data: [12, 19, 3, 5, 2, 3, 7], // TODO: 나중에 실데이터 연동 필요
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
                plugins: { legend: { display: false } }
            }
        });
    }
});

function openCouponModal() {
    document.getElementById('couponModal').classList.add('open');
}

function closeCouponModal() {
    document.getElementById('couponModal').classList.remove('open');
}

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
    });
}

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


function saveFacilityInfo() {
    const data = {
        checkintime: document.getElementById('checkintime').value,
        checkouttime: document.getElementById('checkouttime').value,
        parkinglodging: document.getElementById('parkinglodging').value,
        
        fitness: document.getElementById('fitness').checked ? 1 : 0,
        chkcooking: document.getElementById('chkcooking').checked ? 1 : 0,
        barbecue: document.getElementById('barbecue').checked ? 1 : 0,
        sauna: document.getElementById('sauna').checked ? 1 : 0,
        karaoke: document.getElementById('karaoke').checked ? 1 : 0,
        publicpc: document.getElementById('publicpc').checked ? 1 : 0
    };

    fetch(TripanConfig.contextPath + '/partner/api/facility/update', {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json',
            'AJAX': 'true' 
        },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resData => {
        if(resData.message === 'success') {
            showToast('공통 시설 설정이 저장되었습니다! 🎉', 'success');
        } else {
            showToast('저장에 실패했습니다.', 'error');
        }
    })
    .catch(error => console.error('Error:', error));
}