<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Tripan - 리뷰 작성</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        .review-container { 
            max-width: 800px; margin: 120px auto 80px; padding: 40px; 
            background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.8); border-radius: 24px; box-shadow: 0 12px 32px rgba(45, 55, 72, 0.04);
        }
        
        .review-title { font-size: 24px; font-weight: 900; margin-bottom: 8px; color: #2D3748; }
        .review-subtitle { font-size: 15px; color: #718096; margin-bottom: 30px; }

        /* ✨ 새롭게 추가된 예약 정보 카드 스타일 */
        .booking-summary-card {
            display: flex;
            align-items: center;
            gap: 20px;
            background: white;
            padding: 16px;
            border-radius: 16px;
            border: 1px solid #E2E8F0;
            margin-bottom: 32px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
        }
        .booking-img {
            width: 100px;
            height: 100px;
            border-radius: 12px;
            overflow: hidden;
            flex-shrink: 0;
        }
        .booking-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .booking-info { flex: 1; }
        .booking-place { font-size: 18px; font-weight: 800; color: #2D3748; margin-bottom: 4px; }
        .booking-room { font-size: 14px; font-weight: 600; color: #4A5568; margin-bottom: 8px; }
        .booking-date { 
            display: inline-block;
            font-size: 12px; 
            font-weight: 700; 
            color: #89CFF0; 
            background: rgba(137, 207, 240, 0.1);
            padding: 4px 10px;
            border-radius: 8px;
        }
        
        .form-group { margin-bottom: 24px; }
        .form-label { font-weight: 800; display: block; margin-bottom: 12px; color: var(--text-dark, #4A5568); }
        
        /* 별점 UI 스타일 */
        .star-rating { 
            display: flex; 
            flex-direction: row-reverse; 
            justify-content: flex-end; 
            font-size: 2.5rem; 
            gap: 4px;
        }
        .star-rating input { display: none; }
        .star-rating label { color: #E2E8F0; cursor: pointer; transition: color 0.2s, transform 0.2s; }
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label { color: #FFD700; } /* 선택된 별 노란색 */
        .star-rating label:hover { transform: scale(1.1); }

        .review-textarea {
            width: 100%; height: 200px; padding: 16px;
            border: 1px solid #E2E8F0; border-radius: 12px;
            font-size: 15px; font-family: inherit; resize: none;
            background: #F8FAFC; outline: none; transition: all 0.2s;
        }
        .review-textarea:focus { border-color: #89CFF0; background: #fff; }

        .file-upload-box {
            margin-top: 12px; padding: 16px;
            border: 1px dashed #A0AEC0; border-radius: 12px;
            background: #FAFAFA; text-align: left;
        }
        .file-upload-box input[type="file"] {
            font-size: 14px; color: #4A5568;
        }
        
        /* ✨ 드래그 앤 드롭 박스 스타일 */
		.file-upload-box {
		    margin-top: 12px; padding: 40px 16px;
		    border: 2px dashed #A0AEC0; border-radius: 16px;
		    background: #FAFAFA; text-align: center;
		    cursor: pointer; transition: all 0.3s ease;
		}
		.file-upload-box:hover { background: #F0F8FF; border-color: #89CFF0; }
		/* 드래그 중일 때 박스 효과 */
		.file-upload-box.dragover {
		    border-color: #89CFF0; background: #E6F4FF; transform: scale(1.02);
		}
		
		/* ✨ 썸네일 미리보기 영역 */
		.image-preview-container {
		    display: flex; gap: 12px; flex-wrap: wrap; margin-top: 16px;
		}
		.preview-wrapper {
		    position: relative; width: 100px; height: 100px;
		    border-radius: 12px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.1);
		}
		.preview-wrapper img {
		    width: 100%; height: 100%; object-fit: cover;
		}
		/* 썸네일 삭제(X) 버튼 */
		.preview-remove-btn {
		    position: absolute; top: 4px; right: 4px;
		    background: rgba(255, 0, 0, 0.7); color: white;
		    border: none; border-radius: 50%; width: 24px; height: 24px;
		    display: flex; align-items: center; justify-content: center;
		    font-size: 14px; cursor: pointer; transition: background 0.3s;
		}
		.preview-remove-btn:hover { background: rgba(255, 0, 0, 1); }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="review-container">
    <h2 class="review-title">
        <c:out value="${mode == 'update' ? '숙소 리뷰 수정' : '숙소 리뷰 작성'}"/>
    </h2>
    <p class="review-subtitle">이용하신 숙소는 어떠셨나요? 소중한 경험을 나누어주세요.</p>
    
    <form id="reviewForm" action="${pageContext.request.contextPath}/accommodation/review/${mode == 'update' ? 'update' : 'submit'}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="mode" value="${mode}">
        
        <c:if test="${mode == 'write'}">
            <input type="hidden" name="reservationId" value="${reservationInfo.reservationId}">
            <input type="hidden" name="placeId" value="${room.placeId}">
            <input type="hidden" name="startDate" value="${reservationInfo.checkin}">
            <input type="hidden" name="endDate" value="${reservationInfo.checkout}">
        </c:if>
        <c:if test="${mode == 'update'}">
            <input type="hidden" name="reviewId" value="${review.reviewId}">
            <input type="hidden" name="placeId" value="${review.placeId}">
        </c:if>

        <div class="form-group">
            <label class="form-label">별점</label>
            <div class="star-rating">
                <input type="radio" id="star5" name="rating" value="5" checked><label for="star5" class="bi bi-star-fill"></label>
                <input type="radio" id="star4" name="rating" value="4"><label for="star4" class="bi bi-star-fill"></label>
                <input type="radio" id="star3" name="rating" value="3"><label for="star3" class="bi bi-star-fill"></label>
                <input type="radio" id="star2" name="rating" value="2"><label for="star2" class="bi bi-star-fill"></label>
                <input type="radio" id="star1" name="rating" value="1"><label for="star1" class="bi bi-star-fill"></label>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">리뷰 내용</label>
            <textarea class="review-textarea" name="content" placeholder="숙소의 청결도, 서비스, 위치 등 솔직한 리뷰를 남겨주세요." required>${mode == 'update' ? review.content : ''}</textarea>
        </div>

        <div class="form-group">
		    <label class="form-label">사진 첨부 (선택)</label>
		    
		    <div id="retainImagesContainer">
		        <c:if test="${mode == 'update'}">
		            <c:forEach var="img" items="${review.imageUrls}">
		                <input type="hidden" name="retainImageUrls" value="${img}" id="retain_${img.replace('.', '_')}">
		            </c:forEach>
		        </c:if>
		    </div>
		
		    <div class="file-upload-box" id="dropZone">
		        <i class="bi bi-cloud-arrow-up" style="font-size: 32px; color: #89CFF0; margin-bottom: 12px; display: block;"></i>
		        <p style="margin: 0; font-size: 15px; font-weight: 700; color: #4A5568;">클릭하거나 이미지를 이곳에 드래그 앤 드롭하세요.</p>
		        <p style="font-size: 12px; color: #A0AEC0; margin-top: 8px; margin-bottom: 0;">(기존 사진 포함 최대 5장)</p>
		        
		        <input type="file" name="uploadFiles" id="fileInput" multiple accept="image/*" style="display: none;">
		    </div>
		    
		    <div id="imagePreviewContainer" class="image-preview-container"></div>
		</div>

        <button type="submit" class="btn-submit">
            <c:out value="${mode == 'update' ? '리뷰 수정하기' : '리뷰 등록하기'}"/>
        </button>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('fileInput');
    const previewContainer = document.getElementById('imagePreviewContainer');
    
    let dataTransfer = new DataTransfer();

    <c:if test="${mode == 'update' and not empty review.imageUrls}">
        <c:forEach var="img" items="${review.imageUrls}">
        {
            const existingDiv = document.createElement('div');
            existingDiv.className = 'preview-wrapper';
            existingDiv.innerHTML = `
                <img src="${pageContext.request.contextPath}/uploads/review/${img}" alt="기존 이미지">
                <button type="button" class="preview-remove-btn" data-existing="${img}">
                    <i class="bi bi-x"></i>
                </button>
            `;
            previewContainer.appendChild(existingDiv);
        }
        </c:forEach>
    </c:if>

    dropZone.addEventListener('click', () => fileInput.click());

    const handleFiles = (files) => {
        const currentCount = previewContainer.querySelectorAll('.preview-wrapper').length; 
        
        const validFiles = Array.from(files).filter(file => {
            if (!file.type.match('image.*')) {
                alert('이미지 파일만 업로드 가능합니다: ' + file.name);
                return false;
            }
            return true;
        });

        if (currentCount + validFiles.length > 5) {
            alert('사진은 기존 사진 포함 최대 5장까지만 첨부할 수 있습니다.');
            validFiles.splice(5 - currentCount); 
        }

        validFiles.forEach(file => {
            dataTransfer.items.add(file);
            const reader = new FileReader();
            reader.onload = (e) => {
                const div = document.createElement('div');
                div.className = 'preview-wrapper';
                div.innerHTML = `
                    <img src="\${e.target.result}" alt="미리보기">
                    <button type="button" class="preview-remove-btn" data-name="\${file.name}">
                        <i class="bi bi-x"></i>
                    </button>
                `;
                previewContainer.appendChild(div);
            };
            reader.readAsDataURL(file);
        });

        fileInput.files = dataTransfer.files;
    };

    fileInput.addEventListener('change', (e) => handleFiles(e.target.files));

    dropZone.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.classList.add('dragover'); });
    dropZone.addEventListener('dragleave', (e) => { e.preventDefault(); dropZone.classList.remove('dragover'); });
    dropZone.addEventListener('drop', (e) => {
        e.preventDefault(); dropZone.classList.remove('dragover');
        handleFiles(e.dataTransfer.files); 
    });

    // 🚀 X 버튼 눌렀을 때 삭제 로직 (기존 vs 신규 구분)
    previewContainer.addEventListener('click', (e) => {
        const btn = e.target.closest('.preview-remove-btn');
        if (btn) {
            const existingImg = btn.getAttribute('data-existing');
            
            if (existingImg) {
                // (1) 기존에 있던 이미지를 지울 때: 서버로 날아갈 hidden input 삭제
                const safeId = existingImg.replace('.', '_');
                const hiddenInput = document.getElementById('retain_' + safeId);
                if (hiddenInput) hiddenInput.remove();
            } else {
                // (2) 새로 첨부한 이미지를 지울 때: DataTransfer에서 빼기
                const fileNameToRemove = btn.getAttribute('data-name');
                const newDataTransfer = new DataTransfer();
                Array.from(dataTransfer.files).forEach(file => {
                    if (file.name !== fileNameToRemove) newDataTransfer.items.add(file);
                });
                dataTransfer = newDataTransfer;
                fileInput.files = dataTransfer.files;
            }
            
            // 화면에서 썸네일 날리기
            btn.closest('.preview-wrapper').remove();
        }
    });
});
</script>


</body>
</html>
