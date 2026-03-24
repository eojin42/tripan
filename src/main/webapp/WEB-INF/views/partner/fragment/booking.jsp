<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div id="tab-booking" class="page-section ${activeTab == 'booking' ? 'active' : ''}">
    <div class="page-header">
        <h1>예약 내역 관리</h1>
        <p>실시간 예약 현황을 확인하고 예약을 확정/취소합니다.</p>
    </div>
    
    <div class="search-filter-box" style="background: #F8FAFC; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
	    <form action="main" method="GET" style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
	        <input type="hidden" name="tab" value="booking">
	        
	        <div style="display: flex; align-items: center; gap: 5px;">
	            <input type="date" name="startDate" value="${param.startDate}" style="padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px;">
	            <span>~</span>
	            <input type="date" name="endDate" value="${param.endDate}" style="padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px;">
	        </div>
	        
	        <select name="roomId" style="padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px;">
			    <option value="">객실 전체</option>
			    <c:forEach var="room" items="${roomList}">
			        <option value="${room.roomId}" ${param.roomId == room.roomId ? 'selected' : ''}>
			            ${room.roomName}
			        </option>
			    </c:forEach>
			</select>
	
	        <select name="status" style="padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px;">
	            <option value="">상태 전체</option>
	            <option value="SUCCESS" ${param.status == 'SUCCESS' ? 'selected' : ''}>예약확정</option>
	            <option value="CANCELED" ${param.status == 'CANCELED' ? 'selected' : ''}>취소됨</option>
	        </select>
	
	        <input type="text" name="keyword" value="${param.keyword}" placeholder="예약자명 또는 연락처" style="padding: 8px; border: 1px solid #E2E8F0; border-radius: 6px; flex-grow: 1; min-width: 200px;">
	        
	        <button type="submit" style="padding: 8px 24px; background: var(--primary); color: white; border: none; border-radius: 6px; font-weight: 700; cursor: pointer;">검색</button>
	        <a href="?tab=booking" style="padding: 8px 16px; background: white; color: #64748B; border: 1px solid #E2E8F0; border-radius: 6px; font-weight: 700; text-decoration: none; font-size: 13px; display: flex; align-items: center;">초기화</a>
	    </form>
	</div>
    
    <div class="card" style="padding: 0; overflow: hidden;">
        <table style="width: 100%; border-collapse: collapse; text-align: left;">
            <thead style="background: #F8FAFC; border-bottom: 1px solid #E2E8F0;">
                <tr>
                    <th style="padding: 16px 24px;">예약번호</th>
                    <th>예약자</th>
                    <th>객실명 / 인원</th>
                    <th>일정</th>
                    <th>결제금액</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="booking" items="${bookingList}">
                    <tr style="border-bottom: 1px solid #F1F5F9;">
                        <td style="padding: 16px 24px; font-weight:700; color: #64748B;">
                            RES-${booking.reservationId}
                        </td>
                        <td style="font-weight: 700;">${booking.guestName}</td>
                        <td>${booking.roomName} <span style="color:#94A3B8; font-size:12px;">(${booking.guestCount}인)</span></td>
                        <td style="font-size: 13px;">${booking.checkIn} ~ ${booking.checkOut}</td>
                        <td style="font-weight: 600;"><fmt:formatNumber value="${booking.amount}" pattern="#,###"/>원</td>
                        <td>
                            <c:choose>
                                <c:when test="${booking.status == 'SUCCESS'}">
                                    <span class="badge" style="background: #DCFCE7; color: #166534; padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 700;">예약확정</span>
                                </c:when>
                                <c:when test="${booking.status == 'CANCELED'}">
                                    <span class="badge" style="background: #FEE2E2; color: #991B1B; padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 700;">취소됨</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge" style="background: #FEF3C7; color: #92400E; padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 700;">${booking.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:if test="${booking.status != 'CANCELED'}">
							  <button onclick="openBookingDetail(
							    '${booking.reservationId}', 
							    '${booking.guestName}', 
							    '${booking.guestPhone}', 
							    '${booking.roomName}', 
							    '${booking.checkIn} ~ ${booking.checkOut}', 
							    '${booking.amount}', 
							    '${booking.status}'
							)" style="background: white; border: 1px solid #64748B; color: #475569; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700;">
							    예약 관리
							</button>
							</c:if>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty bookingList}">
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 40px; color: #94A3B8;">예약 내역이 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!--  모달 영역 -->

<div id="bookingDetailModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background: white; padding: 30px; border-radius: 12px; width: 450px; box-shadow: 0 4px 20px rgba(0,0,0,0.15);">
        <h2 style="margin-top: 0; margin-bottom: 20px; font-size: 20px; font-weight: 800; border-bottom: 2px solid #F1F5F9; padding-bottom: 10px;">📋 예약 상세 관리</h2>
        
        <div style="margin-bottom: 20px; font-size: 14px; line-height: 1.6;">
            <p><strong>예약 번호:</strong> <span id="dtlResId" style="color: var(--primary); font-weight: 700;"></span></p>
            <p><strong>예약자:</strong> <span id="dtlName"></span> (<span id="dtlPhone"></span>)</p>
            <p><strong>객실:</strong> <span id="dtlRoom"></span></p>
            <p><strong>일정:</strong> <span id="dtlDate"></span></p>
            <p><strong>결제 금액:</strong> <span id="dtlAmount" style="font-weight: 700; color: #0F172A;"></span>원</p>
            <p><strong>현재 상태:</strong> <span id="dtlStatus"></span></p>
        </div>

        <div style="border-top: 1px solid #E2E8F0; margin: 20px 0;"></div>

        <div id="cancelActionArea">
            <h3 style="font-size: 14px; color: #EF4444; margin-bottom: 10px;">⚠️ 파트너 권한 강제 취소 (환불)</h3>
            <textarea id="cancelReason" placeholder="고객에게 안내될 취소 사유를 입력해주세요 (예: 기상 악화, 객실 수리 등)" style="width: 100%; height: 60px; padding: 10px; border: 1px solid #E2E8F0; border-radius: 6px; margin-bottom: 10px; resize: none;"></textarea>
            <button onclick="submitCancel()" style="width: 100%; padding: 10px; background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; border-radius: 6px; font-weight: 700; cursor: pointer;">
                이 예약을 강제 취소하고 환불 진행하기
            </button>
        </div>

        <div style="text-align: right; margin-top: 20px;">
            <button onclick="document.getElementById('bookingDetailModal').style.display='none'" style="padding: 8px 16px; background: #F1F5F9; color: #475569; border: none; border-radius: 6px; cursor: pointer; font-weight: 700;">닫기</button>
        </div>
    </div>
</div>