# config/routes.rb
Rails.application.routes.draw do
  post 'videos/upload', to: 'videos#upload'
  get 'videos/:key/manifest.m3u8', to: 'videos#hls_manifest', constraints: { key: /.*/ }
  get 'videos/:key/:segment', to: 'videos#hls_segment', constraints: { key: /.*/, segment: /.*/ }
end