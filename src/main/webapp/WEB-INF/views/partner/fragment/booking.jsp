<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="tab-booking" class="page-section ${activeTab == 'booking' ? 'active' : ''}">
    <div class="page-header">
        <h1>예약 내역 관리</h1>
        <p>실시간 예약 현황을 확인하고 예약을 확정/취소합니다.</p>
    </div>
    <div class="card" style="padding: 0; overflow: hidden;">
        <table>
            <thead style="background: #F8FAFC;">
                <tr><th style="padding-left:24px;">예약번호</th><th>예약자</th><th>객실명</th><th>상태</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td style="padding-left:24px; font-weight:700;">RES-20261015-01</td>
                    <td>김철수</td><td>오션뷰 프리미엄</td>
                    <td><span class="badge badge-done">예약확정</span></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>