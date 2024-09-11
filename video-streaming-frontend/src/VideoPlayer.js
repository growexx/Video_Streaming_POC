// src/VideoPlayer.js
import React, { useEffect, useRef, useState } from 'react';
import videojs from 'video.js';
import 'video.js/dist/video-js.css';
import '@videojs/http-streaming';

const VideoPlayer = ({ videoKey, onError }) => {
  const videoRef = useRef(null);
  const playerRef = useRef(null);
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    if (!videoKey) return;

    console.log('Initializing video player with key:', videoKey);

    const videoJsOptions = {
      controls: true,
      autoplay: false,
      preload: 'auto',
      fluid: true,
      sources: [{
        src: `http://localhost:3001/videos/${encodeURIComponent(videoKey)}/manifest.m3u8`,
        type: 'application/x-mpegURL'
      }]
    };

    const initializePlayer = () => {
      if (!playerRef.current && videoRef.current) {
        playerRef.current = videojs(videoRef.current, videoJsOptions, function onPlayerReady() {
          console.log('Player is ready');
          setIsReady(true);
          this.on('error', (e) => {
            console.error('Video.js error:', this.error());
            onError(`Video playback error: ${this.error().message}`);
          });
          this.on('loadedmetadata', () => {
            console.log('Video metadata loaded');
          });
          this.on('loadeddata', () => {
            console.log('Video data loaded');
          });
        });
      } else if (playerRef.current) {
        playerRef.current.src({ 
          type: 'application/x-mpegURL', 
          src: `http://localhost:3001/videos/${encodeURIComponent(videoKey)}/manifest.m3u8` 
        });
      }
    };

    // Delay initialization to ensure DOM is ready
    const timer = setTimeout(initializePlayer, 100);

    return () => {
      clearTimeout(timer);
      if (playerRef.current) {
        playerRef.current.dispose();
        playerRef.current = null;
      }
    };
  }, [videoKey, onError]);

  return (
    <div data-vjs-player>
      <video ref={videoRef} className="video-js vjs-big-play-centered" />
      {!isReady && <div>Loading video player...</div>}
    </div>
  );
};

export default VideoPlayer;