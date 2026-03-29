<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
#tab-review {
    background: #F1F5F9;
    padding: 24px;
    border-radius: 16px;
}

.search-filter-box form {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    align-items: center;
}

.search-filter-box input,
.search-filter-box select {
    padding: 10px 12px;
    border: 1px solid #E2E8F0;
    border-radius: 10px;
    font-size: 13px;
    background: #F9FAFB;
    transition: all 0.2s;
}

.search-filter-box input:focus,
.search-filter-box select:focus {
    outline: none;
    border-color: #6366F1;
    background: #fff;
    box-shadow: 0 0 0 2px rgba(99,102,241,0.15);
}

.search-filter-box input[type="text"] {
    flex: 1;
    min-width: 180px;
}

.search-filter-box button {
    padding: 10px 18px;
    background: #6366F1;
    color: white;
    border: none;
    border-radius: 10px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.2s;
}

.search-filter-box button:hover {
    background: #4F46E5;
}

.search-filter-box a {
    padding: 10px 14px;
    background: #fff;
    border: 1px solid #E2E8F0;
    border-radius: 10px;
    color: #64748B;
    text-decoration: none;
    font-weight: 600;
    transition: 0.2s;
}

.search-filter-box a:hover {
    background: #F1F5F9;
}

.search-filter-box span {
    color: #64748B;
    font-weight: 600;
}

.search-filter-box {
    background: #FFFFFF;
    border: 1px solid #E2E8F0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    padding: 20px;
    border-radius: 14px;
}

.review-card {
    background: #FFFFFF;
    border-radius: 16px;
    border: 1px solid #E5E7EB;
    padding: 20px;
    transition: all 0.2s ease;
    border-left: 4px solid #6366F1;
}

.review-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
}

.review-content {
    background: #F8FAFC;
    border: 1px solid #E2E8F0;
    border-radius: 12px;
    padding: 16px;
    margin-top: 12px;
    white-space: pre-wrap; 
    word-break: break-all;
}

