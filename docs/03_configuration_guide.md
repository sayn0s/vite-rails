# ⚙️ 設定ファイル解説ガイド

## 🎯 概要

vite_rails 環境における各設定ファイルの詳細な説明と、最適化のポイントについて解説します。

## 📁 設定ファイル一覧

### 1. `config/vite.json` - vite_rails 設定

vite_rails の中心的な設定ファイルです。

```json
{
  "all": {
    "sourceCodeDir": "app/frontend",
    "watchAdditionalPaths": []
  },
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036
  },
  "test": {
    "autoBuild": true,
    "publicOutputDir": "vite-test",
    "port": 3037
  }
}
```

#### 設定項目の詳細

| 項目                   | 説明                             | 推奨値            |
| ---------------------- | -------------------------------- | ----------------- |
| `sourceCodeDir`        | フロントエンドソースディレクトリ | `"app/frontend"`  |
| `watchAdditionalPaths` | 追加監視パス                     | `[]`              |
| `autoBuild`            | 自動ビルド有効化                 | `true` (開発環境) |
| `publicOutputDir`      | 公開ディレクトリ                 | `"vite-dev"`      |
| `port`                 | Vite サーバーポート              | `3036`            |

#### 本番環境設定の追加

```json
{
  "all": {
    "sourceCodeDir": "app/frontend",
    "watchAdditionalPaths": []
  },
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036,
    "host": "0.0.0.0"
  },
  "production": {
    "autoBuild": false,
    "publicOutputDir": "vite",
    "assetsDir": "vite-assets"
  },
  "test": {
    "autoBuild": true,
    "publicOutputDir": "vite-test",
    "port": 3037
  }
}
```

### 2. `vite.config.mjs` - Vite 設定

Vue.js 2.7 統合のための設定ファイルです。

```javascript
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue2";

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
});
```

#### 拡張設定例

```javascript
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue2";
import { resolve } from "path";

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue({
      // Vue 2.7 固有の設定
      template: {
        compilerOptions: {
          // カスタムディレクティブの設定
        },
      },
    }),
  ],

  // エイリアス設定
  resolve: {
    alias: {
      "@": resolve(__dirname, "app/frontend"),
      components: resolve(__dirname, "app/frontend/components"),
    },
  },

  // ビルド設定
  build: {
    // チャンク分割
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ["vue"],
          // その他のvendorライブラリ
        },
      },
    },
  },

  // 開発サーバー設定
  server: {
    host: "0.0.0.0", // Docker環境対応
    port: 3036,
    hmr: {
      port: 3036,
    },
  },

  // CSS設定
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@import "@/styles/variables.scss";`,
      },
    },
  },
});
```

### 3. `package.json` - Node.js 依存関係

```json
{
  "name": "frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "cd frontend && vite",
    "build": "cd frontend && vite build",
    "vite:install": "bundle exec vite install"
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

#### 拡張依存関係の例

```json
{
  "dependencies": {
    "vue": "^2.7.16",
    "axios": "^1.0.0",
    "vue-router": "^3.6.5",
    "vuex": "^3.6.2"
  },
  "devDependencies": {
    "@vitejs/plugin-vue2": "^2.0.0",
    "vite": "^5.0.0",
    "vite-plugin-ruby": "^5.1.0",
    "sass": "^1.50.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.0.0",
    "eslint-plugin-vue": "^9.0.0"
  }
}
```

### 4. `app/frontend/entrypoints/application.js` - エントリーポイント

vite_rails のメインエントリーファイルです。

```javascript
// app/frontend/entrypoints/application.js
console.log("Vite ⚡️ Rails");

// Vue 2.7 application initialization
import Vue from "vue";
import App from "../App.vue";

new Vue({
  render: (h) => h(App),
}).$mount("#app");
```

#### 拡張エントリーポイント例

```javascript
// app/frontend/entrypoints/application.js
import Vue from "vue";
import App from "../App.vue";
import router from "../router";
import store from "../store";

// グローバルスタイル
import "../styles/application.scss";

// フォント
import "../styles/fonts.css";

// アイコン
import "../icons";

// グローバルコンポーネント
import "../components/globals";

// Vue app initialization (Vue 2.7)
new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");

// Hot Module Replacement
if (import.meta.hot) {
  import.meta.hot.accept();
}
```

## 🔗 Rails 側設定

### 1. `app/views/layouts/application.html.erb`

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>TODO App</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <!-- Vite Rails integration -->
    <%= vite_client_tag %>
    <%= vite_javascript_tag 'application' %>
    <%= vite_stylesheet_tag 'application', 'data-turbo-track': 'reload' %>
  </head>

  <body>
    <div id="app"></div>

    <!-- CSRF Token for Vue.js -->
    <meta name="csrf-token" content="<%= form_authenticity_token %>">
  </body>
</html>
```

### 2. `config/routes.rb`

```ruby
Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      resources :todos
    end
  end

  # Frontend routes
  root 'home#index'

  # SPA fallback - すべてのルートをVue.jsに委任
  get '*path', to: 'home#index', constraints: lambda { |req|
    !req.xhr? && req.format.html?
  }
end
```

### 3. `app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  # CSRF protection for web requests
  protect_from_forgery with: :exception, except: [:create, :update, :destroy]

  # API requests are exempt from CSRF
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.path.start_with?('/api/')
  end

  # JSON error handling
  def handle_json_error(error)
    render json: {
      error: error.message,
      status: response.status
    }
  end
end
```

## 🐳 Docker 設定

### 1. `Dockerfile`

```dockerfile
FROM ruby:3.1.6

# System dependencies
RUN apt-get update -qq && \
    apt-get install -y curl build-essential libpq-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

# Ruby dependencies
COPY Gemfile ./
RUN gem update bundler
RUN bundle config set --local path vendor/bundle

# Node.js dependencies
COPY package.json yarn.lock* ./

# Application code
COPY . .

# Install dependencies
RUN bundle install --retry 3
RUN yarn install

# Port exposure
EXPOSE 3001 3036

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]
```

### 2. `docker-compose.yml`

```yaml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "4000:3001" # Rails server
      - "3036:3036" # Vite dev server
    volumes:
      - .:/app
      - bundle_cache:/app/vendor/bundle
      - node_modules:/app/node_modules
    environment:
      - BUNDLE_PATH=/app/vendor/bundle
      - NODE_ENV=development
      - RAILS_ENV=development
    stdin_open: true
    tty: true

