<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
/* 모달 전용 스타일 */
.modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(15, 23, 42, 0.6);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(4px);
}
.modal-content {
    background: #FFFFFF;
    border-radius: 20px;
    width: 100%;
    max-width: 500px;
    padding: 32px;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    max-height: 90vh;
    overflow-y: auto;
}
.form-group {
    margin-bottom: 20px;
}
.form-group label {
    display: block;
    font-weight: 700;
    color: #334155;
    margin-bottom: 8px;
    font-size: 14px;
}
.form-control {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #E2E8F0;
    border-radius: 12px;
    font-size: 14px;
    color: #1E293B;
    background: #F8FAFC;
    transition: all 0.2s;
    box-sizing: border-box;
}
.form-control:focus {
    outline: none;
    border-color: #6366F1;
    background: #FFFFFF;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}
.form-control:disabled {
    background: #F1F5F9;
    color: #64748B;
    cursor: not-allowed;
    border-color: #E2E8F0;
}
.grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}
.applied-place-badge {
    background: #F1F5F9;
    color: #475569;
    padding: 6px 10px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    display: inline-block;
    border: 1px solid #E2E8F0;
}

/* 추가된 발행 주체 뱃지 스타일 */
.issuer-badge {
    font-size: 11px;
    font-weight: 800;
    padding: 3px 8px;
    border-radius: 6px;
    margin-right: 6px;
    vertical-align: middle;
}
.issuer-platform {
    background: #FEF2F2;
    color: #EF4444;
    border: 1px solid #FCA5A5;
}
.issuer-partner {
    background: #F0FDF4;
    color: #22C55E;
    border: 1px solid #86EFAC;
}
</style>

