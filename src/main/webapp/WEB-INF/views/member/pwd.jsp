<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>비밀번호 확인 — Tripan</title>
  
  <style>
    /* 웹사이트 메인 테마와 일치하는 배경색 */
    body {
      background-color: #F3F6FA; 
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      font-family: 'Pretendard', -apple-system, sans-serif;
    }

    /* 부드러운 화이트 카드 스타일 */
    .pwd-container {
      background: #FFFFFF;
      width: 100%;
      max-width: 400px;
      padding: 48px 40px;
      border-radius: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
      border: 1px solid #EAF0F6;
      text-align: center;
    }

    .pwd-container h2 {
      font-size: 22px;
      font-weight: 800;
      color: #111827;
      margin-top: 0;
      margin-bottom: 12px;
    }

    .pwd-container p {
      font-size: 14px;
      color: #6B7280;
      margin-bottom: 32px;
      line-height: 1.5;
    }

    .form-group {
      text-align: left;
      margin-bottom: 24px;
    }

    .form-group label {
      display: block;
      font-size: 13px;
      font-weight: 700;
      color: #374151;
      margin-bottom: 8px;
    }

    /* 깔끔한 입력창 */
    .form-group input[type="password"] {
      width: 100%;
      padding: 14px 16px;
      border: 1px solid #D1D5DB;
      border-radius: 10px;
      font-size: 14px;
      box-sizing: border-box;
      transition: border-color 0.2s;
    }

    .form-group input[type="password"]:focus {
      outline: none;
      border-color: #8CBAF8; /* 하늘색 포커스 */
    }

    /* 요청하신 하늘색 -> 핑크색 그라데이션 버튼 */
    .btn-submit {
      width: 100%;
      padding: 16px;
      background: linear-gradient(90deg, #8CBAF8 0%, #F49DB3 100%);
      color: #FFFFFF;
      border: none;
      border-radius: 12px;
      font-size: 15px;
      font-weight: 700;
      cursor: pointer;
      transition: opacity 0.2s ease;
    }

    .btn-submit:hover {
      opacity: 0.85;
    }

    .btn-cancel {
      display: inline-block;
      margin-top: 20px;
      font-size: 13px;
      color: #6B7280;
      text-decoration: none;
      font-weight: 500;
    }

    .btn-cancel:hover {
      text-decoration: underline;
      color: #111827;
    }

    /* 에러 메시지 */
    .error-msg {
      color: #DC2626;
      font-size: 13px;
      font-weight: 600;
      margin-bottom: 24px;
    }
  </style>
</head>
<body>

<div class="pwd-container">
  <c:choose>
    <c:when test="${mode == 'dropout'}">
      <h2>회원 탈퇴</h2>
      <p>안전한 탈퇴 처리를 위해<br>현재 비밀번호를 다시 한번 입력해주세요.</p>
    </c:when>
    <c:otherwise>
      <h2>비밀번호 확인</h2>
      <p>안전한 개인정보 수정을 위해<br>현재 비밀번호를 다시 한번 입력해주세요.</p>
    </c:otherwise>
  </c:choose>

  <c:if test="${not empty message}">
    <div class="error-msg">⚠️ ${message}</div>
  </c:if>

  <form action="${pageContext.request.contextPath}/member/pwd" method="post">
    <input type="hidden" name="mode" value="${mode}">
    
    <div class="form-group">
      <label for="password">비밀번호</label>
      <input type="password" id="password" name="password" placeholder="비밀번호를 입력하세요" required autofocus>
    </div>
    
    <button type="submit" class="btn-submit">확인</button>
  </form>
  
  <a href="javascript:history.back()" class="btn-cancel">취소하고 이전 화면으로</a>
</div>

</body>
</html>