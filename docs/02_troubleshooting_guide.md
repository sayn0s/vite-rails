# 🚨 Vite Rails トラブルシューティングガイド

## 🎯 概要

vite_rails 導入時に発生する一般的な問題と、実際に遭遇したエラーの解決策をまとめています。

## 🔧 インストール関連の問題

### 1. `bundler: command not found: vite`

**症状:**

```bash
$ bundle exec vite install
bundler: command not found: vite
Could not find command "vite".
```

**原因:**

- Gemfile.lock に vite_rails が含まれていない
- bundle install が正常に完了していない

**解決策:**

```bash
# Docker環境の場合
# 1. Gemfile.lockを削除
rm Gemfile.lock

# 2. Dockerコンテナを再ビルド
docker compose build --no-cache

# 3. 再度インストール実行
docker compose exec app bundle exec vite install
```

### 2. Node.js の依存関係エラー

**症状:**

```bash
Error: Cannot find module '@vitejs/plugin-vue2'
```

**原因:**

- package.json の依存関係がインストールされていない
- Node.js のバージョン不整合

**解決策:**

```bash
# 1. node_modules削除
rm -rf node_modules yarn.lock

# 2. 依存関係の再インストール
yarn install

# 3. Dockerの場合は再ビルド
docker compose build
```

## 🌐 HTML ビューレンダリング問題

### 3. `No template found` エラー

**症状:**

```bash
ActionController::UnknownFormat: ActionController::UnknownFormat
No template found for HomeController#index
```

**原因:**

- ApplicationController が`ActionController::API`を継承している
- HTML ビューのレンダリング機能が無効化されている

**解決策:**

```ruby
# app/controllers/application_controller.rb
# 変更前
class ApplicationController < ActionController::API
end

# 変更後
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: [:create, :update, :destroy]
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.path.start_with?('/api/')
  end
end
```

### 4. 真っ白な画面が表示される

**症状:**

- ブラウザに何も表示されない
- コンソールエラーなし

**原因:**

- HTML ビューファイルが存在しない
- Vite タグが適切に設定されていない

**解決策:**

```erb
<!-- app/views/layouts/application.html.erb を作成 -->
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

## 🔄 Vue.js 処理エラー

### 5. `.vue`ファイルの処理エラー

**症状:**

```bash
Failed to parse source for import analysis because the content
contains invalid JS syntax. Install @vitejs/plugin-vue to handle .vue files.
```

**原因:**

- Vue.js プラグインが vite.config.mjs に設定されていない
- Vue 2.7 用のプラグインを使用していない

**解決策:**

```javascript
// vite.config.mjs
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue2"; // Vue 2.7用プラグイン

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
});
```

```json
// package.jsonの依存関係確認
{
  "devDependencies": {
    "@vitejs/plugin-vue2": "^2.0.0", // Vue 2.7用
    "vite": "^5.0.0",
    "vite-plugin-ruby": "^5.1.0"
  }
}
```

## 📝 文字エンコーディング問題

### 6. 日本語文字化け

**症状:**

```bash
ERB::SyntaxError: invalid multibyte char (US-ASCII)
(erb):7: syntax error, unexpected local variable or method
M-i^@^@M-^AM-^HM-^@M-^AM-^IM-^@M-^@M-^@
```

**原因:**

- ERB テンプレートの文字エンコーディング問題
- 日本語文字列の処理エラー

**一時的解決策:**

```ruby
# 日本語文字列を英語に変更
# 変更前
title: "新しいTODO"

# 変更後
title: "New TODO"
```

**恒久的解決策:**

```ruby
# config/application.rb
config.encoding = "utf-8"

# ファイルの先頭にマジックコメント追加
# -*- coding: utf-8 -*-
```

## 🔌 API 通信エラー

### 7. 422 エラーが返される（データは保存される）

**症状:**

```javascript
// コンソールエラー
POST /api/v1/todos 422 (Unprocessable Entity)
// しかし、実際にはTODOは作成されている
```

**原因:**

- `todo.persisted?`メソッドが ActiveModel::Model で正しく動作しない
- 成功判定ロジックの問題

**解決策:**

```ruby
# app/controllers/api/v1/todos_controller.rb
def create
  todo = Todo.new(todo_params)

  if todo.save
    # 変更前
    # if todo.persisted?

    # 変更後
    if todo.id.present? && todo.errors.empty?
      render json: todo, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  else
    render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
  end
end
```

## 🐳 Docker 関連問題

### 8. Vite ポートアクセスエラー

**症状:**

```bash
Vite dev server not accessible from host
```

**原因:**

- Docker のポートマッピング不足
- Vite サーバーのホスト設定問題

**解決策:**

```yaml
# docker-compose.yml
services:
  app:
    ports:
      - "4000:3001" # Rails
      - "3036:3036" # Vite dev server
```

```json
# config/vite.json
{
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036,
    "host": "0.0.0.0"  // Docker環境用
  }
}
```

## 📊 ディレクトリ構造の混乱

### 9. フロントエンドファイルが見つからない

**症状:**

```bash
Cannot resolve "./App.vue"
```

**原因:**

- 複数の frontend ディレクトリが存在
- vite_rails が参照するディレクトリが不明確

**解決策:**

```json
// config/vite.json で確認
{
  "all": {
    "sourceCodeDir": "app/frontend" // これが実際に使用されるディレクトリ
  }
}
```

```bash
# 使用されていないディレクトリの確認
ls -la frontend/     # 旧ディレクトリ（未使用）
ls -la app/frontend/ # vite_rails標準ディレクトリ（使用中）
```

## 🔍 デバッグ方法

### 一般的なデバッグ手順

1. **ログの確認**

```bash
# Rails ログ
docker compose logs app

# Vite ログ
docker compose exec app bin/vite dev
```

2. **設定ファイルの確認**

```bash
# vite_rails設定
cat config/vite.json

# Vite設定
cat vite.config.mjs

# パッケージ依存関係
cat package.json
```

3. **ポート確認**

```bash
# 使用中ポートの確認
netstat -tulpn | grep :3001
netstat -tulpn | grep :3036
```

## 🚀 予防策

### 1. 開発環境のベストプラクティス

- Gemfile.lock をコミットし、依存関係を固定
- Docker 環境では必要なポートをすべて公開
- package.json の lock ファイルも同期

### 2. 設定ファイルの管理

- vite.config.mjs の設定を環境別に分離
- 本番環境では適切なビルド設定を使用

### 3. エラーハンドリング

- API レスポンスの統一
- フロントエンドでの適切なエラー表示
- ログレベルの適切な設定
