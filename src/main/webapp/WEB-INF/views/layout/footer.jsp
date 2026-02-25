<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<div id="footer" class="footer dark-background">
	<div class="container footer-top">
		<div class="row gy-4">
			<div class="col-lg-4 col-md-6 footer-about">
				<a href="${pageContext.request.contextPath}/" class="logo d-flex align-items-center">
					<span class="sitename">hShop</span>
				</a>
				<div class="footer-contact pt-3">
					<p>21, World Cup buk-ro</p>
					<p>Mapo-gu, Seoul, Republic of Korea</p>
					<p class="mt-3"><strong>Phone:</strong> <span>+82 1234 5648</span></p>
					<p><strong>Email:</strong> <span>info@example.com</span></p>
				</div>
				<div class="social-links d-flex mt-4">
					<a href="#"><i class="bi bi-twitter-x"></i></a>
					<a href="#"><i class="bi bi-facebook"></i></a>
					<a href="#"><i class="bi bi-instagram"></i></a>
					<a href="#"><i class="bi bi-linkedin"></i></a>
				</div>				
			</div>
			
			<div class="col-lg-2 col-md-3 footer-links">
				<h4>Useful Links</h4>
				<ul>
					<li><a href="#">Home</a></li>
					<li><a href="#">About</a></li>
					<li><a href="#">Map</a></li>
					<li><a href="#">Shopping</a></li>
					<li><a href="#">Weather</a></li>
				</ul>			
			</div>

			<div class="col-lg-2 col-md-3 footer-links">
				<h4>Help &amp; Information</h4>
				<ul>
					<li><a href="#">Help</a></li>
					<li><a href="#">Customer Service</a></li>					
					<li><a href="#">이용약관</a></li>
					<li><a href="#">전자금융거래약관</a></li>
					<li><a href="#">개인정보처리방침</a></li>
				</ul>
			</div>
			
			<div class="col-lg-4 col-md-12 footer-guide">
				<h4>Our Newsletter</h4>
				<p>hShop 회원이 되시면 쇼핑 혜택 및 서비스 소식을 받아볼수 있습니다.</p>
			</div>
		</div>
	</div>
	
	<div class="container copyright text-center mt-4">
		<p>© <span>Copyright</span> <strong class="px-1 sitename">hShop</strong> <span>All Rights Reserved</span></p>
	</div>
</div>

<!-- Scroll Top -->
<a href="#" id="scroll-top" class="scroll-top d-flex align-items-center justify-content-center"><i class="bi bi-arrow-up-short"></i></a>

<!-- Preloader -->
<div id="preloader"></div>
<div id="loadingLayout"></div>

<script type="text/javascript">
$(function(){
	// 상품명을 클릭한 경우
	$('.product-section').on('click', '.product-item-detial', function(){
		const $item = $(this).closest('.product-item');
		const productNum = $item.attr('data-productNum');
		
		let url = '${pageContext.request.contextPath}/products/' + productNum;
		location.href = url;
	});
	
	// 장바구니를 클릭한 경우
	$('.product-section').on('click', '.product-item-cart', function(){
		const $item = $(this).closest('.product-item');
		const productNum = $item.attr('data-productNum');
		
		let url = '${pageContext.request.contextPath}/products/' + productNum;
		location.href = url;
	});
});

// 찜
$(function(){
	// 상품 리스트에서 찜을 클릭한 경우
	$('.product-section').on('click', '.product-item-heart', function(){
		const $item = $(this).closest('.product-item');
		const productNum = $item.attr('data-productNum');
		
		const bLogin = Number('${empty sessionScope.member ? 0 : 1}') || 0;
		if(! bLogin) {
			location.href = '${pageContext.request.contextPath}/member/login';
			return false;
		}
		
		sendWish(productNum, $(this));
	});
	
	// 상품 상세 보기에서 찜을 클릭한 경우
	$('.btn-productBlind').on('click', function(){
		const productNum = $(this).attr('data-productNum');
		
		const bLogin = Number('${empty sessionScope.member ? 0 : 1}') || 0;
		if(! bLogin) {
			location.href = '${pageContext.request.contextPath}/member/login';
			return false;
		}
		
		sendWish(productNum, $(this));
	});
});

//  찜 등록 또는 해제
function sendWish(productNum, $el) {
	const bFlag = $el.find('i').hasClass('bi-heart-fill');
	
	let method, msg;
	if(bFlag) {
		method = 'delete';
		msg = '상품에 대한 찜을 해제 하시겠습니까 ?';
	} else {
		method = 'post';
		msg = '상품을 찜 목록에 등록하시겠습니까 ?';
	}
	
	if(! confirm(msg)) {
		return;
	}
	
	const params = {productNum: productNum};
	let url = '${pageContext.request.contextPath}/myShopping/wish/' + productNum;
	
	const fn = function(data) {
		const state = data.state;
		
		if(state === 'false') {
			return false;
		}
		
		if(bFlag) {
			$el.find('i').removeClass('bi-heart-fill text-danger').addClass('bi-heart');
		} else {
			$el.find('i').removeClass('bi-heart').addClass('bi-heart-fill text-danger');
		}
	};
	
	ajaxRequest(url, method, params, 'json', fn);	
}
</script>