volumes:
  bundle_cache:
  node_modules:
```

## 🚀 最適化設定

### 1. 本番環境ビルド設定

```javascript
// vite.config.mjs (本番環境最適化)
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue2";

export default defineConfig({
  plugins: [RubyPlugin(), vue()],

  build: {
    // 本番ビルド最適化
    minify: "terser",
    sourcemap: false,

    rollupOptions: {
      output: {
        // アセットファイル名の最適化
        assetFileNames: "assets/[name]-[hash].[ext]",
        chunkFileNames: "assets/[name]-[hash].js",
        entryFileNames: "assets/[name]-[hash].js",

        // チャンク分割
        manualChunks: {
          vendor: ["vue"],
          utils: ["axios"],
        },
      },
    },

    // Bundle size analysis
    reportCompressedSize: true,
    chunkSizeWarningLimit: 1000,
  },
});
```

### 2. 開発環境最適化

```json
// config/vite.json (開発環境最適化)
{
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036,
    "host": "0.0.0.0",
    "https": false,
    "hmr": true,
    "clearScreen": false
  }
}
```

## 🔍 デバッグ設定

### 1. ログレベル設定

```javascript
// vite.config.mjs (デバッグ設定)
export default defineConfig({
  // ... other config

  // ログレベル
  logLevel: "info", // 'error' | 'warn' | 'info' | 'silent'

  // カスタムログ
  define: {
    __VUE_OPTIONS_API__: true,
    __VUE_PROD_DEVTOOLS__: false,
    __DEV__: process.env.NODE_ENV !== "production",
  },
});
```

### 2. Vue Devtools 設定

```javascript
// app/frontend/main.js (開発環境)
import { createApp } from "vue";
import App from "./App.vue";

const app = createApp(App);

// Vue Devtools (開発環境のみ)
if (process.env.NODE_ENV === "development") {
  app.config.devtools = true;
  app.config.debug = true;
}

app.mount("#app");
```

## 📋 設定チェックリスト

### ✅ 必須設定項目

- [ ] `config/vite.json`で sourceCodeDir が正しく設定されている
- [ ] `vite.config.mjs`に Vue 2.7 プラグインが含まれている
- [ ] `ApplicationController`が`ActionController::Base`を継承している
- [ ] HTML レイアウトに Vite タグが含まれている
- [ ] package.json に必要な依存関係がすべて含まれている

### ✅ 最適化設定項目

- [ ] 本番環境でのビルド最適化設定
- [ ] チャンク分割設定
- [ ] CSS 前処理設定
- [ ] エイリアス設定
- [ ] Docker 環境でのポート公開設定

### ✅ トラブルシューティング準備

- [ ] ログ出力設定
- [ ] デバッグモード設定
- [ ] エラーハンドリング設定
- [ ] 開発環境とのポート競合回避