<div id="tab-coupon" class="page-section ${activeTab == 'coupon' ? 'active' : ''}">
    
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px;">🎟️ 쿠폰 마케팅</h1>
            <p style="color: var(--text-gray); margin-top: 8px; font-weight: 500;">우리 숙소 전용 할인 쿠폰을 직접 발행하고 관리하여 예약률을 높여보세요.</p>
        </div>
        <button class="btn btn-primary" onclick="openCouponModal()" style="padding: 12px 24px; font-weight: 800; border-radius: 12px;">+ 새 쿠폰 발행</button>
    </div>

    <div class="kpi-grid" style="grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px;">
        <div class="card" style="padding: 24px; margin-bottom: 0; border-radius: 16px; border: 1px solid #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
            <div class="kpi-label" style="color: #64748B; font-size: 14px; font-weight: 700; margin-bottom: 8px;">발급 진행 중인 쿠폰</div>
            <div class="kpi-value" style="color: var(--primary); font-size: 32px; font-weight: 900; font-family: 'Sora', sans-serif;">
                ${kpiStats.activeCount != null ? kpiStats.activeCount : 0}건
            </div>
        </div>
        <div class="card" style="padding: 24px; margin-bottom: 0; border-radius: 16px; border: 1px solid #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
            <div class="kpi-label" style="color: #64748B; font-size: 14px; font-weight: 700; margin-bottom: 8px;">이번 달 누적 다운로드</div>
            <div class="kpi-value" style="color: #0F172A; font-size: 32px; font-weight: 900; font-family: 'Sora', sans-serif;">
                ${kpiStats.monthDownloadCount != null ? kpiStats.monthDownloadCount : 0}건
            </div>
        </div>
        <div class="card" style="padding: 24px; margin-bottom: 0; border-radius: 16px; border: 1px solid #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
            <div class="kpi-label" style="color: #64748B; font-size: 14px; font-weight: 700; margin-bottom: 8px;">이번 달 실제 사용(결제)</div>
            <div class="kpi-value" style="color: #10B981; font-size: 32px; font-weight: 900; font-family: 'Sora', sans-serif;">
                ${kpiStats.monthUseCount != null ? kpiStats.monthUseCount : 0}건
            </div>
        </div>
    </div>

    <div class="card" style="padding: 20px; border-radius: 16px; margin-bottom: 24px; background: #F8FAFC; border: 1px solid #E2E8F0; box-shadow: none;">
        <form action="main" method="GET" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap; margin: 0;">
            <input type="hidden" name="tab" value="coupon">
            
            <div style="display: flex; align-items: center; gap: 8px;">
                <input type="date" name="startDate" value="${param.startDate}" style="padding: 10px; border: 1px solid #CBD5E1; border-radius: 8px; font-size: 13px; color: #475569;">
                <span style="color: #94A3B8; font-weight: bold;">~</span>
                <input type="date" name="endDate" value="${param.endDate}" style="padding: 10px; border: 1px solid #CBD5E1; border-radius: 8px; font-size: 13px; color: #475569;">
            </div>
            
            <select name="status" style="padding: 10px; border: 1px solid #CBD5E1; border-radius: 8px; font-size: 13px; color: #475569; min-width: 120px;">
                <option value="">상태 전체</option>
                <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>발급중</option>
                <option value="WAITING" ${param.status == 'WAITING' ? 'selected' : ''}>대기중</option>
                <option value="EXPIRED" ${param.status == 'EXPIRED' ? 'selected' : ''}>종료됨</option>
            </select>

            <input type="text" name="keyword" value="${param.keyword}" placeholder="쿠폰명 검색" style="padding: 10px; border: 1px solid #CBD5E1; border-radius: 8px; flex-grow: 1; min-width: 180px; font-size: 13px;">
            
            <button type="submit" style="padding: 10px 24px; background: #1E293B; color: white; border: none; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s;">검색</button>
            <a href="?tab=coupon" style="padding: 10px 16px; background: white; color: #64748B; border: 1px solid #CBD5E1; border-radius: 8px; font-weight: 600; text-decoration: none; font-size: 13px; transition: 0.2s;">초기화</a>
        </form>
    </div>

    <div class="card" style="padding: 0; overflow: hidden; border-radius: 16px; border: 1px solid #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
        
        <c:choose>
            <c:when test="${not empty couponList}">
                <table style="width: 100%; border-collapse: collapse; text-align: left;">
                    <thead style="background: #F8FAFC; border-bottom: 1px solid #E2E8F0;">
                        <tr>
                            <th style="padding: 16px 24px; font-size: 14px; color: #64748B; font-weight: 700;">쿠폰명</th>
                            <th style="padding: 16px; font-size: 14px; color: #64748B; font-weight: 700;">할인 혜택</th>
                            <th style="padding: 16px; font-size: 14px; color: #64748B; font-weight: 700;">통계 (다운/사용)</th>
                            <th style="padding: 16px; font-size: 14px; color: #64748B; font-weight: 700;">유효 기간</th>
                            <th style="padding: 16px; font-size: 14px; color: #64748B; font-weight: 700;">상태</th>
                            <th style="text-align: center; padding: 16px 24px; font-size: 14px; color: #64748B; font-weight: 700;">관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="coupon" items="${couponList}">
                            <tr style="border-bottom: 1px solid #F1F5F9;">
                                
                                <td style="padding: 16px 24px; font-weight: 800; color: #0F172A;">
                                    <c:choose>
                                        <c:when test="${coupon.platformShare > 0}">
                                            <span class="issuer-badge issuer-platform">TRIPAN</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="issuer-badge issuer-partner">우리숙소</span>
                                        </c:otherwise>
                                    </c:choose>
                                    ${coupon.couponName}
                                </td>
                                
                                <td style="padding: 16px;">
                                    <c:choose>
                                        <c:when test="${coupon.discountType == 'FIXED'}">
                                            <span style="color: var(--danger, #EF4444); font-weight: 900; font-family:'Sora', sans-serif;">
                                                <fmt:formatNumber value="${coupon.discountAmount}" type="currency" currencySymbol="₩ "/>
                                            </span>
                                        </c:when>
                                        <c:when test="${coupon.discountType == 'PERCENT'}">
                                            <span style="color: var(--danger, #EF4444); font-weight: 900; font-family:'Sora', sans-serif;">
                                                <fmt:formatNumber value="${coupon.discountAmount}" pattern="#,###"/>%
                                            </span>
                                        </c:when>
                                    </c:choose>
                                    
                                    <div style="font-size: 11px; color: #94A3B8; margin-top: 4px; font-weight: 600;">
                                        <c:if test="${coupon.minOrderAmount > 0}">
                                            <fmt:formatNumber value="${coupon.minOrderAmount}" pattern="#,###"/>원 이상 결제 시
                                        </c:if>
                                        <c:if test="${coupon.minOrderAmount == 0 || coupon.minOrderAmount == null}">
                                            조건 없음
                                        </c:if>
                                    </div>
                                </td>
                                
                                <td style="padding: 16px; font-size: 13px; font-weight: 600; color: #475569;">
                                    ⬇️ ${coupon.downloadCount}건 / 💳 <span style="color:#10B981;">${coupon.useCount}건</span>
                                </td>
                                
                                <td style="padding: 16px; font-size: 13px; font-weight: 700; color: #334155;">
                                    ${coupon.validFrom} ~ ${coupon.validUntil}
                                </td>
                                
                                <td style="padding: 16px;">
                                    <c:choose>
                                        <c:when test="${coupon.status == 'ACTIVE'}">
                                            <span class="badge badge-done" style="background: #ECFDF5; color: #10B981; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 800;">발급중</span>
                                        </c:when>
                                        <c:when test="${coupon.status == 'WAITING'}">
                                            <span class="badge" style="background: #FEF9C3; color: #CA8A04; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 800;">대기중</span>
                                        </c:when>
                                        <c:when test="${coupon.status == 'EXPIRED'}">
                                            <span class="badge" style="background: #F1F5F9; color: #94A3B8; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 700;">기간만료</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                
                                <td style="text-align: center; padding: 16px 24px;">
                                    <c:choose>
                                        <c:when test="${coupon.platformShare > 0}">
                                            <button class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px; font-weight: 700; border-radius: 8px; border: none; background: transparent; color: #CBD5E1;" disabled>플랫폼 관리</button>
                                        </c:when>
                                        <c:when test="${coupon.status == 'ACTIVE' || coupon.status == 'WAITING'}">
                                            <button class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px; font-weight: 700; border-radius: 8px; border: 1px solid #E2E8F0; background: white; color: #475569; cursor: pointer;" onclick="stopCoupon(${coupon.couponId})">발급 중지</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-ghost" style="padding: 6px 12px; font-size: 12px; font-weight: 700; border-radius: 8px; border: none; background: transparent; color: #CBD5E1; text-decoration: line-through;" disabled>종료됨</button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div style="text-align: center; padding: 60px 20px;">
                    <div style="font-size: 40px; margin-bottom: 16px;">🎫</div>
                    <p style="color: var(--text-gray); font-size: 15px; font-weight: 600; margin: 0;">발행된 쿠폰 내역이 없습니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
        
    </div>
