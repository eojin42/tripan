<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Tripan - 숙소 리뷰</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .review-list-container { max-width: 800px; margin: 120px auto 80px; padding: 0 20px; }
        
        /* 통계 섹션 */
        .stats-card {
            background: rgba(255, 255, 255, 0.9); border-radius: 20px;
            padding: 30px; box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 40px; border: 1px solid #E2E8F0;
        }
        .stats-average { text-align: center; }
        .stats-average h2 { font-size: 48px; font-weight: 900; color: #2D3748; margin: 0; }
        .stats-average .stars { color: #FFD700; font-size: 24px; margin: 8px 0; }
        .stats-average p { color: #718096; font-size: 14px; margin: 0; }
        
        .stats-bars { font-size: 14px; color: #4A5568; line-height: 1.8; font-weight: 600; }
        
        /* 리뷰 리스트 */
        .review-item {
            background: white; border-radius: 16px; padding: 24px;
            margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid #E2E8F0;
        }
        .review-header { display: flex; justify-content: space-between; margin-bottom: 16px; }
        .reviewer-info { display: flex; flex-direction: column; }
        .reviewer-name { font-weight: 800; font-size: 16px; color: #2D3748; }
        .review-room { font-size: 13px; color: #718096; margin-top: 4px; }
        
        .review-meta { text-align: right; }
        .review-stars { color: #FFD700; font-size: 14px; }
        .review-date { font-size: 13px; color: #A0AEC0; margin-top: 4px; }
        
        /* 🚀 핵심: textarea에서 입력한 줄바꿈(\n)을 화면에 그대로 보여주는 속성 */
        .review-content { 
            font-size: 15px; color: #4A5568; line-height: 1.6; 
            margin-bottom: 16px; white-space: pre-wrap; word-break: break-all;
        }
        
        /* 첨부 이미지 갤러리 */
        .review-images { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 16px; }
        .review-images img {
            width: 120px; height: 120px; object-fit: cover;
            border-radius: 12px; border: 1px solid #E2E8F0; cursor: pointer;
            transition: transform 0.2s;
        }
        .review-images img:hover { transform: scale(1.05); }
        
        /* ✨ 추가할 숙소 요약 헤더 스타일 */
		.place-summary-card {
		    display: flex; align-items: center; gap: 24px;
		    background: white; border-radius: 20px; padding: 24px;
		    margin-bottom: 32px; box-shadow: 0 4px 16px rgba(45, 55, 72, 0.05);
		    border: 1px solid #E2E8F0;
		}
		.place-summary-img {
		    width: 100px; height: 100px; border-radius: 16px; overflow: hidden; flex-shrink: 0;
		}
		.place-summary-img img {
		    width: 100%; height: 100%; object-fit: cover;
		}
		.place-summary-info { display: flex; flex-direction: column; justify-content: center; }
		.place-summary-info h2 { font-size: 22px; font-weight: 900; color: #2D3748; margin-bottom: 8px; }
		.place-summary-info p { font-size: 14px; color: #718096; margin: 0; display: flex; align-items: center; gap: 4px; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="review-list-container">
	<div class="place-summary-card">
        <div class="place-summary-img">
            <img src="${placeInfo.imageUrl}" alt="숙소 이미지">
        </div>
        <div class="place-summary-info">
            <h2>${placeInfo.name}</h2>
            <p><i class="bi bi-geo-alt-fill"></i> ${placeInfo.region}</p>
        </div>
    </div>

    <h3 style="font-weight: 900; margin-bottom: 20px; color: #2D3748;">생생한 이용 후기</h3>
    
    <div class="stats-card">
        <div class="stats-average">
            <h2>${stats.avgRating}</h2>
            <div class="stars">
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi ${stats.avgRating >= 4.5 ? 'bi-star-fill' : 'bi-star-half'}"></i>
            </div>
            <p>총 ${stats.totalCount}개의 리뷰</p>
        </div>
        
        <div class="stats-bars">
            <div>5점 ⭐️⭐️⭐️⭐️⭐️ : ${stats.count5}개</div>
            <div>4점 ⭐️⭐️⭐️⭐️ : ${stats.count4}개</div>
            <div>3점 ⭐️⭐️⭐️ : ${stats.count3}개</div>
            <div>2점 ⭐️⭐️ : ${stats.count2}개</div>
            <div>1점 ⭐️ : ${stats.count1}개</div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty reviewList}">
            <div style="text-align: center; padding: 60px 20px; color: #A0AEC0; background: white; border-radius: 16px; border: 1px dashed #E2E8F0;">
                <i class="bi bi-chat-square-text" style="font-size: 48px; color: #CBD5E0;"></i>
                <p style="margin-top: 16px; font-size: 15px; font-weight: 600;">아직 작성된 리뷰가 없습니다.<br>첫 번째 리뷰의 주인공이 되어보세요!</p>
            </div>
        </c:when>
        
        <c:otherwise>
            <c:forEach var="review" items="${reviewList}">
                <div class="review-item">
                    <div class="review-header">
                        <div class="reviewer-info">
                            <span class="reviewer-name">${review.memberName}</span>
                            <span class="review-room">이용 객실: ${review.roomName}</span>
                        </div>
                        <div class="review-meta">
                            <div class="review-stars">
                                <c:forEach begin="1" end="5" var="i">
                                    <i class="bi ${i <= review.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                </c:forEach>
                            </div>
                            <div class="review-date">${review.createdAt}</div>
                        </div>
                    </div>
                    
                    <div class="review-content"><c:out value="${review.content}" /></div>
                    
                    <c:if test="${not empty review.imageUrls}">
                        <div class="review-images">
                            <c:forEach var="imgName" items="${review.imageUrls}">
                                <img src="${pageContext.request.contextPath}/uploads/review/${imgName}" alt="리뷰 첨부 사진">
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

</body>
</html>