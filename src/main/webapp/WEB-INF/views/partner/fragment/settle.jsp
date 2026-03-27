<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
    /* 🌟 레이아웃 & 컨테이너 */
    .settle-header-container { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    .settle-title { font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; margin: 0; }
    .settle-subtitle { color: var(--text-gray); margin-top: 8px; font-weight: 500; margin-bottom: 0; }
    .table-card { padding: 0; overflow: hidden; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }

    /* 🌟 버튼 요소 */
    .btn-excel { padding: 10px 16px; font-weight: 700; border-radius: 10px; border: 1px solid #CBD5E1; color: #475569; background: white; cursor: pointer; transition: background 0.2s; }
    .btn-excel:hover { background: #F8FAFC; }
    .btn-detail { padding: 4px 12px; font-size: 12px; font-weight: 700; border-radius: 6px; border: 1px solid #E2E8F0; background: white; color: #64748B; cursor: pointer; transition: background 0.2s; }
    .btn-detail:hover { background: #F8FAFC; }

    /* 🌟 상단 KPI 대시보드 */
    .settle-kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
    .settle-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); position: relative; overflow: hidden; }
    .settle-card.highlight { background: #0F172A; border-color: #0F172A; }
    .settle-label { font-size: 13px; font-weight: 700; color: #64748B; margin-bottom: 8px; }
    .settle-card.highlight .settle-label { color: #94A3B8; }
    .settle-value { font-size: 28px; font-weight: 900; color: #1E293B; font-family: 'Sora', sans-serif; }
    .settle-card.highlight .settle-value { color: #10B981; }
    .math-sign { position: absolute; right: -10px; top: 50%; transform: translateY(-50%); font-size: 40px; font-weight: 900; color: #F1F5F9; z-index: 0; }
    .settle-note { font-size: 11px; color: #64748B; margin-top: 6px; font-weight: 500; }

    /* 🌟 신규: 검색 필터 영역 (시원하게 간격 펌핑!) */
    .settle-filter-card { padding: 24px 32px; border-radius: 16px; margin-bottom: 24px; background: #F8FAFC; border: 1px solid #E2E8F0; }
    .settle-filter-form { display: flex; gap: 32px; align-items: center; flex-wrap: wrap; margin: 0; } /* gap을 12px -> 32px로 대폭 증가 */
    .filter-input { padding: 12px 20px; border: 1px solid #CBD5E1; border-radius: 10px; font-size: 14px; color: #334155; background: white; font-family: inherit; font-weight: 600; min-width: 160px; } /* 패딩, 폰트크기, 최소너비 증가 */
    .filter-input:focus { outline: none; border-color: #0F172A; box-shadow: 0 0 0 3px rgba(15, 23, 42, 0.05); }
    .btn-search { padding: 12px 32px; background: #1E293B; color: white; border: none; border-radius: 10px; font-size: 14px; font-weight: 800; cursor: pointer; transition: background 0.2s; }
    .btn-search:hover { background: #0F172A; }
    .btn-reset { padding: 12px 24px; background: white; color: #64748B; border: 1px solid #CBD5E1; border-radius: 10px; font-weight: 700; text-decoration: none; font-size: 14px; display: inline-flex; align-items: center; justify-content: center; }
    .btn-reset:hover { background: #F1F5F9; color: #334155; }
    .filter-group { display: flex; align-items: center; gap: 12px; }
    .filter-label { font-size: 14px; font-weight: 800; color: #334155; }

    /* 🌟 테이블 공통 */
    .settle-table { width: 100%; border-collapse: collapse; }
    .settle-table th { padding: 16px; font-size: 13px; color: #64748B; font-weight: 700; background: #F8FAFC; border-bottom: 1px solid #E2E8F0; text-align: right; }
    .settle-table td { padding: 16px; font-size: 14px; font-weight: 600; color: #334155; border-bottom: 1px solid #F1F5F9; text-align: right; }
    .settle-table th:first-child, .settle-table td:first-child { text-align: center; padding-left: 24px; }
    .settle-table th:last-child, .settle-table td:last-child { text-align: center; padding-right: 24px; }
    
    /* 🌟 절대 안 빠지는 텍스트 컬러 전용 클래스 */
    .color-red { color: #EF4444 !important; }
    .color-red-light { color: #F87171 !important; }
    .color-green { color: #10B981 !important; }
    .color-dark { color: #0F172A !important; }
    .color-gray { color: #64748B !important; }
    .text-lg { font-size: 16px !important; }
    .font-black { font-weight: 900 !important; }
    
    /* 🌟 상태 뱃지 */
    .status-badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 800; display: inline-block; }
    .badge-warning { background: #FEF9C3; color: #CA8A04; }
    .badge-gray { background: #F1F5F9; color: #64748B; }
</style>

<div id="tab-settle" class="page-section ${activeTab == 'settle' ? 'active' : ''}">
    
    <div class="settle-header-container">
        <div>
            <h1 class="settle-title">💰 정산 대금 조회</h1>
            <p class="settle-subtitle">발생한 매출에서 수수료 및 파트너 쿠폰 부담금을 제외한 최종 정산액을 확인하세요.</p>
        </div>
        <button class="btn btn-excel">엑셀 다운로드</button>
    </div>

    <div class="settle-kpi-grid">
        <div class="settle-card">
            <div class="math-sign">-</div>
            <div class="settle-label">이번 달 총 매출 (A)</div>
            <div class="settle-value">₩ 5,000,000</div>
        </div>
        <div class="settle-card">
            <div class="math-sign">-</div>
            <div class="settle-label">플랫폼 수수료 (B)</div>
            <div class="settle-value color-red">₩ 500,000</div>
        </div>
        <div class="settle-card">
            <div class="math-sign">=</div>
            <div class="settle-label">파트너 쿠폰 부담금 (C)</div>
            <div class="settle-value color-red">₩ 150,000</div>
        </div>
        <div class="settle-card highlight">
            <div class="settle-label">이번 달 정산 예정액 (A-B-C)</div>
            <div class="settle-value color-green">₩ 4,350,000</div>
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
                    <th>수수료 (10%)</th>
                    <th>쿠폰 분담금</th>
                    <th class="color-dark font-black">최종 정산액</th>
                    <th class="text-center">상태</th>
                    <th class="text-center">명세서</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="color-dark font-black">2026. 03</td>
                    <td>₩ 5,000,000</td>
                    <td class="color-red">- ₩ 500,000</td>
                    <td class="color-red">- ₩ 150,000</td>
                    <td class="color-green font-black text-lg">₩ 4,350,000</td>
                    <td class="text-center">
                        <span class="status-badge badge-warning">정산 예정</span>
                    </td>
                    <td class="text-center">
                        <button class="btn btn-detail">상세보기</button>
                    </td>
                </tr>

                <tr>
                    <td class="color-gray">2026. 02</td>
                    <td class="color-gray">₩ 3,200,000</td>
                    <td class="color-red-light">- ₩ 320,000</td>
                    <td class="color-red-light">- ₩ 0</td>
                    <td class="color-dark font-black text-lg">₩ 2,880,000</td>
                    <td class="text-center">
                        <span class="status-badge badge-gray">지급 완료</span>
                    </td>
                    <td class="text-center">
                        <button class="btn btn-detail">상세보기</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>