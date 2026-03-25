<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<button id="faqChatFloatingBtn" class="faq-floating-btn" aria-label="챗봇 열기">
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M3 18v-6a9 9 0 0 1 18 0v6"></path>
    <path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"></path>
  </svg>
</button>

<div id="faqChatModal" class="chat-modal hidden">
  <div class="chat-header">
    <h5>Tripan FAQ 챗봇</h5>
    <button id="faqCloseChatBtn" class="btn-close-chat">&times;</button>
  </div>
  
  <div class="chat-body" id="faqChatBox">
    <div class="message assistant">
      <div class="message-content">Tripan 챗봇입니다. 여행 일정이나 정산, 서비스 이용에 대해 궁금한 점을 물어보세요!</div>
    </div>
  </div>

  <div class="chat-footer">
    <form id="faqChatForm" class="chat-input-group">
      <input type="text" id="faqMessageInput" class="chat-input" placeholder="문의사항을 입력하세요..." autocomplete="off">
      <button class="btn-send" type="submit" id="faqSendButton">전송</button>
    </form>
  </div>
</div>

<style>
  .faq-floating-btn {
    position: fixed;
    bottom: 110px; /* 기존 30px -> 110px 로 올려서 겹침 방지 */
    right: 30px;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, #a8c0ff 0%, #fbc2eb 100%);
    border: none;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    cursor: pointer;
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.2s;
  }
  .faq-floating-btn:hover {
    transform: scale(1.05);
  }

  /* 챗봇 모달 창 시작 위치도 함께 올려줍니다 */
  .chat-modal {
    position: fixed;
    bottom: 180px; /* 기존 100px -> 180px 로 올려서 겹침 방지 */
    right: 30px;
    width: 350px;
    height: 500px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    display: flex;
    flex-direction: column;
    z-index: 10000;
    overflow: hidden;
    transition: opacity 0.3s, transform 0.3s;
  }
  .chat-modal.hidden {
    opacity: 0;
    transform: translateY(20px);
    pointer-events: none;
  }

  /* 헤더, 바디, 푸터 구성 */
  .chat-header {
    background: #f8f9fa;
    padding: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #eee;
  }
  .chat-header h5 { margin: 0; font-size: 16px; font-weight: bold; }
  .btn-close-chat { background: none; border: none; font-size: 24px; cursor: pointer; line-height: 1; }
  
  .chat-body {
    flex: 1;
    padding: 15px;
    overflow-y: auto;
    background: #fff;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  /* 메시지 버블 스타일 */
  .message { display: flex; width: 100%; }
  .message.user { justify-content: flex-end; }
  .message.assistant { justify-content: flex-start; }
  .message-content {
    max-width: 80%;
    padding: 10px 14px;
    border-radius: 15px;
    font-size: 14px;
    line-height: 1.4;
  }
  .message.user .message-content {
    background: var(--point-blue, #007bff);
    color: #fff;
    border-bottom-right-radius: 2px;
  }
  .message.assistant .message-content {
    background: #f1f3f5;
    color: #333;
    border-bottom-left-radius: 2px;
  }

  .chat-footer {
    padding: 15px;
    border-top: 1px solid #eee;
    background: #fff;
  }
  .chat-input-group { display: flex; gap: 8px; }
  .chat-input {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 6px;
    outline: none;
  }
  .chat-input:focus { border-color: #a8c0ff; }
  .btn-send {
    padding: 10px 15px;
    background: #333;
    color: #fff;
    border: none;
    border-radius: 6px;
    cursor: pointer;
  }
  .btn-send:disabled { background: #ccc; cursor: not-allowed; }
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {
  // 스크립트에서도 변경된 ID를 참조하도록 수정
  const chatFloatingBtn = document.getElementById('faqChatFloatingBtn');
  const chatModal = document.getElementById('faqChatModal');
  const closeChatBtn = document.getElementById('faqCloseChatBtn');
  
  const chatBox = document.getElementById('faqChatBox');
  const chatForm = document.getElementById('faqChatForm');
  const messageInput = document.getElementById('faqMessageInput');
  const sendButton = document.getElementById('faqSendButton');

  // 모달 열기/닫기 토글
  chatFloatingBtn.addEventListener('click', () => {
    chatModal.classList.toggle('hidden');
    if (!chatModal.classList.contains('hidden')) {
      messageInput.focus();
    }
  });
  closeChatBtn.addEventListener('click', () => {
    chatModal.classList.add('hidden');
  });

  function addMessage(text, sender) {
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', sender);
    messageDiv.innerHTML = `<div class="message-content">\${escapeHtml(text)}</div>`; // JSP EL과 충돌 방지를 위해 \$ 사용
    chatBox.appendChild(messageDiv);
    chatBox.scrollTo({ top: chatBox.scrollHeight, behavior: 'smooth' });
    return messageDiv;
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  chatForm.addEventListener('submit', (e) => {
    e.preventDefault();
    sendMessage();
  });

  async function sendMessage() {
    const question = messageInput.value.trim();
    if (question) {
      addMessage(question, 'user');
      messageInput.value = '';
      sendButton.disabled = true;
      
      try {
        const response = await fetch(`http://localhost:9091/api/question?question=\${encodeURIComponent(question)}`);
        if (!response.ok) throw new Error("서버 응답 오류");

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        
        const botMessageElement = addMessage('', 'assistant');
        const contentElement = botMessageElement.querySelector('.message-content');
        
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          
          const targetText = decoder.decode(value, { stream: true });
          contentElement.innerHTML += targetText;
          chatBox.scrollTo({ top: chatBox.scrollHeight, behavior: 'auto' }); 
        }
      } catch(error) {
        addMessage('오류가 발생했습니다. AI 서버(9091)가 켜져 있는지 확인해주세요.', 'assistant');
        console.error('Error:', error);
      } finally {
        sendButton.disabled = false;
        messageInput.focus();
      }
    }
  }
});
</script>