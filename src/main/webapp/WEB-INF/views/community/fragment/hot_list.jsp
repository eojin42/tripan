<%@ page contentType="text/html; charset=UTF-8" %>
<style>
  .hot-header { margin-bottom: 24px; }
  .hot-title { font-size: 24px; font-weight: 900; margin: 0 0 8px 0; }
  .hot-sub { font-size: 14px; color: var(--text-gray); margin: 0; }
  .hot-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
  .hot-item { position: relative; width: 100%; aspect-ratio: 1 / 1; border-radius: 16px; overflow: hidden; cursor: pointer; }
  .hot-item img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease; }
  .hot-overlay { position: absolute; inset: 0; background: rgba(0, 0, 0, 0.4); display: flex; justify-content: center; align-items: center; gap: 16px; opacity: 0; transition: opacity 0.3s ease; color: white; font-weight: 800; font-size: 16px; }
  .hot-item:hover img { transform: scale(1.05); }
  .hot-item:hover .hot-overlay { opacity: 1; }
  .hot-overlay span { display: flex; align-items: center; gap: 4px; }
  @media (max-width: 768px) { .hot-grid { grid-template-columns: repeat(2, 1fr); gap: 8px; } }
</style>

<div class="hot-header">
  <h2 class="hot-title">🔥 인기 급상승</h2>
  <p class="hot-sub">지금 Tripan에서 가장 핫한 여행지를 확인하세요.</p>
</div>
<div class="hot-grid">
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/jeju22/500/500"><div class="hot-overlay"><span>♥ 890</span><span>💬 45</span></div></a>
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/seoul3/500/500"><div class="hot-overlay"><span>♥ 750</span><span>💬 32</span></div></a>
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/sokcho/500/500"><div class="hot-overlay"><span>♥ 620</span><span>💬 28</span></div></a>
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/busan9/500/500"><div class="hot-overlay"><span>♥ 540</span><span>💬 15</span></div></a>
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/daegu/500/500"><div class="hot-overlay"><span>♥ 430</span><span>💬 22</span></div></a>
  <a href="#" class="hot-item"><img src="https://picsum.photos/seed/yeosu/500/500"><div class="hot-overlay"><span>♥ 380</span><span>💬 19</span></div></a>
</div>