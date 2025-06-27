# 🏗️ API 仕様とアーキテクチャガイド

## 🎯 概要

vite_rails 統合環境における TODO アプリケーションの API 仕様、システムアーキテクチャ、およびデータフローについて詳しく解説します。

## 🔗 API エンドポイント仕様

### Base URL

```
http://localhost:4000/api/v1
```

### 1. TODO 一覧取得

```http
GET /api/v1/todos
```

**レスポンス例:**

```json
{
  "todos": [
    {
      "id": 1,
      "title": "Sample TODO",
      "description": "This is a sample todo item",
      "completed": false,
      "priority": "medium",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### 2. TODO 作成

```http
POST /api/v1/todos
Content-Type: application/json
```

**リクエストボディ:**

```json
{
  "title": "New TODO",
  "description": "Description of the new todo",
  "priority": "high"
}
```

**レスポンス例 (201 Created):**

```json
{
  "id": 2,
  "title": "New TODO",
  "description": "Description of the new todo",
  "completed": false,
  "priority": "high",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

**エラーレスポンス (422 Unprocessable Entity):**

```json
{
  "errors": ["Title can't be blank"]
}
```

### 3. TODO 詳細取得

```http
GET /api/v1/todos/:id
```

**レスポンス例 (200 OK):**

```json
{
  "id": 1,
  "title": "Sample TODO",
  "description": "This is a sample todo item",
  "completed": false,
  "priority": "medium",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

**エラーレスポンス (404 Not Found):**

```json
{
  "error": "TODO not found"
}
```

### 4. TODO 更新

```http
PUT /api/v1/todos/:id
Content-Type: application/json
```

**リクエストボディ:**

```json
{
  "title": "Updated TODO",
  "description": "Updated description",
  "completed": true,
  "priority": "low"
}
```

**レスポンス例 (200 OK):**

```json
{
  "id": 1,
  "title": "Updated TODO",
  "description": "Updated description",
  "completed": true,
  "priority": "low",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

### 5. TODO 削除

```http
DELETE /api/v1/todos/:id
```

**レスポンス例 (204 No Content):**

```
(空のレスポンス)
```

## 🏛️ システムアーキテクチャ

### アーキテクチャ図

```
┌─────────────────────────────────────────────────────────┐
│                    Browser                              │
│  ┌─────────────────────────────────────────────────┐    │
│  │            Vue.js SPA                           │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌──────────┐   │    │
│  │  │   TodoList  │ │  TodoForm   │ │ TodoItem │   │    │
│  │  └─────────────┘ └─────────────┘ └──────────┘   │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
                       HTTP Requests
                            │
┌─────────────────────────────────────────────────────────┐
│                 Rails Server                            │
│                 (Port 3001)                             │
│  ┌─────────────────────────────────────────────────┐    │
│  │           Application Layer                     │    │
│  │  ┌─────────────┐ ┌─────────────┐               │    │
│  │  │HomeController│ │ API::V1::   │               │    │
│  │  │             │ │TodosController│               │    │
│  │  └─────────────┘ └─────────────┘               │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Model Layer                        │    │
│  │  ┌─────────────────────────────────────────┐     │    │
│  │  │             Todo Model                  │     │    │
│  │  │        (ActiveModel::Model)             │     │    │
│  │  └─────────────────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
                    File System I/O
                            │
┌─────────────────────────────────────────────────────────┐
│                Data Storage                             │
│  ┌─────────────────────────────────────────────────┐    │
│  │              data/todos.json                    │    │
│  │        (JSON File-based Storage)                │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Vite Rails 統合アーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                Development Mode                         │
│                                                         │
│  ┌─────────────────┐    ┌─────────────────────────┐     │
│  │   Rails Server  │    │     Vite Dev Server     │     │
│  │   (Port 3001)   │    │      (Port 3036)        │     │
│  │                 │    │                         │     │
│  │  - HTML Views   │    │  - Vue Components       │     │
│  │  - API Routes   │    │  - Hot Module Reload    │     │
│  │  - Asset Tags   │    │  - ES Module Serving    │     │
│  └─────────────────┘    └─────────────────────────┘     │
│           │                        │                   │
│           └────────────────────────┘                   │
│                   Integration                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                Production Mode                          │
│                                                         │
│  ┌─────────────────────────────────────────────────┐     │
│  │                Rails Server                     │     │
│  │               (Port 3001)                       │     │
│  │                                                 │     │
│  │  - HTML Views                                   │     │
│  │  - API Routes                                   │     │
│  │  - Compiled Assets (from Vite)                  │     │
│  │  - Static File Serving                          │     │
│  └─────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## 📂 ディレクトリ構造詳細

### フロントエンド構造

```
app/frontend/                    # vite_rails標準ディレクトリ
├── entrypoints/
│   └── application.js           # メインエントリーポイント
├── components/                  # Vue.jsコンポーネント
│   ├── TodoList.vue            # TODO一覧表示
│   ├── TodoForm.vue            # TODO作成・編集フォーム
│   └── TodoItem.vue            # 個別TODOアイテム
├── styles/                     # スタイルシート
│   ├── application.scss        # メインスタイル
│   ├── components/             # コンポーネント別スタイル
│   └── variables.scss          # SCSS変数
├── utils/                      # ユーティリティ
│   ├── api.js                  # API通信ヘルパー
│   └── constants.js            # 定数定義
└── App.vue                     # メインアプリケーションコンポーネント
```

### バックエンド構造

```
app/
├── controllers/
│   ├── application_controller.rb    # ベースコントローラー
│   ├── home_controller.rb           # フロントエンド配信
│   └── api/
│       └── v1/
│           └── todos_controller.rb  # TODO API
├── models/
│   └── todo.rb                     # TODOモデル
└── views/
    ├── layouts/
    │   └── application.html.erb    # メインレイアウト
    └── home/
        └── index.html.erb          # SPA用ビュー

config/
├── routes.rb                       # ルーティング設定
├── application.rb                  # Rails設定
└── vite.json                       # vite_rails設定

data/
└── todos.json                      # JSONファイルストレージ
```

## 🔄 データフロー

### 1. TODO 作成フロー

```
Vue Component (TodoForm)
        │
        │ 1. User Input
        ▼
    Form Validation
        │
        │ 2. API Call
        ▼
   HTTP POST /api/v1/todos
        │
        │ 3. Request Processing
        ▼
Api::V1::TodosController#create
        │
        │ 4. Model Creation
        ▼
      Todo.new(params)
        │
        │ 5. File I/O
        ▼
    data/todos.json
        │
        │ 6. Response
        ▼
     JSON Response
        │
        │ 7. State Update
        ▼
   Vue Component Update
        │
        │ 8. UI Re-render
        ▼
    Updated TodoList
```

### 2. データ永続化フロー

```ruby
# app/models/todo.rb
class Todo
  include ActiveModel::Model
  include ActiveModel::Attributes

  # ファイルベース永続化
  def save
    if valid?
      data = load_data
      self.id = generate_id(data)
      self.created_at = Time.current.iso8601

      data['todos'] << attributes
      write_data(data)
      true
    else
      false
    end
  end

  private

  def load_data
    if File.exist?(data_file_path)
      JSON.parse(File.read(data_file_path))
    else
      { 'todos' => [] }
    end
  end

  def write_data(data)
    File.write(data_file_path, JSON.pretty_generate(data))
  end
end
```

## 🔐 セキュリティ考慮事項

### 1. CSRF 保護

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Web requests: CSRF protection enabled
  protect_from_forgery with: :exception, except: [:create, :update, :destroy]

  # API requests: CSRF protection disabled
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.path.start_with?('/api/')
  end
end
```

### 2. パラメータフィルタリング

```ruby
# app/controllers/api/v1/todos_controller.rb
private

def todo_params
  params.require(:todo).permit(:title, :description, :completed, :priority)
end
```

### 3. エラーハンドリング

```ruby
# app/controllers/api/v1/todos_controller.rb
def create
  todo = Todo.new(todo_params)

  if todo.save && todo.id.present? && todo.errors.empty?
    render json: todo, status: :created
  else
    render json: {
      errors: todo.errors.full_messages.presence || ['Failed to create TODO']
    }, status: :unprocessable_entity
  end
rescue StandardError => e
  render json: {
    error: 'Internal server error'
  }, status: :internal_server_error
end
```

## 📊 パフォーマンス最適化

### 1. フロントエンド最適化

```javascript
// app/frontend/utils/api.js
import axios from "axios";

// リクエストインターセプター
axios.interceptors.request.use((config) => {
  // CSRF token
  const token = document.querySelector('meta[name="csrf-token"]');
  if (token) {
    config.headers["X-CSRF-Token"] = token.getAttribute("content");
  }
  return config;
});

// レスポンスインターセプター
axios.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("API Error:", error.response?.data || error.message);
    return Promise.reject(error);
  }
);
```

### 2. バックエンド最適化

```ruby
# app/models/todo.rb (キャッシュ対応)
class Todo
  include ActiveModel::Model

  @@cache = nil
  @@cache_timestamp = nil

  def self.all
    if cache_valid?
      @@cache
    else
      reload_cache
    end
  end

  private

  def self.cache_valid?
    return false unless @@cache && @@cache_timestamp

    file_mtime = File.mtime(data_file_path)
    @@cache_timestamp >= file_mtime
  end

  def self.reload_cache
    data = load_data
    @@cache = data['todos'].map { |attrs| new(attrs) }
    @@cache_timestamp = Time.current
    @@cache
  end
end
```

## 🚀 拡張可能性

### 1. 認証システム統合

```ruby
# 将来の拡張例
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :api_request?

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
```

### 2. リアルタイム更新

```javascript
// WebSocket統合例
// app/frontend/utils/websocket.js
export class TodoWebSocket {
  constructor() {
    this.connect();
  }

  connect() {
    this.ws = new WebSocket("ws://localhost:3000/cable");
    this.ws.onmessage = this.handleMessage.bind(this);
  }

  handleMessage(event) {
    const data = JSON.parse(event.data);
    if (data.type === "todo_updated") {
      // Vue store update
      this.$store.dispatch("updateTodo", data.todo);
    }
  }
}
```

### 3. データベース統合

```ruby
# app/models/todo.rb (ActiveRecord版)
class Todo < ApplicationRecord
  validates :title, presence: true
  validates :priority, inclusion: { in: %w[low medium high] }

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :by_priority, ->(priority) { where(priority: priority) }
end
```

## 📋 運用監視

### 1. ログ設定

```ruby
# config/application.rb
config.log_level = :info
config.log_tags = [:request_id, :remote_ip]

# カスタムログ
Rails.logger.info "Todo created: #{todo.id}"
```

### 2. メトリクス収集

```ruby
# app/controllers/api/v1/todos_controller.rb
def create
  start_time = Time.current

  # ... todo creation logic

  Rails.logger.info "Todo creation took #{Time.current - start_time}s"
end
```
