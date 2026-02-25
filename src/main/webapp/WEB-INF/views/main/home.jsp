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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/shop.css" type="text/css">
<style type="text/css">
.product-img img {
  height: 250px;
  width: 100%;
}
@media (max-width: 991.98px) {
  .product-img img { height: 200px; }
}
@media (max-width: 767.98px) {
  .product-img img { height: 150px; }
}
</style>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<main>
	<div class="section bg-light">
		<!-- 점보 -->
		
		<!-- 오늘의 특가 -->
		<c:if test="${todayList.size() > 0}">
			<div class="container product-section">
				<div class="container product-section-title" data-aos="fade-up">
					<h2>오늘의 특가</h2>
					<a href="<c:url value='/specialList/200'/>" class="border-link">View All</a>
				</div>
				
				<div class="row gy-4" data-aos="fade-up" data-aos-delay="200">
					<c:forEach var="dto" items="${todayList}" varStatus="status">
						<div class="col-lg-4 col-md-6">
							<div class="product-item" data-productNum="${dto.productNum}">
								<div class="product-img h-100">
									<div class="img-top">
										<c:if test="${dto.discountRate >= 10}">
											<p class="sale">${dto.discountRate}% off</p>
										</c:if>
									</div>
									<img src="${pageContext.request.contextPath}/uploads/products/${dto.thumbnail}" class="img-fluid" alt="">
									<div class="product-action">
										<a class="product-item-cart cart-link" title="장바구니"><i class="bi bi-cart-plus"></i></a>
		                                <a class="product-item-heart heart-link" title="찜"><i class="bi ${dto.userWish==1 ? 'bi-heart-fill text-danger':'bi-heart'}"></i></a>
									</div>
								</div>
								<div class="product-info pt-3">
									<a class="product-item-detial text-truncate d-block fs-6">${dto.productName}</a>
									<div class="d-flex align-items-center mt-2">
										<h5 class="text-danger me-2">${dto.discountRate}%</h5>
										<h5><fmt:formatNumber value="${dto.salePrice}"/>원</h5>
										<h6 class="text-muted ms-2"><del><fmt:formatNumber value="${dto.price}"/>원</del></h6>
									</div>
									<div class="d-flex align-items-center mb-2">
										<fmt:parseNumber var="intScore" value="${dto.score}" integerOnly="true" type="number"/>
										<c:forEach var="i" begin="1" end="${intScore}">
											<i class="bi bi-star-fill"></i>
										</c:forEach>
										<c:if test="${dto.score -  intScore >= 0.5}">
											<i class="bi bi bi-star-half"></i>
											<c:set var="intScore" value="${intScore+1}"/>
										</c:if>
										<c:forEach var="i" begin="${intScore + 1}" end="5">
											<i class="bi bi-star"></i>
										</c:forEach>
										<small>(${dto.reviewCount})</small>
									</div>
									<div class="info-bottom">
										<div>${dto.delivery==0 ? "무료 배송" : "&nbsp;"}</div>
										<div>${dto.saleCount}개 구매</div>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</c:if>
				
		<!-- 기획전 -->
		<c:if test="${planList.size() > 0}">
			<div class="container product-section">
				<div class="container product-section-title" data-aos="fade-up">
					<h2>기획전</h2>
					<a href="<c:url value='/specialList/300'/>" class="border-link">View All</a>
				</div>
				
				<div class="row gy-4" data-aos="fade-up" data-aos-delay="200">
					<c:forEach var="dto" items="${planList}" varStatus="status">
						<div class="col-lg-4 col-md-6 ">
							<div class="product-item" data-productNum="${dto.productNum}">
								<div class="product-img h-100">
									<div class="img-top">
										<c:if test="${dto.discountRate >= 10}">
											<p class="sale">${dto.discountRate}% off</p>
										</c:if>
									</div>
									<img src="${pageContext.request.contextPath}/uploads/products/${dto.thumbnail}" class="img-fluid" alt="">
									<div class="product-action">
										<a class="product-item-cart cart-link" title="장바구니"><i class="bi bi-cart-plus"></i></a>
		                                <a class="product-item-heart heart-link" title="찜"><i class="bi ${dto.userWish==1 ? 'bi-heart-fill text-danger':'bi-heart'}"></i></a>
									</div>
								</div>
								<div class="product-info pt-3">
									<a class="product-item-detial text-truncate d-block fs-6">${dto.productName}</a>
									<div class="d-flex align-items-center mt-2">
										<h5 class="text-danger me-2">${dto.discountRate}%</h5>
										<h5><fmt:formatNumber value="${dto.salePrice}"/>원</h5>
										<h6 class="text-muted ms-2"><del><fmt:formatNumber value="${dto.price}"/>원</del></h6>
									</div>
									<div class="d-flex align-items-center mb-2">
										<fmt:parseNumber var="intScore" value="${dto.score}" integerOnly="true" type="number"/>
										<c:forEach var="i" begin="1" end="${intScore}">
											<i class="bi bi-star-fill"></i>
										</c:forEach>
										<c:if test="${dto.score -  intScore >= 0.5}">
											<i class="bi bi bi-star-half"></i>
											<c:set var="intScore" value="${intScore+1}"/>
										</c:if>
										<c:forEach var="i" begin="${intScore + 1}" end="5">
											<i class="bi bi-star"></i>
										</c:forEach>
										<small>(${dto.reviewCount})</small>
									</div>
									<div class="info-bottom">
										<div>${dto.delivery==0 ? "무료 배송" : "&nbsp;"}</div>
										<div>${dto.saleCount}개 구매</div>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</c:if>
				
		<!-- 추천 상품 -->
		<c:if test="${mainList.size() > 0}">
			<div class="container product-section">
				<div class="container product-section-title" data-aos="fade-up">
					<h2>추천 상품</h2>
				</div>
				
				<div class="row gy-4" data-aos="fade-up" data-aos-delay="200">
					<c:forEach var="dto" items="${mainList}" varStatus="status">
						<div class="col-lg-4 col-md-6 ">
							<div class="product-item" data-productNum="${dto.productNum}">
								<div class="product-img h-100">
									<div class="img-top">
										<c:if test="${dto.discountRate >= 10}">
											<p class="sale">${dto.discountRate}% off</p>
										</c:if>
									</div>
									<img src="${pageContext.request.contextPath}/uploads/products/${dto.thumbnail}" class="img-fluid" alt="">
									<div class="product-action">
										<a class="product-item-cart cart-link" title="장바구니"><i class="bi bi-cart-plus"></i></a>
		                                <a class="product-item-heart heart-link" title="찜"><i class="bi ${dto.userWish==1 ? 'bi-heart-fill text-danger':'bi-heart'}"></i></a>
									</div>
								</div>
								<div class="product-info pt-3">
									<a class="product-item-detial text-truncate d-block fs-6">${dto.productName}</a>
									<div class="d-flex align-items-center mt-2">
										<h5 class="text-danger me-2">${dto.discountRate}%</h5>
										<h5><fmt:formatNumber value="${dto.salePrice}"/>원</h5>
										<h6 class="text-muted ms-2"><del><fmt:formatNumber value="${dto.price}"/>원</del></h6>
									</div>
									<div class="d-flex align-items-center mb-2">
										<fmt:parseNumber var="intScore" value="${dto.score}" integerOnly="true" type="number"/>
										<c:forEach var="i" begin="1" end="${intScore}">
											<i class="bi bi-star-fill"></i>
										</c:forEach>
										<c:if test="${dto.score -  intScore >= 0.5}">
											<i class="bi bi bi-star-half"></i>
											<c:set var="intScore" value="${intScore+1}"/>
										</c:if>
										<c:forEach var="i" begin="${intScore + 1}" end="5">
											<i class="bi bi-star"></i>
										</c:forEach>
										<small>(${dto.reviewCount})</small>
									</div>
									<div class="info-bottom">
										<div>${dto.delivery==0 ? "무료 배송" : "&nbsp;"}</div>
										<div>${dto.saleCount}개 구매</div>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</c:if>
				
	</div>
</main>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>