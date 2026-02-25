<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>hShop</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<main>
	<div class="section bg-light">
		<div class="container">

			<div class="row justify-content-center" data-aos="fade-up" data-aos-delay="200">
				<div class="col-md-5">
					<div class="bg-white box-shadow my-5 p-5">
						<h3 class="text-center pt-3"><i class="bi bi-lock"></i> 회원 로그인</h3>
	                    
						<form name="loginForm" action="" method="post" class="row g-3 mb-2">
							<div class="col-12">
								<label class="mb-1">아이디</label>
								<input type="text" name="login_id" class="form-control" placeholder="아이디">
							</div>
							<div class="col-12">
								<label class="mb-1">패스워드</label>
								<input type="password" name="password" class="form-control" autocomplete="off" 
									placeholder="패스워드">
							</div>
							<div class="col-12">
								<div class="form-check">
									<input class="form-check-input rememberMe" type="checkbox" id="rememberMe">
									<label class="form-check-label" for="rememberMe"> 아이디 저장</label>
								</div>
							</div>
							<div class="col-12 text-center">
								<button type="button" class="btn-accent btn-lg w-100" onclick="sendLogin();">&nbsp;Login&nbsp;<i class="bi bi-check2"></i></button>
							</div>
							<div class="col-12 d-flex justify-content-between">
								<button type="button" class="btn-light flex-fill me-2"><i class="bi bi-chat-fill kakao-icon"></i> 카카오</button>
								<button type="button" class="btn-light flex-fill me-2"><span class="naver-icon">N</span> 네이버</button>
								<button type="button" class="btn-light flex-fill"><i class="bi bi-google google-icon"></i> 구 글</button>
							</div>
						</form>
	                    
						<div>
							<p class="form-control-plaintext text-center text-danger">${message}</p>
						</div>

						<div class="mt-3">
							<p class="text-center">
								<a href="${pageContext.request.contextPath}/" class="me-2 border-link-right">아이디 찾기</a>
								<a href="${pageContext.request.contextPath}/member/pwdFind" class="me-2 border-link-right">패스워드 찾기</a>
								<a href="${pageContext.request.contextPath}/member/account" class="border-link-right">회원가입</a>
							</p>
						</div>
	                    
					</div>
	
				</div>
			</div>

		</div>
	</div>
</main>

<script type="text/javascript">
function sendLogin() {
    const f = document.loginForm;
    
    if( ! f.login_id.value.trim() ) {
        f.login_id.focus();
        return;
    }

    if( ! f.password.value.trim() ) {
        f.password.focus();
        return;
    }

    const saveIdChk = document.getElementById("rememberMe").checked;
	if (saveIdChk) {
		localStorage.setItem("savedLoginId", f.login_id.value.trim());
	} else {
		localStorage.removeItem("savedLoginId");
	}	    
    
    f.action = '${pageContext.request.contextPath}/member/login';
    f.submit();
}
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>