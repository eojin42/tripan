<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
    <div class="page-header">
        <h1>정산 내역</h1>
        <p>매월 발생한 매출과 정산 금액을 확인합니다.</p>
    </div>
    <div class="card" style="padding:0; overflow:hidden;">
        <table>
            <thead>
                <tr><th style="padding-left:24px;">정산월</th><th>총 매출</th><th>실 지급액</th><th>상태</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td style="padding-left:24px;">2026년 09월</td><td>₩ 5,000,000</td><td style="font-weight:900;">₩ 4,500,000</td>
                    <td><span class="badge badge-done">지급완료</span></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>