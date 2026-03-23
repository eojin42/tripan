<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="tab-calendar" class="page-section ${activeTab == 'calendar' ? 'active' : ''}">
    <div class="page-header">
        <h1>예약 캘린더</h1>
        <p>날짜별 객실 예약 현황을 한눈에 보고 판매를 관리하세요.</p>
    </div>
    
    <div class="card" style="padding: 30px;">
        <div id="calendar"></div> 
    </div>
</div>


<!-- 캘린더용 모달 -->

<div id="reservationDetailModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background: white; padding: 30px; border-radius: 12px; width: 400px; box-shadow: 0 4px 20px rgba(0,0,0,0.15);">
        <h2 style="margin-top: 0; margin-bottom: 20px; font-size: 20px; font-weight: 800; border-bottom: 2px solid #F1F5F9; padding-bottom: 10px;">🗓️ 예약 상세 정보</h2>
        
        <div style="margin-bottom: 15px; font-size: 14px;">
            <p><strong>예약자 (객실):</strong> <span id="modalTitle" style="color: var(--primary); font-weight: 700;"></span></p>
            <p><strong>일정:</strong> <span id="modalDate"></span></p>
            <p><strong>인원:</strong> <span id="modalGuest"></span>명</p>
            <p><strong>결제 금액:</strong> <span id="modalAmount" style="font-weight: 700;"></span>원</p>
            <p><strong>상태:</strong> <span id="modalStatus"></span></p>
            <div style="background: #F8FAFC; padding: 10px; border-radius: 8px; margin-top: 15px;">
                <strong>💬 고객 요청사항:</strong><br>
                <span id="modalRequest" style="color: #64748B;"></span>
            </div>
        </div>

        <div style="text-align: right; margin-top: 20px;">
            <button onclick="document.getElementById('reservationDetailModal').style.display='none'" style="padding: 8px 16px; background: #E2E8F0; border: none; border-radius: 6px; cursor: pointer; font-weight: 700;">닫기</button>
        </div>
    </div>
</div>