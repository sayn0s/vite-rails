Rails.application.routes.draw do
  # APIルートを最初に定義
  namespace :api do
    namespace :v1 do
      resources :todos, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # ルートパスをフロントエンドに
  root 'frontend#index'
  
  # APIパス以外のみキャッチ
  get '*path', to: 'frontend#index', constraints: ->(req) { 
    !req.path.start_with?('/api') && !req.xhr? && req.format.html? 
  }
end 