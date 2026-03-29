/**
 * 🌟 공용 페이징 UI 생성기
 * * @param {number} totalPages  - 전체 페이지 수 
 * @param {number} currentPage - 현재 페이지 번호 
 * @param {string} containerId - 페이징 버튼들이 들어갈 HTML <div>의 id
 * @param {function} callback  - 페이지 번호를 클릭했을 때 실행할 함수
 */
function renderPagination(totalPages, currentPage, containerId, callback) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    container.innerHTML = '';

    if (totalPages <= 0) return;

    const blockSize = 5; 
    
    let startPage = Math.floor((currentPage - 1) / blockSize) * blockSize + 1;
    let endPage = Math.min(startPage + blockSize - 1, totalPages);

    const wrap = document.createElement('div');
    wrap.style.cssText = 'display:flex; gap:8px; justify-content:center; margin-top:24px; margin-bottom: 24px;';

    const createBtn = (text, page, isActive = false) => {
        const btn = document.createElement('button');
        btn.innerHTML = text;
        
        btn.style.cssText = isActive 
            ? 'background:#6366F1; color:white; border:none; min-width:32px; height:32px; border-radius:8px; font-weight:800; cursor:pointer; transition:0.2s;'
            : 'background:#fff; color:#64748B; border:1px solid #CBD5E1; min-width:32px; height:32px; border-radius:8px; font-weight:600; cursor:pointer; transition:0.2s;';
            
        if(!isActive) {
            btn.onmouseover = () => { btn.style.background = '#F1F5F9'; btn.style.color = '#0F172A'; };
            btn.onmouseout = () => { btn.style.background = '#fff'; btn.style.color = '#64748B'; };
        }

        btn.onclick = () => callback(page);
        return btn;
    };

    if (currentPage > 1) {
        wrap.appendChild(createBtn('≪', 1));
    }

    if (startPage > 1) {
        wrap.appendChild(createBtn('◀', startPage - 1));
    }

    for (let i = startPage; i <= endPage; i++) {
        wrap.appendChild(createBtn(i, i, i === currentPage));
    }

    if (endPage < totalPages) {
        wrap.appendChild(createBtn('▶', endPage + 1));
    }

    if (currentPage < totalPages) {
        wrap.appendChild(createBtn('≫', totalPages));
    }

    container.appendChild(wrap);
}