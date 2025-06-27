# 📚 Vite Rails 導入ガイド

## 🎯 概要

このドキュメントでは、Docker 環境で Rails + Vue.js + vite_rails を統合する手順と、発生しやすい問題の対処法について説明します。

## 🛠️ 前提条件

- Rails 7.0 アプリケーション
- Vue.js 2.7
- Docker 環境
- Bundler, Yarn/NPM がインストール済み

## 📋 ステップバイステップ導入手順

### 1. Gemfile への追加

```ruby
# Gemfile
gem 'vite_rails'
```

### 2. Dockerfile の設定

```dockerfile
FROM ruby:3.1.6

# Node.js 18.x, Yarn, 必要パッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y curl build-essential libpq-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

# Gemfileのみをコピー（Gemfile.lockは削除済みなので除外）
COPY Gemfile ./

# bundlerを更新
RUN gem update bundler
RUN bundle config set --local path vendor/bundle

# package.jsonをコピー（存在する場合）
COPY package.json yarn.lock* ./

# アプリケーションコードをコピー
COPY . .

# bundle install（これでGemfile.lockが新しく生成される）
RUN bundle install --retry 3

# Node.jsの依存関係をインストール
RUN yarn install

# ポート開放（Viteのポート3036も含める）
EXPOSE 3001 3036

# デフォルトコマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]
```

### 3. package.json の設定

```json
{
  "name": "frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "cd frontend && vite",
    "build": "cd frontend && vite build"
  },
  "dependencies": {
    "vue": "^2.7.16"
  },
  "devDependencies": {
    "@vitejs/plugin-vue2": "^2.0.0",
    "vite": "^5.0.0",
    "vite-plugin-ruby": "^5.1.0"
  }
}
```

### 4. vite_rails のインストール

```bash
# Docker環境の場合
docker compose exec app bundle exec vite install

# ローカル環境の場合
bundle exec vite install
```

### 5. Vue.js プラグインの設定

```javascript
// vite.config.mjs
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue2";

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
});
```

### 6. ApplicationController の修正

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # API専用からBase継承に変更
  protect_from_forgery with: :exception, except: [:create, :update, :destroy]

  # API requests are exempt from CSRF
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.path.start_with?('/api/')
  end
end
```

### 7. HTML ビューの作成

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>TODO App</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= vite_client_tag %>
    <%= vite_javascript_tag 'application' %>
  </head>

  <body>
    <div id="app"></div>
  </body>
</html>
```

```erb
<!-- app/views/home/index.html.erb -->
<!-- Vue.jsアプリがマウントされるため、内容は空でOK -->
```

### 8. ルーティングの設定

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # APIルート
  namespace :api do
    namespace :v1 do
      resources :todos
    end
  end

  # フロントエンドルート
  root 'home#index'

  # SPAのため、すべてのルートをhome#indexにフォールバック
  get '*path', to: 'home#index'
end
```

### 9. コントローラーの作成

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    # Vue.jsアプリを配信
  end
end
```

## 🚀 ディレクトリ構造

インストール後、以下の構造になります：

```
vite-rails/
├── app/frontend/                 # vite_rails標準ディレクトリ
│   ├── entrypoints/
│   │   └── application.js        # メインエントリーポイント
│   ├── App.vue                   # Vue.jsメインコンポーネント
│   └── main.js
├── config/
│   └── vite.json                 # vite_rails設定
├── vite.config.mjs               # Vite設定
├── bin/
│   └── vite                      # Viteコマンド実行ファイル
└── frontend/                     # 既存のフロントエンド（非使用）
```

## ⚠️ 重要なポイント

### 1. ディレクトリ構造の注意点

- `app/frontend/`が vite_rails の標準構造
- `frontend/`は既存の独立した Vite プロジェクト（使用されない）
- `config/vite.json`の`sourceCodeDir`設定で使用ディレクトリが決まる

### 2. Vue.js 2.7 対応

- `@vitejs/plugin-vue2`を使用する（Vue 3 用のプラグインではない）
- Vue 2.7 は Composition API が利用可能

### 3. ApplicationController の継承

- API 専用の場合は`ActionController::API`
- HTML ビューも配信する場合は`ActionController::Base`
- vite_rails を使用する場合は必ず`ActionController::Base`

## 🔧 開発環境での起動

```bash
# Dockerの場合
docker compose up

# 別ターミナルでViteサーバー起動（開発時のみ）
docker compose exec app bin/vite dev

# ローカルの場合
# ターミナル1: Railsサーバー
bundle exec rails server

# ターミナル2: Viteサーバー（開発時のみ）
bin/vite dev
```

## 📝 次のステップ

1. [トラブルシューティングガイド](02_troubleshooting_guide.md)で一般的な問題と解決策を確認
2. [設定ファイル解説](03_configuration_guide.md)で詳細な設定方法を学習
3. [API とアーキテクチャ](04_api_and_architecture.md)でシステム全体を理解
