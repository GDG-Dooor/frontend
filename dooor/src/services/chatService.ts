import axios from 'axios';

const CHAT_API_BASE_URL = 'http://43.202.174.46:5000';

interface ChatResponse {
  message: string;
}

class ChatService {
  async sendMessage(message: string, userName: string, accessToken: string): Promise<string> {
    try {
      const response = await axios.get<string>(`${CHAT_API_BASE_URL}/chat/message`, {
        params: {
          message,
          userName
        },
        headers: {
          Authorization: `Bearer ${accessToken}`
        }
      });
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 401) {
        // 토큰이 만료된 경우
        throw new Error('TOKEN_EXPIRED');
      }
      throw error;
    }
  }

  async refreshToken(refreshToken: string): Promise<string> {
    try {
      const response = await axios.post(`${CHAT_API_BASE_URL}/auth/refresh`, null, {
        headers: {
          Authorization: `Bearer ${refreshToken}`
        }
      });
      return response.data.accessToken;
    } catch (error) {
      throw new Error('토큰 갱신에 실패했습니다.');
    }
  }
}

export const chatService = new ChatService(); 