</div>

<div id="couponModal" class="modal-overlay">
    <div class="modal-content">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <h2 style="margin: 0; font-size: 22px; font-weight: 900; color: #0F172A;">✨ 새 쿠폰 발행하기</h2>
            <button onclick="closeCouponModal()" style="background: none; border: none; font-size: 24px; color: #94A3B8; cursor: pointer;">&times;</button>
        </div>
        
        <form id="couponForm" onsubmit="submitCoupon(event)">
            
            <div class="form-group">
                <label>적용 숙소</label>
                <select class="form-control" disabled>
                    <c:forEach var="place" items="${partnerPlaceList}">
                        <option value="${place.placeId}" selected>[숙소] ${place.name}</option>
                    </c:forEach>
                </select>
                <c:forEach var="place" items="${partnerPlaceList}">
                    <input type="hidden" name="placeId" value="${place.placeId}">
                </c:forEach>
            </div>

            <div class="form-group">
                <label>쿠폰 이름 <span style="color: #EF4444;">*</span></label>
                <input type="text" name="couponName" class="form-control" placeholder="예: 첫 예약 감사 5,000원 할인" required>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>할인 방식 <span style="color: #EF4444;">*</span></label>
                    <select name="discountType" class="form-control" required>
                        <option value="FIXED">정액 할인 (원)</option>
                        <option value="PERCENT">정률 할인 (%)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>할인 금액/비율 <span style="color: #EF4444;">*</span></label>
                    <input type="number" name="discountAmount" class="form-control" placeholder="금액 또는 % 입력" required>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>최소 결제 금액 (선택)</label>
                    <input type="number" name="minOrderAmount" class="form-control" placeholder="예: 50000">
                    <div style="font-size: 11px; color: #94A3B8; margin-top: 4px;">비워두면 조건 없이 사용 가능합니다.</div>
                </div>
                <div class="form-group">
                    <label>발급 한도 (선택)</label>
                    <input type="number" name="maxQuantity" class="form-control" placeholder="총 발행 가능 수량">
                    <div style="font-size: 11px; color: #94A3B8; margin-top: 4px;">비워두면 무제한으로 다운로드 됩니다.</div>
                </div>
            </div>

            <div class="grid-2" style="margin-bottom: 32px;">
                <div class="form-group" style="margin-bottom: 0;">
                    <label>발급 시작일 <span style="color: #EF4444;">*</span></label>
                    <input type="date" name="validFrom" class="form-control" required>
                </div>
                <div class="form-group" style="margin-bottom: 0;">
                    <label>발급 종료일 <span style="color: #EF4444;">*</span></label>
                    <input type="date" name="validUntil" class="form-control" required>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; padding-top: 20px; border-top: 1px solid #F1F5F9;">
                <button type="button" onclick="closeCouponModal()" class="btn btn-ghost" style="padding: 12px 20px; border-radius: 12px; font-weight: 700; color: #64748B; background: #F8FAFC; border: none; cursor: pointer;">취소</button>
                <button type="submit" class="btn btn-primary" style="padding: 12px 28px; border-radius: 12px; font-weight: 800; border: none; cursor: pointer;">🚀 쿠폰 발행하기</button>
            </div>
        </form>
    </div>
