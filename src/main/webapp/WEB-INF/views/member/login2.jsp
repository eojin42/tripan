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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/login-full.css" type="text/css">
</head>
<body>

<main class="full-main">
	<div class="card-container">
		<div class="full-main-bg">
			<div class="large-circle-1"></div>
			<div class="small-circle-1"></div>
			<div class="large-circle-2"></div>
			<div class="small-circle-2"></div>
		</div>	
	
		<div class="card-wrapper">
			<div class="card-header">
				<a href="<c:url value='/' />">
					<span class="brand-icon"><i class="bi bi-stars"></i></span>
					<span class="brand-name">Spring</span>
				</a>
			</div>
			
			<div class="login-form">
				<div class="login-form-header">
					<h3>Login</h3>
				</div>
				<div class="login-form-body">
				
					<form name="loginForm" action="" method="post" class="row g-3">
						<div>
							<input type="text" name="login_id" class="form-control" placeholder="아이디">
						</div>
						<div>
							<input type="password" name="password" class="form-control" autocomplete="off" placeholder="패스워드">
						</div>
						<div class="d-flex justify-content-between">
							<div class="form-check">
								<input class="form-check-input rememberMe" type="checkbox" id="rememberMe">
								<label class="form-check-label" for="rememberMe"> 아이디 저장</label>
							</div>
							<div>
								<a href="${pageContext.request.contextPath}/" class="border-link-right">아이디 찾기</a>
							</div>
						</div>
						<div>
							<button type="button" class="btn-accent btn-lg w-100" onclick="sendLogin();">Login</button>
						</div>
						<div class="d-flex justify-content-between">
							<button type="button" class="btn-light flex-fill me-2"><i class="bi bi-chat-fill kakao-icon"></i> 카카오</button>
							<button type="button" class="btn-light flex-fill me-2"><span class="naver-icon">N</span> 네이버</button>
							<button type="button" class="btn-light flex-fill"><i class="bi bi-google google-icon"></i> 구 글</button>
						</div>
                        
						<div>
							<p class="form-control-plaintext text-center text-danger p-0">
								<small>${message}</small>
							</p>
							<p class="form-control-plaintext text-center">
								<a href="${pageContext.request.contextPath}/member/pwdFind" class="border-link-right me-2">패스워드를 잊으셨나요 ?</a>
							</p>
						</div>
					</form>
				</div>
				<div class="login-form-footer">
					<p class="form-control-plaintext text-center">
						아직 회원이 아니세요 ?
						<a href="${pageContext.request.contextPath}/member/account" class="border-link-right">회원가입</a>
					</p>
				</div>
			</div>
			
		</div>
	</div>
</main>

<script type="text/javascript">
window.addEventListener('DOMContentLoaded', ev => {
	const savedId = localStorage.getItem("savedLoginId");

	if (savedId) {
		const login_idELS = document.querySelectorAll('form input[name=login_id]') || [];
		const saveIdELS = document.querySelectorAll('form .rememberMe') || [];
		
		for(let el of saveIdELS) {
			el.checked = true;
		}
		
		for(let el of login_idELS) {
			el.value = savedId;
		}
	}
});

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

<!-- Vendor JS Files -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.6/dist/js/bootstrap.bundle.min.js"></script>	
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>

</body>
</html>