# app/controllers/videos_controller.rb
require 'streamio-ffmpeg'

class VideosController < ApplicationController
  def upload
    file = params[:file]
    
    if file
      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
  
      bucket = ENV['S3_BUCKET_NAME']
      key = "videos/#{SecureRandom.uuid}-#{file.original_filename}"
  
      begin
        s3_client.put_object(
          bucket: bucket,
          key: key,
          body: file.read,
          content_type: file.content_type
        )
  
        Rails.logger.info "File uploaded successfully with key: #{key}"
  
        # Convert to HLS
        convert_to_hls(key)
  
        render json: { message: 'Video uploaded and converted successfully', key: key }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Error: #{e.message}"
        render json: { error: 'Failed to upload and convert video' }, status: :internal_server_error
      end
    else
      render json: { error: 'No file provided' }, status: :bad_request
    end
  end

  def hls_manifest
    key = params[:key]
    manifest_key = "#{key}/manifest.m3u8"
  
    Rails.logger.info "Attempting to fetch manifest with key: #{manifest_key}"
  
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  
    begin
      response = s3_client.get_object(bucket: ENV['S3_BUCKET_NAME'], key: manifest_key)
      Rails.logger.info "Manifest found. Content type: #{response.content_type}"
      send_data response.body.read, type: 'application/vnd.apple.mpegurl', disposition: 'inline'
    rescue Aws::S3::Errors::NoSuchKey
      Rails.logger.error "Manifest not found for key: #{manifest_key}"
      render json: { error: 'Manifest not found' }, status: :not_found
    rescue StandardError => e
      Rails.logger.error "Error fetching manifest: #{e.message}"
      render json: { error: 'Failed to retrieve manifest' }, status: :internal_server_error
    end
  end

def hls_segment
  key = params[:key]
  segment = params[:segment]
  segment_key = "#{key}/#{segment}"

  s3_client = Aws::S3::Client.new(
    region: ENV['AWS_REGION'],
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )

  begin
    response = s3_client.get_object(bucket: ENV['S3_BUCKET_NAME'], key: segment_key)
    send_data response.body.read, type: 'video/MP2T', disposition: 'inline'
  rescue Aws::S3::Errors::NoSuchKey
    render json: { error: 'Segment not found' }, status: :not_found
  rescue StandardError => e
    Rails.logger.error "Error fetching segment: #{e.message}"
    render json: { error: 'Failed to retrieve segment' }, status: :internal_server_error
  end
end

  private

  def convert_to_hls(key)
    s3 = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    bucket = s3.bucket(ENV['S3_BUCKET_NAME'])
  
    # Download the file from S3
    temp_file = Tempfile.new(['video', '.mp4'])
    bucket.object(key).download_file(temp_file.path)
  
    # Convert to HLS
    movie = FFMPEG::Movie.new(temp_file.path)
    output_dir = File.dirname(temp_file.path)
    output_path = File.join(output_dir, 'manifest.m3u8')
  
    Rails.logger.info "Converting video to HLS: #{output_path}"
  
    movie.transcode(output_path, %W(-codec:v libx264 -codec:a aac -hls_time 10 -hls_list_size 0 -f hls))
  
    # Upload HLS files to S3
    Dir.glob(File.join(output_dir, '*.m3u8')).each do |file|
      new_key = "#{key}/#{File.basename(file)}"
      Rails.logger.info "Uploading manifest: #{new_key}"
      bucket.object(new_key).upload_file(file, content_type: 'application/vnd.apple.mpegurl')
    end
  
    Dir.glob(File.join(output_dir, '*.ts')).each do |file|
      new_key = "#{key}/#{File.basename(file)}"
      Rails.logger.info "Uploading segment: #{new_key}"
      bucket.object(new_key).upload_file(file, content_type: 'video/MP2T')
    end
  
    # Clean up temporary files
    temp_file.unlink
    File.delete(output_path)
    Dir.glob(File.join(output_dir, '*.ts')).each { |file| File.delete(file) }
  
    Rails.logger.info "HLS conversion and upload completed for key: #{key}"
  end
end