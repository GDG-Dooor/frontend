import { useCallback, useState } from 'react';

export const useAuth = () => {
  const [accessToken, setAccessToken] = useState<string>(() => 
    localStorage.getItem('accessToken') || ''
  );
  const [refreshToken, setRefreshToken] = useState<string>(() => 
    localStorage.getItem('refreshToken') || ''
  );

  const updateAccessToken = useCallback((newToken: string) => {
    setAccessToken(newToken);
    localStorage.setItem('accessToken', newToken);
  }, []);

  const updateRefreshToken = useCallback((newToken: string) => {
    setRefreshToken(newToken);
    localStorage.setItem('refreshToken', newToken);
  }, []);

  const clearTokens = useCallback(() => {
    setAccessToken('');
    setRefreshToken('');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }, []);

  return {
    accessToken,
    refreshToken,
    updateAccessToken,
    updateRefreshToken,
    clearTokens,
  };
}; 