.btn-delete {
    background: #FEF2F2;
    border: 1px solid #FCA5A5;
    color: #DC2626;
    font-weight: 700;
    border-radius: 10px;
    padding: 6px 12px;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-delete:hover {
    background: #DC2626;
    color: white;
}

.star {
    color: #F59E0B;
    letter-spacing: 2px;
    font-weight: 900;
}

.review-author {
    font-weight: 800;
    color: #111827;
}

.review-meta {
    font-size: 13px;
    color: #94A3B8;
}
</style>

<div id="tab-review" class="page-section ${activeTab == 'review' ? 'active' : ''}">
    
    <div style="margin-bottom: 20px;">
        <h1 style="font-size: 26px; font-weight: 900;">⭐ 리뷰 관리</h1>
        <p style="color: #64748B;">고객 리뷰를 관리하고 부적절한 리뷰를 삭제할 수 있습니다.</p>
    </div>

	<div class="search-filter-box">
        <form action="main" method="GET" style="display: flex; gap: 10px; flex-wrap: wrap; align-items: center;">
            <input type="hidden" name="tab" value="review">
            <input type="hidden" name="page" id="page" value="${empty param.page ? 1 : param.page}">
            <input type="date" name="startDate" value="<c:out value='${param.startDate}'/>">
            <input type="date" name="endDate" value="<c:out value='${param.endDate}'/>">

            <select name="roomId">
                <option value="">객실 전체</option>
                <c:forEach var="room" items="${roomList}">
                    <option value="${room.roomId}" ${param.roomId == room.roomId ? 'selected' : ''}>
                        <c:out value="${room.roomName}"/>
                    </option>
                </c:forEach>
            </select>

            <select name="rating">
                <option value="">별점 전체</option>
                <option value="5" ${param.rating == '5' ? 'selected' : ''}>5점</option>
                <option value="4" ${param.rating == '4' ? 'selected' : ''}>4점</option>
                <option value="3" ${param.rating == '3' ? 'selected' : ''}>3점</option>
                <option value="2" ${param.rating == '2' ? 'selected' : ''}>2점</option>
                <option value="1" ${param.rating == '1' ? 'selected' : ''}>1점</option>
            </select>

            <input type="text" name="keyword" value="<c:out value='${param.keyword}'/>" placeholder="검색">

            <button type="submit">검색</button>
            <a href="?tab=review">초기화</a>
			
			<select name="limit" onchange="document.getElementById('page').value=1; this.form.submit();">
			    <option value="10" ${param.limit == '10' ? 'selected' : ''}>10개씩 보기</option>
			    <option value="30" ${param.limit == '30' ? 'selected' : ''}>30개씩 보기</option>
			    <option value="50" ${param.limit == '50' ? 'selected' : ''}>50개씩 보기</option>
			</select>
						
        </form>
    </div>

    <div style="margin-top: 20px; display: flex; flex-direction: column; gap: 16px;">
        
        <c:choose>
            <c:when test="${not empty reviewList}">
                <c:forEach var="review" items="${reviewList}">

                    <div class="review-card">
                        
						<div style="display:flex; justify-content:space-between;">
						    
						    <div>
						        <div style="display:flex; gap:8px; align-items:center;">
						            <span class="star">
						                <c:forEach begin="1" end="${review.rating}">★</c:forEach>
						                <c:forEach begin="1" end="${5 - review.rating}">
						                    <span style="color:#E5E7EB;">★</span>
						                </c:forEach>
						            </span>
						            <span class="review-author"><c:out value="${review.memberName}"/></span>
						        </div>
						        <div class="review-meta">
						            ${review.createdAt} | <c:out value="${review.roomName}"/>
						        </div>
						    </div>

						    <div style="display: flex; gap: 8px; height: fit-content;">
						        <a href="${pageContext.request.contextPath}/accommodation/review/list/${review.placeId}?tab=review" 
						           target="_blank" 
						           style="background: #F8FAFC; border: 1px solid #E2E8F0; color: #475569; font-size: 13px; font-weight: 700; border-radius: 10px; padding: 6px 12px; text-decoration: none; transition: all 0.2s; display: flex; align-items: center;">
						            리뷰 보러 가기 ↗
						        </a>
						        
						        <button class="btn-delete" onclick="deleteReview('${review.reviewId}')">
						            삭제
						        </button>
						    </div>

						</div>

                        <div class="review-content"><c:out value="${review.content}"/></div>

                    </div>

                </c:forEach>
            </c:when>

            <c:otherwise>
                <div style="text-align:center; padding:40px; background:#fff; border-radius:12px;">
                    리뷰 없음
                </div>
            </c:otherwise>
        </c:choose>
		
		<div id="reviewPaginationArea"></div>

    </div>
</div>

<script>
	
document.addEventListener('DOMContentLoaded', function() {
    const totalPages = parseInt('${empty totalPages ? 0 : totalPages}');
    const currentPage = parseInt('${empty param.page ? 1 : param.page}');

    if (typeof renderPagination === 'function') {
        renderPagination(totalPages, currentPage, 'reviewPaginationArea', movePage);
    }
});

function movePage(pageNo) {
    const form = document.querySelector('.search-filter-box form');
    
    let pageInput = form.querySelector('input[name="page"]');
    if (!pageInput) {
        pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        form.appendChild(pageInput);
    }
    
    pageInput.value = pageNo;
    form.submit();
}
function deleteReview(reviewId) {
    if(confirm("삭제하시겠습니까?")) {
        fetch('${pageContext.request.contextPath}/partner/api/review/delete', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'AJAX': 'true'
            },
            body: JSON.stringify({ reviewId: reviewId }) 
        })
        .then(res => {
            if (!res.ok) throw new Error('서버 응답 오류');
            return res.json();
        })
        .then(data => {
            if(data.message === 'success') {
                alert("삭제 완료");
                location.reload();
            } else {
                alert("실패: " + data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("삭제중 오류가 발생했습니다.");
        });
    }
}
</script>