require 'sidekiq/web'
require 'sidekiq-scheduler/web'

# Basic 認証
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
end

Rails.application.routes.draw do
  # topページ
  root "static_pages#top"

  # 静的ページ
  get '/terms_of_service', to: 'static_pages#terms_of_service'
  get '/privacy_policy', to: 'static_pages#privacy_policy'

  resource :user, only: %i[new create destroy]
  resource :profile, controller: 'users', only: [:show]

  # webhook
  post '/callback', to: 'webhook#callback'

  mount Sidekiq::Web => '/sidekiq'
end
