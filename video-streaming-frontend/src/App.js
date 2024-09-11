// src/App.js
import React, { useState, useEffect } from 'react';
import VideoUploader from './VideoUploader';
import VideoPlayer from './VideoPlayer';

const BACKEND_URL = 'http://localhost:3001';

const App = () => {
  const [videoKey, setVideoKey] = useState(null);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleUploadSuccess = (key) => {
    console.log('Upload successful, key:', key);
    setVideoKey(key);
    setError(null);
    setIsLoading(true);
  };

  const handleError = (errorMessage) => {
    console.error('Error:', errorMessage);
    setError(errorMessage);
    setIsLoading(false);
  };

  useEffect(() => {
    if (videoKey) {
      console.log('Video key updated:', videoKey);
    }
  }, [videoKey]);

  return (
    <div>
      <h1>Video Upload and Streaming</h1>
      <VideoUploader onUploadSuccess={handleUploadSuccess} backendUrl={BACKEND_URL} />
      {error && <div style={{color: 'red'}}>{error}</div>}
      {isLoading && <div>Loading video...</div>}
      {videoKey && <VideoPlayer videoKey={videoKey} onError={handleError} />}
    </div>
  );
};

export default App;