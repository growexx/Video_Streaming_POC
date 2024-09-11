Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'  # In production, replace with your frontend's origin
      resource '*',
        headers: :any,
        methods: [:get, :post, :options],
        expose: ['Content-Type', 'Content-Length', 'Accept-Ranges', 'Content-Range']
    end
  end
