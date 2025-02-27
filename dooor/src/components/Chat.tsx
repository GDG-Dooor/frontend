import React, { useCallback, useState } from 'react';

import { chatService } from '../services/chatService';
import { useAuth } from '../hooks/useAuth';

interface ChatProps {
  userName: string;
}

export const Chat: React.FC<ChatProps> = ({ userName }) => {
  const [message, setMessage] = useState('');
  const [chatHistory, setChatHistory] = useState<Array<{message: string; isUser: boolean}>>([]);
  const [isLoading, setIsLoading] = useState(false);
  const { accessToken, refreshToken, updateAccessToken } = useAuth();

  const handleSendMessage = useCallback(async () => {
    if (!message.trim() || isLoading) return;

    try {
      setIsLoading(true);
      // 사용자 메시지를 채팅 기록에 추가
      setChatHistory(prev => [...prev, { message, isUser: true }]);
      setMessage('');

      // 챗봇 응답 요청
      const response = await chatService.sendMessage(message, userName, accessToken);
      
      // 챗봇 응답을 채팅 기록에 추가
      setChatHistory(prev => [...prev, { message: response, isUser: false }]);
    } catch (error) {
      if (error instanceof Error && error.message === 'TOKEN_EXPIRED') {
        try {
          // 토큰 갱신 시도
          const newAccessToken = await chatService.refreshToken(refreshToken);
          updateAccessToken(newAccessToken);
          
          // 갱신된 토큰으로 메시지 재전송
          const response = await chatService.sendMessage(message, userName, newAccessToken);
          setChatHistory(prev => [...prev, { message: response, isUser: false }]);
        } catch (refreshError) {
          console.error('토큰 갱신 실패:', refreshError);
          // 로그인 페이지로 리다이렉트 등 추가 처리
        }
      } else {
        console.error('메시지 전송 실패:', error);
        setChatHistory(prev => [...prev, { 
          message: '메시지 전송에 실패했습니다. 다시 시도해주세요.', 
          isUser: false 
        }]);
      }
    } finally {
      setIsLoading(false);
    }
  }, [message, userName, accessToken, refreshToken, updateAccessToken, isLoading]);

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {chatHistory.map((chat, index) => (
          <div
            key={index}
            className={`flex ${chat.isUser ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[70%] rounded-lg p-3 ${
                chat.isUser
                  ? 'bg-blue-500 text-white'
                  : 'bg-gray-200 text-gray-800'
              }`}
            >
              <p className="text-sm font-medium mb-1">
                {chat.isUser ? userName : '챗봇'}
              </p>
              <p>{chat.message}</p>
            </div>
          </div>
        ))}
      </div>
      <div className="border-t p-4">
        <div className="flex space-x-2">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && !isLoading && handleSendMessage()}
            className="flex-1 border rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="메시지를 입력하세요..."
            disabled={isLoading}
          />
          <button
            onClick={handleSendMessage}
            disabled={isLoading}
            className={`px-6 py-2 rounded-lg transition-colors ${
              isLoading 
                ? 'bg-gray-400 text-white cursor-not-allowed'
                : 'bg-blue-500 text-white hover:bg-blue-600'
            }`}
          >
            {isLoading ? '전송 중...' : '전송'}
          </button>
        </div>
      </div>
    </div>
  );
}; 