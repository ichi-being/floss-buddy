Rails.application.routes.draw do
  # topページ
  root "static_pages#top"

  # 静的ページ
  get '/terms_of_service', to: 'static_pages#terms_of_service'
  get '/privacy_policy', to: 'static_pages#privacy_policy'

  get '/after_login', to: 'static_pages#after_login'
  resource :user, only: %i[new create]
end