</div>



<script>
function openCouponModal() {
    document.getElementById('couponModal').style.display = 'flex';
}

function closeCouponModal() {
    document.getElementById('couponModal').style.display = 'none';
    document.getElementById('couponForm').reset();
}

window.onclick = function(event) {
    const modal = document.getElementById('couponModal');
    if (event.target == modal) {
        closeCouponModal();
    }
}

function stopCoupon(couponId) {
    if(confirm("이 쿠폰의 발급을 중지하시겠습니까?\n이미 다운로드한 고객은 유효기간 내에 사용할 수 있습니다.")) {
        
        fetch('${pageContext.request.contextPath}/partner/api/coupon/stop', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
				'AJAX' : 'true',
            },
            body: JSON.stringify({ couponId: couponId })
        })
        .then(response => {
            if (!response.ok) throw new Error('서버 통신 실패');
            return response.json();
        })
        .then(data => {
            if(data.message === 'success') {
                alert("성공적으로 발급이 중지되었습니다.");
                location.reload(); // 성공 시 페이지 새로고침
            } else {
                alert("발급 중지 처리에 실패했습니다.");
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert("서버 통신 중 오류가 발생했습니다.");
        });
    }
}

function submitCoupon(event) {
    event.preventDefault(); // 폼 기본 전송 막기
    
    const formData = new FormData(document.getElementById('couponForm'));
    const couponData = Object.fromEntries(formData.entries()); 
    
    if(new Date(couponData.validFrom) > new Date(couponData.validUntil)) {
        alert("종료일은 시작일보다 빠를 수 없습니다.");
        return;
    }

    if (!couponData.minOrderAmount) {
        couponData.minOrderAmount = 0;
    }
    if (!couponData.maxQuantity) {
        delete couponData.maxQuantity; 
    }
    if (!couponData.discountAmount) {
        couponData.discountAmount = 0;
    }

    // 서버 전송
    fetch('${pageContext.request.contextPath}/partner/api/coupon/save?placeId=' + couponData.placeId, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
			'AJAX' : 'true',
        },
        body: JSON.stringify(couponData)
    })
    .then(response => {
        if (!response.ok) throw new Error('서버 통신 실패');
        return response.json();
    })
    .then(data => {
        if(data.message === 'success') {
            alert("쿠폰이 성공적으로 발행되었습니다! 🎉");
            closeCouponModal();
            location.reload(); 
        } else {
            alert("쿠폰 발행에 실패했습니다. 다시 시도해주세요.");
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert("시스템 오류가 발생했습니다.");
    });
}
</script>