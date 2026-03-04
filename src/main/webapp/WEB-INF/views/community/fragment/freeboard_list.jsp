<%@ page contentType="text/html; charset=UTF-8" %>
<style>
  .board-header { margin-bottom: 24px; }
  .board-title { font-size: 24px; font-weight: 900; margin: 0 0 8px; letter-spacing: -0.5px; }
  .board-sub { font-size: 14px; color: var(--text-gray); font-weight: 500; margin: 0; }
  .filter-bar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid rgba(0,0,0,0.05); }
  .filter-left { display: flex; gap: 8px; flex-wrap: wrap; }
  .f-chip { padding: 8px 16px; border-radius: 50px; border: 1.5px solid rgba(0,0,0,0.1); background: var(--glass-bg); font-size: 13px; font-weight: 700; color: var(--text-gray); cursor: pointer; transition: all .2s; }
  .f-chip:hover { border-color: var(--sky-blue); color: var(--sky-blue); background: #F0F8FF; }
  .f-chip.on { border-color: transparent; background: var(--grad-main); color: white; box-shadow: 0 4px 14px rgba(137,207,240,.3); }
  .btn-write { padding: 9px 20px; border: none; border-radius: 50px; background: var(--grad-main); color: white; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(137,207,240,.3); transition: all .3s; }
  .btn-write:hover { transform: translateY(-2px); box-shadow: 0 7px 20px rgba(137,207,240,.4); }
  .board-list { display: flex; flex-direction: column; gap: 16px; }
  .board-card { display: flex; gap: 20px; background: var(--glass-bg); padding: 24px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.8); box-shadow: 0 4px 16px rgba(0,0,0,0.04); cursor: pointer; text-decoration: none; color: inherit; transition: all 0.3s ease; }
  .board-card:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(137, 207, 240, 0.15); border-color: rgba(137,207,240,0.3); }
  .card-content { flex: 1; display: flex; flex-direction: column; justify-content: center; }
  .card-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; margin-bottom: 12px; width: fit-content; }
  .badge-tip { background: #E6FFFA; color: #00A88F; }
  .badge-review { background: #EBF8FF; color: var(--sky-blue); }
  .card-title { font-size: 17px; font-weight: 800; margin: 0 0 8px; line-height: 1.4; }
  .card-text { font-size: 14px; color: var(--text-gray); margin: 0 0 16px; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .card-meta { display: flex; align-items: center; gap: 16px; font-size: 12px; color: #A0AEC0; font-weight: 600; }
  .meta-user { display: flex; align-items: center; gap: 6px; color: var(--text-dark); }
  .meta-user img { width: 24px; height: 24px; border-radius: 50%; object-fit: cover; }
  .meta-stats { display: flex; gap: 12px; margin-left: auto; }
  .card-thumb { width: 120px; height: 120px; border-radius: 12px; overflow: hidden; flex-shrink: 0; }
  .card-thumb img { width: 100%; height: 100%; object-fit: cover; }
</style>

<div class="board-header">
  <h2 class="board-title">💬 자유게시판</h2>
  <p class="board-sub">여행 꿀팁부터 궁금한 질문, 다녀온 생생 후기까지!</p>
</div>

<div class="filter-bar">
  <div class="filter-left">
    <button class="f-chip on">전체</button>
    <button class="f-chip">💡 여행 꿀팁</button>
    <button class="f-chip">🙋‍♂️ 질문있어요</button>
    <button class="f-chip">📸 다녀온 후기</button>
  </div>
  <button class="btn-write">✏️ 글쓰기</button>
</div>

<div class="board-list">
  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-tip">여행 꿀팁</span>
      <h3 class="card-title">일본 오사카 여행 시 트래블월렛 vs 트래블로그 완벽 비교해드림</h3>
      <p class="card-text">이번에 오사카 다녀오면서 두 카드 모두 사용해봤는데요, 수수료나 편의성 면에서 확실히 차이가 있더라고요.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user1/100/100"><span>@travel_pro</span></div>
        <span>2시간 전</span>
        <div class="meta-stats"><span>👁 1,204</span><span>💬 32</span><span style="color:#E8849A">♥ 145</span></div>
      </div>
    </div>
  </a>

  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-review">다녀온 후기</span>
      <h3 class="card-title">어제 다녀온 부산 해운대 요트투어 야경 미쳤네요 진짜;;</h3>
      <p class="card-text">Tripan 일정 담아오기 기능으로 다른 분 코스 그대로 훔쳐서 다녀왔는데, 시간대 18시로 예약한 게 신의 한 수 였습니다.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user3/100/100"><span>@busan_lover</span></div>
        <span>1일 전</span>
        <div class="meta-stats"><span>👁 2,510</span><span>💬 48</span><span style="color:#E8849A">♥ 312</span></div>
      </div>
    </div>
    <div class="card-thumb"><img src="https://picsum.photos/seed/yacht/400/400"></div>
  </a>
</div>

  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-review">다녀온 후기</span>
      <h3 class="card-title">어제 다녀온 부산 해운대 요트투어 야경 미쳤네요 진짜;;</h3>
      <p class="card-text">Tripan 일정 담아오기 기능으로 다른 분 코스 그대로 훔쳐서 다녀왔는데, 시간대 18시로 예약한 게 신의 한 수 였습니다.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user3/100/100"><span>@busan_lover</span></div>
        <span>1일 전</span>
        <div class="meta-stats"><span>👁 2,510</span><span>💬 48</span><span style="color:#E8849A">♥ 312</span></div>
      </div>
    </div>
    <div class="card-thumb"><img src="https://picsum.photos/seed/yacht/400/400"></div>
  </a>
</div>

  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-review">다녀온 후기</span>
      <h3 class="card-title">어제 다녀온 부산 해운대 요트투어 야경 미쳤네요 진짜;;</h3>
      <p class="card-text">Tripan 일정 담아오기 기능으로 다른 분 코스 그대로 훔쳐서 다녀왔는데, 시간대 18시로 예약한 게 신의 한 수 였습니다.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user3/100/100"><span>@busan_lover</span></div>
        <span>1일 전</span>
        <div class="meta-stats"><span>👁 2,510</span><span>💬 48</span><span style="color:#E8849A">♥ 312</span></div>
      </div>
    </div>
    <div class="card-thumb"><img src="https://picsum.photos/seed/yacht/400/400"></div>
  </a>
</div>

  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-review">다녀온 후기</span>
      <h3 class="card-title">어제 다녀온 부산 해운대 요트투어 야경 미쳤네요 진짜;;</h3>
      <p class="card-text">Tripan 일정 담아오기 기능으로 다른 분 코스 그대로 훔쳐서 다녀왔는데, 시간대 18시로 예약한 게 신의 한 수 였습니다.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user3/100/100"><span>@busan_lover</span></div>
        <span>1일 전</span>
        <div class="meta-stats"><span>👁 2,510</span><span>💬 48</span><span style="color:#E8849A">♥ 312</span></div>
      </div>
    </div>
    <div class="card-thumb"><img src="https://picsum.photos/seed/yacht/400/400"></div>
  </a>
</div>

  <a href="#" class="board-card">
    <div class="card-content">
      <span class="card-badge badge-review">다녀온 후기</span>
      <h3 class="card-title">어제 다녀온 부산 해운대 요트투어 야경 미쳤네요 진짜;;</h3>
      <p class="card-text">Tripan 일정 담아오기 기능으로 다른 분 코스 그대로 훔쳐서 다녀왔는데, 시간대 18시로 예약한 게 신의 한 수 였습니다.</p>
      <div class="card-meta">
        <div class="meta-user"><img src="https://picsum.photos/seed/user3/100/100"><span>@busan_lover</span></div>
        <span>1일 전</span>
        <div class="meta-stats"><span>👁 2,510</span><span>💬 48</span><span style="color:#E8849A">♥ 312</span></div>
      </div>
    </div>
    <div class="card-thumb"><img src="https://picsum.photos/seed/yacht/400/400"></div>
  </a>
</div>