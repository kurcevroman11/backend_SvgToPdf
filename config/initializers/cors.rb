Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Укажи фронтенд адрес (React/Vite)
    origins '*' # или '*' для разработки

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
