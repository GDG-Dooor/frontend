import './index.css';

import { Chat } from './components/Chat';
import React from 'react';
import ReactDOM from 'react-dom/client';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
    <div className="h-screen p-4">
      <Chat userName="사용자" />
    </div>
  </React.StrictMode>
); 