# Video_Streaming_POC
This POC implements a secure video streaming platform with a Ruby on Rails backend and a React frontend. It provides a robust solution for uploading, processing, and streaming videos with a focus on security and preventing easy downloads.

# Secure Video Streaming Platform

## Description

This project implements a secure video streaming platform with a Ruby on Rails backend and a React frontend. It provides a robust solution for uploading, processing, and streaming videos with a focus on security and preventing easy downloads.

## Key Features

- Secure video upload and storage using Amazon S3
- Video conversion to HLS (HTTP Live Streaming) format for adaptive bitrate streaming
- JWT token-based authentication for accessing video streams
- React-based frontend with video.js for smooth video playback
- Prevention of direct video downloads

## Technology Stack

### Backend
- Ruby on Rails (API mode)
- AWS SDK for S3 integration
- FFmpeg for video processing
- JWT for token-based authentication

### Frontend
- React.js
- video.js for HLS video playback
- Axios for API communication

## Installation

### Backend Setup
1. Clone the repository
2. Navigate to the backend directory
3. Install dependencies:
   ```
   bundle install
   ```
4. Set up environment variables (AWS credentials, JWT secret, etc.)
5. Run database migrations:
   ```
   rails db:migrate
   ```
6. Start the Rails server:
   ```
   rails s
   ```

### Frontend Setup
1. Navigate to the frontend directory
2. Install dependencies:
   ```
   npm install
   ```
3. Start the React development server:
   ```
   npm start
   ```

## Usage

1. Upload a video through the React frontend
2. The backend processes the video and converts it to HLS format
3. Once processing is complete, the video becomes available for streaming
4. Play the video using the secure video player in the frontend

## Security Features

- JWT token authentication for video segment requests
- Short-lived, per-segment tokens to prevent unauthorized access
- CORS policy implementation to restrict API access
- Secure S3 bucket configuration
- Frontend measures to discourage easy video downloading

## API Endpoints

- `POST /videos/upload`: Upload a new video
- `GET /videos/:key/manifest.m3u8`: Retrieve the HLS manifest for a video
- `GET /videos/:key/:segment`: Retrieve a specific video segment

## Contributing

Contributions to improve the platform are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- FFmpeg for video processing capabilities
- video.js for the flexible video player
- The Ruby on Rails and React communities for their excellent documentation and support

