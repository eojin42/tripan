<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="../layout/header.jsp" />

<style>
  /* 관리자 페이지 전용 추가 스타일 */
  .admin-section { padding: 120px 5%; max-width: 1400px; margin: 0 auto; }
  .admin-filter { display: flex; gap: 16px; margin-bottom: 30px; align-items: center; background: white; padding: 20px; border-radius: var(--radius-lg); box-shadow: 0 8px 32px rgba(45, 55, 72, 0.05); }
  .admin-filter select, .admin-filter input { padding: 12px 20px; border: 1px solid var(--bg-beige); border-radius: var(--radius-pill); font-family: inherit; font-size: 14px; outline: none; }
  
  .data-table { width: 100%; border-collapse: separate; border-spacing: 0; background: white; border-radius: var(--radius-lg); overflow: hidden; box-shadow: 0 8px 32px rgba(45, 55, 72, 0.05); }
  .data-table th, .data-table td { padding: 16px 24px; text-align: left; border-bottom: 1px solid var(--bg-light); font-size: 14px; }
  .data-table th { background: var(--text-black); color: white; font-weight: 800; }
  .data-table tr:hover { background: var(--bg-light); }
  
  .status-badge { padding: 6px 12px; border-radius: 8px; font-weight: 800; font-size: 12px; }
  .status-active { background: #E6F4FF; color: var(--point-blue); }
  .status-banned { background: #FEEBC8; color: #DD6B20; }
  
  .btn-action { padding: 8px 16px; border-radius: var(--radius-pill); font-size: 13px; font-weight: 700; background: var(--bg-beige); color: var(--text-black); cursor: pointer; border: none; transition: 0.2s; }
  .btn-action:hover { background: var(--text-black); color: white; }
</style>

<main class="admin-section">
    <div class="feed-header reveal active">
        <div>
            <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">회원 관리 👥</h2>
            <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">서비스 이용자 및 파트너사의 권한과 상태를 관리합니다.</p>
        </div>
    </div>

    <div class="admin-filter reveal active delay-100">
        <select name="userRole">
            <option value="ALL">전체 권한</option>
            <option value="USER">일반 유저</option>
            <option value="PARTNER">파트너 관리자</option>
        </select>
        <select name="userStatus">
            <option value="ALL">전체 상태</option>
            <option value="ACTIVE">정상</option>
            <option value="BANNED">정지</option>
        </select>
        <input type="text" placeholder="아이디 또는 닉네임 검색" style="flex: 1;">
        <button class="btn-more" style="background: var(--text-black); color: white;">검색하기</button>
    </div>

    <div class="reveal active delay-200">
        <table class="data-table">
            <thead>
                <tr>
                    <th>NO</th>
                    <th>아이디</th>
                    <th>닉네임</th>
                    <th>권한</th>
                    <th>가입일</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td>user_01@email.com</td>
                    <td>여행에미치다</td>
                    <td>일반 유저</td>
                    <td>2026-01-15</td>
                    <td><span class="status-badge status-active">정상</span></td>
                    <td><button class="btn-action">권한/상태 변경</button></td>
                </tr>
                <tr>
                    <td>2</td>
                    <td>stay_shilla</td>
                    <td>신라호텔 관리자</td>
                    <td>파트너 관리자</td>
                    <td>2026-01-10</td>
                    <td><span class="status-badge status-active">정상</span></td>
                    <td><button class="btn-action">권한/상태 변경</button></td>
                </tr>
                <tr>
                    <td>3</td>
                    <td>bad_user123</td>
                    <td>도배꾼</td>
                    <td>일반 유저</td>
                    <td>2026-02-01</td>
                    <td><span class="status-badge status-banned">정지 (스팸)</span></td>
                    <td><button class="btn-action">권한/상태 변경</button></td>
                </tr>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="../layout/footer.jsp" />