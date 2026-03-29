<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
    .settle-header-container { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    .settle-title { font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; margin: 0; }
    .settle-subtitle { color: var(--text-gray); margin-top: 8px; font-weight: 500; margin-bottom: 0; }
    .table-card { padding: 0; overflow: hidden; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }

    .btn-excel { padding: 10px 16px; font-weight: 700; border-radius: 10px; border: 1px solid #CBD5E1; color: #475569; background: white; cursor: pointer; transition: background 0.2s; }
    .btn-excel:hover { background: #F8FAFC; }
    .btn-detail { padding: 4px 12px; font-size: 12px; font-weight: 700; border-radius: 6px; border: 1px solid #E2E8F0; background: white; color: #64748B; cursor: pointer; transition: background 0.2s; }
    .btn-detail:hover { background: #F8FAFC; }

    .settle-kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
    .settle-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); position: relative; overflow: hidden; }
    .settle-card.highlight { background: #0F172A; border-color: #0F172A; }
    .settle-label { font-size: 13px; font-weight: 700; color: #64748B; margin-bottom: 8px; }
    .settle-card.highlight .settle-label { color: #94A3B8; }
    .settle-value { font-size: 28px; font-weight: 900; color: #1E293B; font-family: 'Sora', sans-serif; }
    .settle-card.highlight .settle-value { color: #10B981; }
    .math-sign { position: absolute; right: -10px; top: 50%; transform: translateY(-50%); font-size: 40px; font-weight: 900; color: #F1F5F9; z-index: 0; }
    .settle-note { font-size: 11px; color: #64748B; margin-top: 6px; font-weight: 500; }

    .settle-filter-card { padding: 24px 32px; border-radius: 16px; margin-bottom: 24px; background: #F8FAFC; border: 1px solid #E2E8F0; }
    .settle-filter-form { display: flex; gap: 32px; align-items: center; flex-wrap: wrap; margin: 0; }
    .filter-input { padding: 12px 20px; border: 1px solid #CBD5E1; border-radius: 10px; font-size: 14px; color: #334155; background: white; font-family: inherit; font-weight: 600; min-width: 160px; }
    .filter-input:focus { outline: none; border-color: #0F172A; box-shadow: 0 0 0 3px rgba(15, 23, 42, 0.05); }
    .btn-search { padding: 12px 32px; background: #1E293B; color: white; border: none; border-radius: 10px; font-size: 14px; font-weight: 800; cursor: pointer; transition: background 0.2s; }
    .btn-search:hover { background: #0F172A; }
    .btn-reset { padding: 12px 24px; background: white; color: #64748B; border: 1px solid #CBD5E1; border-radius: 10px; font-weight: 700; text-decoration: none; font-size: 14px; display: inline-flex; align-items: center; justify-content: center; }
    .btn-reset:hover { background: #F1F5F9; color: #334155; }
    .filter-group { display: flex; align-items: center; gap: 12px; }
    .filter-label { font-size: 14px; font-weight: 800; color: #334155; }

    .settle-table { width: 100%; border-collapse: collapse; }
    .settle-table th { padding: 16px; font-size: 13px; color: #64748B; font-weight: 700; background: #F8FAFC; border-bottom: 1px solid #E2E8F0; text-align: right; }
    .settle-table td { padding: 16px; font-size: 14px; font-weight: 600; color: #334155; border-bottom: 1px solid #F1F5F9; text-align: right; }
    .settle-table th:first-child, .settle-table td:first-child { text-align: center; padding-left: 24px; }
    .settle-table th:last-child, .settle-table td:last-child { text-align: center; padding-right: 24px; }
    
    .color-red { color: #EF4444 !important; }
    .color-red-light { color: #F87171 !important; }
    .color-green { color: #10B981 !important; }
    .color-dark { color: #0F172A !important; }
    .color-gray { color: #64748B !important; }
    .text-lg { font-size: 16px !important; }
    .font-black { font-weight: 900 !important; }
    
    .status-badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 800; display: inline-block; }
    .badge-warning { background: #FEF9C3; color: #CA8A04; }
    .badge-gray { background: #F1F5F9; color: #64748B; }
	
	.modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(4px); }
    .modal-container { background: #FFFFFF; border-radius: 20px; width: 100%; max-width: 800px; padding: 32px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); max-height: 85vh; display: flex; flex-direction: column; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #E2E8F0; }
    .modal-header h2 { margin: 0; font-size: 20px; font-weight: 900; color: #0F172A; }
    .modal-close { background: none; border: none; font-size: 28px; color: #94A3B8; cursor: pointer; padding: 0; line-height: 1; }
    .modal-close:hover { color: #0F172A; }
    .modal-body { overflow-y: auto; flex-grow: 1; padding-right: 8px; }
	
    /* 모달 내부 스크롤바 디자인 */
    .modal-body::-webkit-scrollbar { width: 6px; }
    .modal-body::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 10px; }
    
    .modal-summary-box { display: flex; justify-content: space-between; background: #F8FAFC; padding: 16px 24px; border-radius: 12px; margin-bottom: 24px; border: 1px solid #E2E8F0; }
    .summary-item { text-align: center; }
    .summary-title { font-size: 12px; color: #64748B; font-weight: 700; margin-bottom: 4px; }
    .summary-val { font-size: 16px; font-weight: 900; color: #0F172A; }
	
</style>

<div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
    
	<div class="settle-header-container">
        <div>
            <h1 class="settle-title">💰 정산 대금 조회</h1>
            <p class="settle-subtitle">발생한 매출에서 수수료 및 파트너 쿠폰 부담금을 제외한 최종 정산액을 확인하세요.</p>
        </div>
        <button type="button" class="btn btn-excel" onclick="downloadExcel()">엑셀 다운로드</button>
    </div>

    <div class="settle-kpi-grid">
        <div class="settle-card">
            <div class="math-sign">-</div>
            <div class="settle-label">이번 달 총 매출 (A)</div>
            <div class="settle-value">
                ₩ <fmt:formatNumber value="${empty expectedSettlement.totalSales ? 0 : expectedSettlement.totalSales}" pattern="#,###"/>
            </div>
        </div>
        <div class="settle-card">
            <div class="math-sign">-</div>
            <div class="settle-label">플랫폼 수수료 (B) <span style="color:#EF4444; font-weight:900;">(${empty expectedSettlement.commissionRate ? 10 : expectedSettlement.commissionRate}%)</span></div>
            <div class="settle-value color-red">
                ₩ <fmt:formatNumber value="${empty expectedSettlement.commissionAmount ? 0 : expectedSettlement.commissionAmount}" pattern="#,###"/>
            </div>
        </div>
        <div class="settle-card">
            <div class="math-sign">=</div>
            <div class="settle-label">파트너 쿠폰 부담금 (C)</div>
            <div class="settle-value color-red">
                ₩ <fmt:formatNumber value="${empty expectedSettlement.partnerCouponAmount ? 0 : expectedSettlement.partnerCouponAmount}" pattern="#,###"/>
            </div>
        </div>
        <div class="settle-card highlight">
            <div class="settle-label">이번 달 정산 예정액 (A-B-C)</div>
            <div class="settle-value color-green">
                ₩ <fmt:formatNumber value="${empty expectedSettlement.netAmount ? 0 : expectedSettlement.netAmount}" pattern="#,###"/>
            </div>
            <div class="settle-note">매월 1일 파트너 계좌로 입금됩니다.</div>
        </div>
    </div>

    <div class="settle-filter-card">
        <form action="main" method="GET" class="settle-filter-form">
            <input type="hidden" name="tab" value="settle">
            
            <div class="filter-group">
                <label class="filter-label">정산 연월</label>
                <input type="month" name="settleMonth" value="${param.settleMonth}" class="filter-input">
            </div>
            
            <div class="filter-group">
                <label class="filter-label">정산 상태</label>
                <select name="status" class="filter-input">
                    <option value="">전체 내역</option>
                    <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>정산 예정</option>
                    <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>지급 완료</option>
                </select>
            </div>
            
            <div style="display: flex; gap: 12px; margin-left: 8px;">
                <button type="submit" class="btn-search">검색</button>
                <a href="?tab=settle" class="btn-reset">초기화</a>
            </div>
        </form>
    </div>

    <div class="table-card">
        <table class="settle-table">
            <thead>
                <tr>
                    <th>정산월</th>
                    <th>총 결제 매출액</th>
                    <th>수수료 내역</th>
                    <th>쿠폰 분담금</th>
                    <th class="color-dark font-black">최종 정산액</th>
                    <th class="text-center">상태</th>
                    <th class="text-center">명세서</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty settlementList}">
                        <c:forEach var="item" items="${settlementList}">
                            <c:set var="rowClass" value="${item.status == 'COMPLETED' ? 'color-gray' : 'color-dark font-black'}" />
                            <c:set var="redClass" value="${item.status == 'COMPLETED' ? 'color-red-light' : 'color-red'}" />
                            <c:set var="netClass" value="${item.status == 'COMPLETED' ? 'color-dark font-black text-lg' : 'color-green font-black text-lg'}" />
                            
                            <tr>
                                <td class="${rowClass}">${item.settlementMonth}</td>
                                <td class="${item.status == 'COMPLETED' ? 'color-gray' : ''}">
                                    ₩ <fmt:formatNumber value="${item.totalSales}" pattern="#,###"/>
                                </td>
                                <td class="${redClass}">
                                    - ₩ <fmt:formatNumber value="${item.commissionAmount}" pattern="#,###"/>
                                </td>
                                <td class="${redClass}">
                                    - ₩ <fmt:formatNumber value="${item.partnerCouponAmount}" pattern="#,###"/>
                                </td>
                                <td class="${netClass}">
                                    ₩ <fmt:formatNumber value="${item.netAmount}" pattern="#,###"/>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.status == 'COMPLETED'}">
                                            <span class="status-badge badge-gray">지급 완료</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge badge-warning">정산 예정</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
								<td class="text-center">
                                    <button type="button" class="btn btn-detail" 
                                        onclick="openSettleModal('${item.settlementMonth}', ${item.totalSales}, ${item.commissionAmount}, ${item.partnerCouponAmount}, ${item.netAmount})">
                                        상세보기
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 60px 20px;">
                                <div style="font-size: 40px; margin-bottom: 16px;">💸</div>
                                <p style="color: var(--text-gray); font-size: 15px; font-weight: 600; margin: 0;">해당 조건의 정산 내역이 없습니다.</p>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<div id="settleDetailModal" class="modal-overlay" onclick="closeSettleModal(event)">
    <div class="modal-container" onclick="event.stopPropagation();">
        <div class="modal-header">
            <h2 id="modalTitle">2026. 00 정산 명세서</h2>
            <button class="modal-close" onclick="closeSettleModal()">&times;</button>
        </div>
        
        <div class="modal-body">
            <div class="modal-summary-box">
                <div class="summary-item">
                    <div class="summary-title">총 매출</div>
                    <div class="summary-val" id="modalTotalSales">₩ 0</div>
                </div>
                <div class="summary-item">
                    <div class="summary-title">수수료 차감</div>
                    <div class="summary-val color-red" id="modalCommission">- ₩ 0</div>
                </div>
                <div class="summary-item">
                    <div class="summary-title">쿠폰 차감</div>
                    <div class="summary-val color-red" id="modalCoupon">- ₩ 0</div>
                </div>
                <div class="summary-item">
                    <div class="summary-title">최종 정산액</div>
                    <div class="summary-val color-green" id="modalNet">₩ 0</div>
                </div>
            </div>

            <table class="settle-table" style="font-size: 13px;">
                <thead>
                    <tr>
                        <th style="text-align: center; padding-left: 16px;">예약번호</th>
                        <th style="text-align: left;">객실명</th>
                        <th>결제금액</th>
                        <th>수수료액</th>
                        <th>쿠폰부담</th>
                        <th class="color-dark font-black" style="padding-right: 16px;">정산대상액</th>
                    </tr>
                </thead>
                <tbody id="modalDetailBody">
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #94A3B8; font-weight: 600;">
                            데이터를 불러오는 중입니다...
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    const formatCurrency = (num) => new Intl.NumberFormat('ko-KR').format(num);

    function openSettleModal(month, totalSales, commission, coupon, netAmount) {
        document.getElementById('settleDetailModal').style.display = 'flex';
        document.body.style.overflow = 'hidden'; 

        document.getElementById('modalTitle').innerText = month + ' 정산 명세서';
        document.getElementById('modalTotalSales').innerText = '₩ ' + formatCurrency(totalSales);
        document.getElementById('modalCommission').innerText = '- ₩ ' + formatCurrency(commission);
        document.getElementById('modalCoupon').innerText = '- ₩ ' + formatCurrency(coupon);
        document.getElementById('modalNet').innerText = '₩ ' + formatCurrency(netAmount);

        const tbody = document.getElementById('modalDetailBody');
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 40px; color: #94A3B8; font-weight: 600;">로딩 중... ⏳</td></tr>';

        fetch(`${pageContext.request.contextPath}/partner/api/settlement/detail?month=` + month)
            .then(response => response.json())
            .then(data => {
                tbody.innerHTML = ''; 

                if (!data || data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 40px; color: #94A3B8; font-weight: 600;">해당 월의 상세 내역이 없습니다.</td></tr>';
                    return;
                }

                data.forEach(item => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td style="text-align: center; padding-left: 16px; color: #64748B;">#\${item.reservationId}</td>
                        <td style="text-align: left; font-weight: 800; color: #334155;">\${item.roomName}</td>
                        <td>₩ \${formatCurrency(item.amount)}</td>
                        <td class="color-red-light">- ₩ \${formatCurrency(item.commissionAmount)}</td>
                        <td class="color-red-light">- ₩ \${formatCurrency(item.couponAmount)}</td>
                        <td class="color-dark font-black" style="padding-right: 16px;">₩ \${formatCurrency(item.netAmount)}</td>
                    `;
                    tbody.appendChild(tr);
                });
            })
            .catch(error => {
                console.error('Error:', error);
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 40px; color: #EF4444; font-weight: 600;">데이터를 불러오는데 실패했습니다.</td></tr>';
            });
    }

    function closeSettleModal(event) {
        if (event && event.target.id !== 'settleDetailModal' && !event.target.classList.contains('modal-close')) {
            return;
        }
        document.getElementById('settleDetailModal').style.display = 'none';
        document.body.style.overflow = ''; 
    }
	
function downloadExcel() {
    const form = document.querySelector('.settle-filter-form');
    const settleMonth = form.settleMonth.value;
    const status = form.status.value;
    
    const contextPath = '${pageContext.request.contextPath}';
    
    let url = contextPath + '/partner/api/settlement/excel?settleMonth=' + settleMonth + '&status=' + status;
    
    window.location.href = url;
}
</script>