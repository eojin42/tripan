<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<style type="text/css">
  .category-list ul { padding: 0; }
  .category-list li { list-style: none; }
	
  .menu-item { border-radius: 3px; background-color: #fff; border: 1px solid #ddd; margin-bottom: -1px; }
  .menu-link { display: block; color: #666; font-weight: 500px; cursor: pointer; padding: 10px 15px; }
  .menu-link:hover { color: #000; background: #e9e9e9; }
  .menu-item .opened { color: #fff; font-weight: 500; background-color: #007bff; border-color: #337ab7; 
			border-bottom: 1px solid #ddd; border-color: #d5d5d5; border-radius: 3px; }
	
  .sub-menu { display: none; }
  .sub-menu .active { color: #000; }
  .sub-menu-item { cursor: pointer; padding: 10px 20px; background: #f8f9fa; }
  .sub-menu-link { font-weight: 500; color: #666; }
  .sub-menu-item:hover, .sub-menu-link:hover { color: #000; text-decoration: none; }
</style>
	
<div class="container-fluid py-2 px-5 wow fadeIn header-top" data-wow-delay="0.1s">
	<div class="container">
		<div class="row align-items-center">
			<div class="col d-none d-md-flex contact-info">
				<i class="bi bi-telephone-inbound-fill"></i>&nbsp;<span>+82-1234-5678</span>
			</div>
			
			<div class="col">
				<div class="d-flex justify-content-end header-top-links">
					<c:choose>
						<c:when test="${empty sessionScope.member}">
							<a href="javascript:dialogLogin();" title="로그인" title="로그인"><i class="bi bi-lock"></i></a>
							<a href="${pageContext.request.contextPath}/member/account" title="회원가입"><i class="bi bi-person-plus"></i></a>
						</c:when>
						<c:otherwise>
							<a href="#" title="알림"><i class="bi bi-bell"></i></a>
							<a href="${pageContext.request.contextPath}/member/logout" title="로그아웃"><i class="bi bi-unlock"></i></a>
							<c:if test="${sessionScope.member.userLevel>50}">
								<a href="${pageContext.request.contextPath}/admin" title="관리자"><i class="bi bi-gear"></i></a>
							</c:if>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</div>
	</div>
</div>

<div id="header" class="header d-flex align-items-center sticky-top">
	<div class="container position-relative d-flex align-items-center justify-content-between">
		<a href="<c:url value='/' />" class="logo d-flex align-items-center me-auto me-xl-0">
			<span class="sitename"><label class="text-danger">h</label><label>Shop</label></span><span class="dot">.</span>
		</a>
		
		<nav id="navmenu" class="navmenu">
			<ul>
				<li><a href="<c:url value='/' />">홈</a></li>
				<li><a data-bs-toggle="offcanvas" href="#offcanvasCategory" aria-controls="offcanvasCategory">카테고리</a></li>
				<li><a href="<c:url value='/display/best' />">베스트</a></li>
				<li><a href="<c:url value='/display/special/200' />">오늘의 특가</a></li>
				<li><a href="<c:url value='/display/special/300' />">기획전</a></li>
				<li class="dropdown">
					<a href="#"><span>혜택</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
					<ul>
						<li><a href="<c:url value='/' />">쿠폰 혜택</a></li>
						<li><a href="<c:url value='/' />">쇼핑 혜택</a></li>
						<li><a href="<c:url value='/' />">이벤트</a></li>
						<li><hr class="dropdown-divider"></li>
						<li><a href="<c:url value='/' />">당첨자 발표</a></li>
					</ul>	
				</li>
				<li class="dropdown">
					<a href="#"><span>고객센터</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
					<ul>
						<li><a href="<c:url value='/' />">자주하는질문</a></li>
						<li><a href="<c:url value='/' />">공지사항</a></li>
						<li><a href="<c:url value='/' />">1:1문의</a></li>
						<li><a href="<c:url value='/' />">고객의 소리</a></li>
						<li><hr class="dropdown-divider"></li>
						<li><a href="${pageContext.request.contextPath}/">실시간 문의</a></li>
					</ul>	
				</li>
			</ul>
			<i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
		</nav>
		
		<div class="d-flex align-items-center header-right">
			<div class="header-account-links">
				<a href="#" title="검색" data-bs-toggle="offcanvas" data-bs-target="#offcanvasTop" aria-controls="offcanvasTop"><i class="bi bi-search"></i></a>
				<a href="<c:url value='/myShopping/cart'/>" title="장바구니"><i class="bi bi-cart"></i></a>			
			</div>
			<c:if test="${not empty sessionScope.member}">
				<div class="header-avatar">
					<c:choose>
						<c:when test="${not empty sessionScope.member.avatar}">
							<img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.member.avatar}" 
							onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/dist/images/avatar.png';"
							class="avatar-sm dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
						</c:when>
						<c:otherwise>
							<img src="${pageContext.request.contextPath}/dist/images/avatar.png" class="avatar-sm dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
						</c:otherwise>
					</c:choose>
					<ul class="dropdown-menu">
						<li><a href="<c:url value='/myPage/paymentList' />" class="dropdown-item">주문/배송내역</a></li>
						<li><a href="<c:url value='/myPage/review'/>" class="dropdown-item">리뷰/상품문의</a></li>
						<li><a href="<c:url value='/myShopping/main' />" class="dropdown-item">나의쇼핑</a></li>
						<li><a href="<c:url value='/' />" class="dropdown-item">쪽지</a></li>
						<li><hr class="dropdown-divider"></li>
						<li><a href="<c:url value='/member/pwd'/>" class="dropdown-item">정보수정</a></li>
					</ul>
				</div>
			</c:if>
		</div>
	</div>
</div>

<!-- 검색 -->
<div class="offcanvas offcanvas-top" tabindex="-1" id="offcanvasTop" aria-labelledby="offcanvasTopLabel">
	<div class="offcanvas-header">
		<button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
	</div>
	<div class="offcanvas-body">
		<div class="container">
			<div class="d-flex justify-content-center mb-2">
				<form name="headerSearchForm" class="form-group-search w-50 align-items-center">
					<input type="text" name="searchWord" class="form-control" placeholder="검색어를 입력하세요" value="">
					<button type="button" onclick="searchHeaderList();"><i class="bi bi-search"></i></button>
					<input type="hidden" name="searchField" value="all">
				</form>
			</div>
			
			<ul class="header-search-list">
				<li class="search-list-item">
					<a href="#" onclick="searchHeaderItem('여성의류');" class="border-link-down" title="여성의류">여성의류</a>
				</li>
				<li class="search-list-item">
					<a href="#" onclick="searchHeaderItem('남성의류');" class="border-link-down" title="남성의류">남성의류</a>
				</li>
				<li class="search-list-item">
					<a href="#" onclick="searchHeaderItem('아동의류');" class="border-link-down" title="아동의류">아동의류</a>
				</li>
				<li class="search-list-item">
					<a href="#" onclick="searchHeaderItem('여성런닝화');" class="border-link-down" title="여성런닝화">여성런닝화</a>
				</li>
				<li class="search-list-item">
					<a href="#" onclick="searchHeaderItem('남성런닝화');" class="border-link-down" title="남성런닝화">남성런닝화</a>
				</li>
			</ul>
		</div>
	</div>
</div>

<script type="text/javascript">
// 검색
document.addEventListener('DOMContentLoaded', () => {
	const inputEL = document.querySelector('form[name=headerSearchForm] input[name=searchWord]'); 
	inputEL.addEventListener('keydown', function (evt) {
		if(evt.key === 'Enter') {
			evt.preventDefault();
	    	
			searchHeaderList();
		}
	});
});

function searchHeaderItem(kwd) {
	const f = document.headerSearchForm;
	f.searchWord.value = kwd;
}

function searchHeaderList() {
	const f = document.headerSearchForm;
	if(! f.searchWord.value.trim()) {
		return;
	}
	
	// form 요소는 FormData를 이용하여 URLSearchParams 으로 변환
	const formData = new FormData(f);
	let params = new URLSearchParams(formData).toString();
	
	let url = '${pageContext.request.contextPath}/search';
	location.href = url + '?' + params;
}
</script>

<!-- 좌측 카테고리 오프캔버스 -->
<div class="offcanvas offcanvas-start" tabindex="-1" id="offcanvasCategory" aria-labelledby="offcanvasCategoryLabel">
	<div class="offcanvas-header">
		<h5 class="offcanvas-title" id="offcanvasCategoryLabel"><i class="bi bi-list-ul"></i> 상품 카테고리</h5>
		<button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
	</div>
	<div class="offcanvas-body">
		<div class="d-flex flex-column bd-highlight mt-3 mx-0 px-4">
			<ul class="category-list px-0"></ul>
		</div>
	</div>
</div>

<script type="text/javascript">
// 좌측 카테고리 오프캔버스 : 상품 카테고리
$(function(){
	const myOffcanvas = document.getElementById('offcanvasCategory');
	myOffcanvas.addEventListener('shown.bs.offcanvas', function () {
		let url = '${pageContext.request.contextPath}/products/listAllCategory';
	
		$.get(url, null, function(data){
			let out = '';
			let listUrl = '${pageContext.request.contextPath}/products/main?categoryNum=';
	
			let listMain = data.listMain;
			let listAll = data.listAll;

			$(listMain).each(function(index, item){
				let categoryNum = item.categoryNum;
				let categoryName = item.categoryName;
						
				// let opened = index === 0 ? 'opened' : '';
				let opened = '';
						
				out += '<li class="menu-item">';
				out +=   '<label class="menu-link ' + opened + '">';
				out +=     '<span class="menu-label">' + categoryName + "</span>";
				out +=   '</label>';
				out +=   '<ul class="sub-menu">';
						
				$(listAll).each(function(index, item){
					let subNum = item.categoryNum;
					let subName = item.categoryName;
					let parentNum = item.parentNum;
							
					if(categoryNum === parentNum) {
						out += '<li class="sub-menu-item"><a href="' + listUrl + subNum 
								+ '" class="sub-menu-link">' + subName + '</a></li>';
					}
				});
						
				out +=   '</ul>';
				out += '</li>';
			});
					
			$('.category-list').html(out);
			
			// $('.category-list .opened').siblings('.sub-menu').show();
			// $('.category-list .opened').siblings('.sub-menu').first().find('a').first().addClass('active');
					
		}, 'json');
	});
			
	$('.category-list').on('click', '.menu-item', function(){
		const $menu = $(this);
		const bOpened = $menu.find('.menu-link').hasClass('opened');
		
		$('.category-list .menu-link').removeClass('opened');
		$('.category-list .sub-menu').hide();
		
		if(! bOpened) {
			$menu.find('.menu-link').addClass('opened');
			$menu.find('.sub-menu').fadeIn(500);
		}
	});
});
</script>

<!-- 로그인 -->
<div class="modal fade" id="loginModal" tabindex="-1"
		data-bs-backdrop="static" data-bs-keyboard="false" 
		aria-labelledby="loginModalLabel" aria-hidden="true">
	<div class="modal-dialog modal-sm">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="loginViewerModalLabel">Login</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<div class="modal-body">
				<div class="p-3">
					<form name="modalLoginForm" action="" method="post" class="row g-3">
						<div class="mt-0">
							<p class="form-control-plaintext">계정으로 로그인 하세요</p>
						</div>
						<div class="mt-0">
							<input type="text" name="login_id" class="form-control" placeholder="아이디">
						</div>
						<div>
							<input type="password" name="password" class="form-control" autocomplete="off" 
								placeholder="패스워드">
						</div>
						<div>
							<div class="form-check">
								<input class="form-check-input rememberMe" type="checkbox" id="rememberMeModal">
								<label class="form-check-label" for="rememberMeModal"> 아이디 저장</label>
							</div>
						</div>
						<div>
							<button type="button" class="btn btn-primary w-100" onclick="sendModalLogin();">Login</button>
						</div>
						<div class="d-flex justify-content-between">
								<button type="button" class="btn-light flex-fill me-2" title="Kakao"><i class="bi bi-chat-fill kakao-icon"></i></button>
								<button type="button" class="btn-light flex-fill me-2" title="NAVER"><span class="naver-icon">N</span></button>
								<button type="button" class="btn-light flex-fill" title="Google"><i class="bi bi-google google-icon"></i></button>
						</div>
						<div>
							<p class="form-control-plaintext text-center">
								<a href="${pageContext.request.contextPath}/" class="text-primary text-decoration-none me-2">패스워드를 잊으셨나요 ?</a>
							</p>
						</div>
					</form>
					<hr class="mt-3">
					<div>
						<p class="form-control-plaintext mb-0">
							아직 회원이 아니세요 ?
							<a href="${pageContext.request.contextPath}/member/account" class="text-primary text-decoration-none">회원가입</a>
						</p>
					</div>
				</div>
        
			</div>
		</div>
	</div>
</div>		

<!-- Login Modal -->
<script type="text/javascript">
	document.addEventListener('DOMContentLoaded', ev => {
		const savedId = localStorage.getItem("savedLoginId");

		if (savedId) {
			const login_idELS = document.querySelectorAll('form[name=modalLoginForm] input[name=login_id], form[name=loginForm] input[name=login_id]') || [];
			const saveIdELS = document.querySelectorAll('form .rememberMe') || [];
			
			for(let el of saveIdELS) {
				el.checked = true;
			}
			
			for(let el of login_idELS) {
				el.value = savedId;
			}
		}
	});

	function dialogLogin() {
		// document.querySelector('form[name="modalLoginForm"] input[name="login_id"]').value = '';
		document.querySelector('form[name="modalLoginForm"] input[name="password"]').value = '';
		    
		const loginModalEl = document.getElementById('loginModal');
		const loginModal = bootstrap.Modal.getOrCreateInstance(loginModalEl);
		loginModal.show();			
			
		document.querySelector('form[name="modalLoginForm"] input[name="login_id"]').focus();
	}

	function sendModalLogin() {
		const f = document.modalLoginForm;
	    
		if(! f.login_id.value.trim()) {
			f.login_id.focus();
			return;
		}
	
		if(! f.password.value.trim()) {
			f.password.focus();
			return;
		}
	    
		const saveIdChk = document.getElementById("rememberMeModal").checked;
		if (saveIdChk) {
			localStorage.setItem("savedLoginId", f.login_id.value.trim());
		} else {
			localStorage.removeItem("savedLoginId");
		}	    
	
		f.action = '${pageContext.request.contextPath}/member/login';
		f.submit();
	}
</script>
