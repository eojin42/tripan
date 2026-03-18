<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Tripan - 숙소 리뷰</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        /* 🚀 2단 레이아웃을 위해 넓이를 좀 더 넓게 설정 */
        .review-page-wrapper {
            max-width: 1100px;
            margin: 120px auto 80px;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 340px 1fr; /* 좌측 340px, 우측 나머지 넓이 */
            gap: 40px;
            align-items: start; /* sticky 적용을 위해 start 필수 */
        }
        
        /* ================== 좌측 사이드바 (고정) ================== */
        .left-sidebar {
            position: sticky;
            top: 100px; /* 헤더 높이만큼 띄워줌 */
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* 숙소 요약 카드 - 세로형 사진 큼지막하게 */
        .place-summary-card {
            background: white; border-radius: 20px; padding: 20px;
            box-shadow: 0 4px 20px rgba(45, 55, 72, 0.04);
            border: 1px solid #E2E8F0;
        }
        .place-summary-img {
            width: 100%; height: 180px; border-radius: 12px; overflow: hidden; margin-bottom: 16px;
        }
        .place-summary-img img { width: 100%; height: 100%; object-fit: cover; }
        .place-summary-info h2 { font-size: 20px; font-weight: 900; color: #2D3748; margin-bottom: 8px; }
        .place-summary-info p { font-size: 13px; color: #718096; margin: 0; display: flex; align-items: center; gap: 4px; }

        /* 통계 섹션 */
        .stats-card {
            background: white; border-radius: 20px; padding: 24px;
            box-shadow: 0 4px 20px rgba(45, 55, 72, 0.04);
            border: 1px solid #E2E8F0;
        }
        .stats-average { text-align: center; padding-bottom: 20px; border-bottom: 1px solid #F1F5F9; margin-bottom: 20px; }
        .stats-average h2 { font-size: 48px; font-weight: 900; color: #2D3748; margin: 0; line-height: 1; }
        .stats-average .stars { color: #FFD700; font-size: 20px; margin: 8px 0; }
        .stats-average p { color: #A0AEC0; font-size: 13px; font-weight: 600; margin: 0; }
        
        /* 🚀 시각화된 프로그레스 바 디자인 */
        .rating-bar-row {
            display: flex; align-items: center; gap: 12px; margin-bottom: 10px; font-size: 13px; font-weight: 700; color: #4A5568;
        }
        .rating-label { width: 30px; text-align: right; }
        .progress-track {
            flex: 1; height: 8px; background: #EDF2F7; border-radius: 4px; overflow: hidden;
        }
        .progress-fill {
            height: 100%; background: #FFD700; border-radius: 4px;
        }
        .rating-count { width: 30px; color: #A0AEC0; font-size: 12px; }

        /* ================== 우측 본문 (스크롤) ================== */
        .right-content {
            display: flex;
            flex-direction: column;
        }
        .section-title {
            font-size: 22px; font-weight: 900; color: #2D3748; margin-bottom: 24px;
        }

        /* 리뷰 아이템 */
        .review-item {
            background: white; border-radius: 20px; padding: 28px;
            margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.02);
            border: 1px solid #E2E8F0; transition: transform 0.2s;
        }
        .review-item:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.05); }
        .review-header { display: flex; justify-content: space-between; margin-bottom: 20px; }
        .reviewer-info { display: flex; flex-direction: column; }
        .reviewer-name { font-weight: 800; font-size: 16px; color: #2D3748; }
        .review-room { font-size: 13px; color: #89CFF0; font-weight: 700; background: rgba(137, 207, 240, 0.1); padding: 4px 10px; border-radius: 8px; margin-top: 6px; display: inline-block; width: fit-content; }
        
        .review-meta { text-align: right; }
        .review-stars { color: #FFD700; font-size: 14px; }
        .review-date { font-size: 12px; color: #A0AEC0; margin-top: 4px; }
        
        .review-content { 
            font-size: 15px; color: #4A5568; line-height: 1.6; 
            margin-bottom: 20px; white-space: pre-wrap; word-break: break-all;
        }
        
        /* 갤러리 뷰 개선 */
        .review-images { display: flex; gap: 10px; flex-wrap: wrap; }
        .review-images img {
            width: 100px; height: 100px; object-fit: cover;
            border-radius: 12px; border: 1px solid #E2E8F0; cursor: pointer;
            transition: all 0.2s;
        }
        .review-images img:hover { transform: scale(1.05); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        
        @media (max-width: 992px) {
            .review-page-wrapper {
                grid-template-columns: 1fr; /* 2단을 1단으로 꽉 차게 변경 */
                gap: 24px;
                margin-top: 100px;
            }
            .left-sidebar {
                position: relative; /* 모바일에서는 따라다니는 sticky 효과 해제 */
                top: 0;
            }
            .place-summary-img {
                height: auto;
                aspect-ratio: 16 / 9; /* 세로형 이미지를 가로로 넓게 시원하게 변경 */
            }
        }

        /* 스마트폰 크기 (화면 폭 576px 이하) */
        @media (max-width: 576px) {
            .review-page-wrapper {
                padding: 0 16px;
            }
            .review-item {
                padding: 20px; /* 모바일 화면에 맞춰 패딩 축소 */
            }
            .review-header {
                flex-direction: column; /* 양옆으로 퍼져있던 정보를 위아래로 배치 */
                align-items: flex-start;
                gap: 12px;
            }
            .review-meta {
                text-align: left; /* 별점과 날짜를 왼쪽 정렬로 변경 */
            }
            .stats-average h2 {
                font-size: 38px; /* 통계 숫자 크기 살짝 축소 */
            }
            .review-images img {
                width: 80px; /* 첨부 이미지 썸네일 크기 축소 */
                height: 80px;
            }
            .section-title {
                font-size: 20px;
            }
        }
        
        /* 정렬 셀렉트 박스 스타일 */
		.review-list-header { 
		    display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; 
		}
		.sort-select { 
		    padding: 8px 16px; border: 1px solid #E2E8F0; border-radius: 12px; font-size: 14px; 
		    font-weight: 600; color: #4A5568; outline: none; cursor: pointer; background: white;
		}
		
		/* 수정/삭제 버튼 스타일 */
		.review-actions { display: flex; gap: 8px; margin-top: 12px; justify-content: flex-end; }
		.btn-review-action { 
		    font-size: 12px; padding: 6px 12px; border-radius: 8px; cursor: pointer; 
		    border: 1px solid #E2E8F0; background: white; color: #718096; font-weight: 600;
		}
		.btn-review-action:hover { background: #F8FAFC; color: #2D3748; }
		.btn-review-delete:hover { color: #E53E3E; border-color: #FEB2B2; background: #FFF5F5; }
		
		/* 내가 쓴 글 뱃지 */
		.my-review-badge {
		    font-size: 11px; background: #89CFF0; color: white; padding: 2px 8px; 
		    border-radius: 4px; margin-left: 8px; vertical-align: middle;
		}
		
		/*  페이징 처리 CSS */
        .paginate { 
            text-align: center; margin-top: 40px; 
            display: flex; justify-content: center; align-items: center; gap: 8px; 
        }
        .paginate a, .paginate span { 
            display: inline-flex; align-items: center; justify-content: center; 
            width: 36px; height: 36px; border-radius: 12px; 
            font-size: 14px; font-weight: 700; color: #4A5568; 
            text-decoration: none; transition: all 0.2s; 
            background: white; border: 1px solid #E2E8F0; cursor: pointer;
        }
        .paginate a:hover { background: #F0F8FF; color: #89CFF0; border-color: #89CFF0; }
        .paginate span { background: #89CFF0; color: white; border-color: #89CFF0; } 
        
        /* 🚀 탭 메뉴 스타일 */
        .tab-container { display: flex; gap: 24px; margin-bottom: 24px; border-bottom: 2px solid #EDF2F7; }
        .tab-btn { background: none; border: none; font-size: 20px; font-weight: 800; color: #A0AEC0; padding-bottom: 12px; cursor: pointer; position: relative; transition: color 0.2s; }
        .tab-btn.active { color: #2D3748; }
        .tab-btn.active::after { content: ''; position: absolute; bottom: -2px; left: 0; width: 100%; height: 2px; background: #2D3748; }
        
        /* 🚀 사진 모아보기 그리드 */
        .photo-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 12px; }
        .photo-grid-item { width: 100%; aspect-ratio: 1; border-radius: 12px; overflow: hidden; cursor: pointer; position: relative; }
        .photo-grid-item img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s; }
        .photo-grid-item:hover img { transform: scale(1.05); }

        /* 🚀 전체화면 라이트박스(모달) 갤러리형 업그레이드 */
        .lightbox-modal { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(15, 15, 15, 0.95); flex-direction: column; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s ease; }
        .lightbox-modal.show { display: flex; opacity: 1; }
        
        .lightbox-header { position: absolute; top: 0; left: 0; width: 100%; padding: 24px 40px; display: flex; justify-content: space-between; align-items: center; color: white; font-size: 15px; box-sizing: border-box; z-index: 10000; }
        .lightbox-counter { font-weight: 600; letter-spacing: 2px; color: #E2E8F0; }
        .lightbox-close { font-size: 15px; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: color 0.2s; color: #E2E8F0; }
        .lightbox-close:hover { color: white; }
        
        .lightbox-content { max-width: 80%; max-height: 80vh; border-radius: 8px; object-fit: contain; user-select: none; box-shadow: 0 12px 48px rgba(0,0,0,0.5); }
        
        /* 좌우 이동 화살표 */
        .lightbox-nav { position: absolute; top: 50%; transform: translateY(-50%); background: transparent; color: rgba(255, 255, 255, 0.5); border: none; font-size: 48px; cursor: pointer; padding: 20px; transition: color 0.2s, transform 0.2s; user-select: none; }
        .lightbox-nav:hover { color: white; transform: translateY(-50%) scale(1.1); }
        .lightbox-nav.prev { left: 40px; }
        .lightbox-nav.next { right: 40px; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="review-page-wrapper">
    
    <div class="left-sidebar">
        <div class="place-summary-card">
            <div class="place-summary-img">
                <img src="${placeInfo.imageUrl}" alt="숙소 이미지">
            </div>
            <div class="place-summary-info">
                <h2>${placeInfo.name}</h2>
                <p><i class="bi bi-geo-alt-fill"></i> ${placeInfo.region}</p>
            </div>
        </div>

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
            
            <c:set var="total" value="${stats.totalCount == 0 ? 1 : stats.totalCount}" />
            
            <div class="stats-bars">
                <div class="rating-bar-row">
                    <span class="rating-label">5점</span>
                    <div class="progress-track"><div class="progress-fill" style="width: ${(stats.count5 / total) * 100}%;"></div></div>
                    <span class="rating-count">${stats.count5}</span>
                </div>
                <div class="rating-bar-row">
                    <span class="rating-label">4점</span>
                    <div class="progress-track"><div class="progress-fill" style="width: ${(stats.count4 / total) * 100}%;"></div></div>
                    <span class="rating-count">${stats.count4}</span>
                </div>
                <div class="rating-bar-row">
                    <span class="rating-label">3점</span>
                    <div class="progress-track"><div class="progress-fill" style="width: ${(stats.count3 / total) * 100}%;"></div></div>
                    <span class="rating-count">${stats.count3}</span>
                </div>
                <div class="rating-bar-row">
                    <span class="rating-label">2점</span>
                    <div class="progress-track"><div class="progress-fill" style="width: ${(stats.count2 / total) * 100}%;"></div></div>
                    <span class="rating-count">${stats.count2}</span>
                </div>
                <div class="rating-bar-row">
                    <span class="rating-label">1점</span>
                    <div class="progress-track"><div class="progress-fill" style="width: ${(stats.count1 / total) * 100}%;"></div></div>
                    <span class="rating-count">${stats.count1}</span>
                </div>
            </div>
        </div>
    </div>

    <div class="right-content">
        <div class="review-list-header">
            <h3 class="section-title" style="margin-bottom: 0;">생생한 이용 후기</h3>
            
            <div class="tab-container">
	            <button class="tab-btn active" id="tabReview" onclick="switchTab('review')">리뷰</button>
	            <button class="tab-btn" id="tabPhoto" onclick="switchTab('photo')">사진</button>
	        </div>
            
            <div style="display: flex; gap: 8px;">
		        <select class="sort-select" onchange="location.href='?sort=${sort}&roomId=' + this.value">
		            <option value="">객실 전체</option>
		            <c:forEach var="room" items="${roomList}">
		                <option value="${room.roomId}" ${roomId == room.roomId ? 'selected' : ''}>${room.roomName}</option>
		            </c:forEach>
		        </select>
		        
		        <select class="sort-select" id="sortFilter" onchange="location.href='?roomId=${roomId}&sort=' + this.value">
		            <option value="latest" ${sort == 'latest' ? 'selected' : ''}>최신 작성순</option>
		            <option value="high" ${sort == 'high' ? 'selected' : ''}>별점 높은 순</option>
		            <option value="low" ${sort == 'low' ? 'selected' : ''}>별점 낮은 순</option>
		        </select>
		    </div>
        </div>
        
        <div id="contentReview">
	        <c:choose>
	        	<c:when test="${empty reviewList}">
	                <div style="text-align: center; padding: 80px 20px; color: #A0AEC0; background: white; border-radius: 20px; border: 1px dashed #E2E8F0;">
	                    <i class="bi bi-chat-square-text" style="font-size: 56px; color: #E2E8F0;"></i>
	                    <p style="margin-top: 16px; font-size: 16px; font-weight: 700; color: #718096;">아직 작성된 리뷰가 없습니다.</p>
	                    <p style="font-size: 14px;">첫 번째 리뷰의 주인공이 되어보세요!</p>
	                </div>
	            </c:when>
	            <c:otherwise>
	                <c:forEach var="review" items="${reviewList}">
	                    <div class="review-item">
	                        <div class="review-header">
	                            <div class="reviewer-info">
	                                <span class="reviewer-name">
	                                    ${review.memberName}
	                                    <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.memberId == review.memberId}">
	                                        <span class="my-review-badge">내가 쓴 글</span>
	                                    </c:if>
	                                </span>
	                                <span class="review-room">${review.roomName}</span>
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
							            <img src="${pageContext.request.contextPath}/uploads/review/${imgName}" 
							                 alt="리뷰 첨부 사진" 
							                 onclick="openLightbox(this)"> </c:forEach>
							    </div>
							</c:if>
	
	                        <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.memberId == review.memberId}">
	                            <div class="review-actions">
	                                <button type="button" class="btn-review-action" onclick="location.href='${pageContext.request.contextPath}/accommodation/review/update/${review.reviewId}'">수정</button>
	                                <button type="button" class="btn-review-action btn-review-delete" onclick="deleteReview(${review.reviewId}, ${placeId})">삭제</button>
	                            </div>
	                        </c:if>
	                    </div>
	                </c:forEach>
	            </c:otherwise>
	        </c:choose>
	        
			${paging}
		</div>

		<div id="contentPhoto" style="display: none;">
            <div id="photoGrid" class="photo-grid"></div>
            
            <div id="photoEmptyMsg" style="display:none; text-align:center; padding: 60px 20px; color: #A0AEC0;">
                <i class="bi bi-images" style="font-size: 48px;"></i>
                <p style="margin-top: 16px; font-weight: 700;">등록된 사진이 없습니다.</p>
            </div>
        </div>
		
    </div>
</div>

<div id="lightboxModal" class="lightbox-modal" onclick="closeLightbox(event)">
    <div class="lightbox-header">
        <div style="width: 60px;"></div> <span class="lightbox-counter" id="lightboxCounter">1 / 1</span>
        <span class="lightbox-close" onclick="closeLightbox()">닫기 &times;</span>
    </div>
    
    <button class="lightbox-nav prev" onclick="changeLightboxImage(-1)">&#10094;</button>
    
    <img class="lightbox-content" id="lightboxImg">
    
    <button class="lightbox-nav next" onclick="changeLightboxImage(1)">&#10095;</button>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script>
function deleteReview(reviewId, placeId) {
    if (confirm('정말로 이 리뷰를 삭제하시겠습니까?\n첨부된 사진도 모두 삭제됩니다.')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/accommodation/review/delete';
        
        const input1 = document.createElement('input');
        input1.type = 'hidden';
        input1.name = 'reviewId';
        input1.value = reviewId;

        const input2 = document.createElement('input');
        input2.type = 'hidden';
        input2.name = 'placeId';
        input2.value = placeId;
        
        form.appendChild(input1);
        form.appendChild(input2);
        document.body.appendChild(form);
        
        form.submit();
    }
}


//전역 변수로 현재 상태 저장
let isPhotosLoaded = false;
const currentPlaceId = ${placeId};
const currentRoomId = '${roomId != null ? roomId : ""}';
const ctxPath = '${pageContext.request.contextPath}';

document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const targetTab = urlParams.get('tab');
    
    if (targetTab === 'photo') {
        switchTab('photo');
    }
});

// 탭 전환 기능
function switchTab(tab) {
    const tabReview = document.getElementById('tabReview');
    const tabPhoto = document.getElementById('tabPhoto');
    const contentReview = document.getElementById('contentReview');
    const contentPhoto = document.getElementById('contentPhoto');
    const sortFilter = document.getElementById('sortFilter'); // 정렬 필터

    if (tab === 'review') {
        tabReview.classList.add('active');
        tabPhoto.classList.remove('active');
        contentReview.style.display = 'block';
        contentPhoto.style.display = 'none';
        sortFilter.style.display = 'block'; // 리뷰에선 정렬 필터 켬
    } else {
        tabReview.classList.remove('active');
        tabPhoto.classList.add('active');
        contentReview.style.display = 'none';
        contentPhoto.style.display = 'block';
        sortFilter.style.display = 'none'; // 사진만 볼 땐 정렬 필터 숨김
        
        if (!isPhotosLoaded) {
            loadPhotos();
        }
    }
}

function loadPhotos() {
    fetch(`\${ctxPath}/accommodation/review/photos/\${currentPlaceId}?roomId=\${currentRoomId}`)
        .then(res => res.json())
        .then(images => {
            const grid = document.getElementById('photoGrid');
            const emptyMsg = document.getElementById('photoEmptyMsg');
            
            grid.innerHTML = '';
            
            if (images.length === 0) {
                emptyMsg.style.display = 'block';
            } else {
                emptyMsg.style.display = 'none';
                images.forEach(imgUrl => {
                    const fullUrl = `\${ctxPath}/uploads/review/\${imgUrl}`;
                    const div = document.createElement('div');
                    div.className = 'photo-grid-item';
                    div.innerHTML = `<img src="\${fullUrl}" alt="리뷰 사진" onclick="openLightbox(this)" loading="lazy">`;
                    grid.appendChild(div);
                });
            }
            isPhotosLoaded = true; // 다음 탭 전환 시 재호출 방지
        })
        .catch(err => console.error("사진 로딩 실패:", err));
}

let galleryImages = []; // 현재 띄울 이미지 URL 배열
let currentGalleryIndex = 0; // 현재 보고 있는 이미지의 인덱스

function openLightbox(imgElement) {
    const container = imgElement.closest('.review-images, .photo-grid');
    if (!container) return;

    const imgs = container.querySelectorAll('img');
    galleryImages = Array.from(imgs).map(img => img.src);

    currentGalleryIndex = galleryImages.indexOf(imgElement.src);

    updateLightboxView();
    const lightbox = document.getElementById('lightboxModal');
    lightbox.classList.add('show');
    document.body.style.overflow = 'hidden'; // 뒤쪽 스크롤 방지
}

function updateLightboxView() {
    const lightboxImg = document.getElementById('lightboxImg');
    const counter = document.getElementById('lightboxCounter');
    
    lightboxImg.src = galleryImages[currentGalleryIndex];
    
    counter.textContent = (currentGalleryIndex + 1) + ' / ' + galleryImages.length;
}

function changeLightboxImage(direction) {
    currentGalleryIndex += direction;
    
    if (currentGalleryIndex < 0) {
        currentGalleryIndex = galleryImages.length - 1;
    } else if (currentGalleryIndex >= galleryImages.length) {
        currentGalleryIndex = 0;
    }
    
    updateLightboxView();
}

function closeLightbox(e) {
    if (e && e.target.id !== 'lightboxModal') return;
    
    const lightbox = document.getElementById('lightboxModal');
    lightbox.classList.remove('show');
    document.body.style.overflow = 'auto'; // 스크롤 복구
}
</script>

</body>
</html>