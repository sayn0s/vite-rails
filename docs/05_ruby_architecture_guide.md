# 🏛️ Ruby アーキテクチャ構成ガイド

## 🎯 概要

このドキュメントでは、vite_rails プロジェクトにおける Ruby/Rails アーキテクチャの詳細な構成と設計パターンについて解説します。ActiveModel::Model を使用したファイルベース永続化、コントローラー階層、および Rails 固有の実装について詳しく説明します。

## 🏗️ アーキテクチャ概要

### Rails アプリケーション構成

```
ViteRails::Application
├── ActionController::Base (ApplicationController)
│   ├── FrontendController (HTML ビュー配信)
│   └── ActionController::API (ApiController)
│       └── Api::V1::TodosController (API エンドポイント)
├── ActiveModel::Model (Todo)
│   ├── ActiveModel::Attributes
│   ├── ActiveModel::Validations
│   └── ActiveModel::Serialization
└── File System Storage (JSON)
    └── data/todos.json
```

## 📁 ディレクトリ構造とファイル役割

### コントローラー階層

```
app/controllers/
├── application_controller.rb    # ベースコントローラー (ActionController::Base)
├── frontend_controller.rb       # SPA 配信用コントローラー
├── api_controller.rb            # API ベースコントローラー (ActionController::API)
└── api/
    └── v1/
        └── todos_controller.rb  # TODO API 実装
```

### モデル構成

```
app/models/
└── todo.rb                     # ActiveModel::Model ベースの TODO モデル
```

### 設定ファイル

```
config/
├── application.rb              # Rails アプリケーション設定
├── routes.rb                   # ルーティング設定
├── vite.json                   # vite_rails 設定
└── environments/               # 環境別設定
```

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

## 🎭 コントローラー設計パターン

### 1. ApplicationController - ベースコントローラー

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
end
```

**設計のポイント:**

- `ActionController::Base` を継承して HTML レンダリング機能を有効化
- CSRF 保護を Web リクエストに適用、API リクエストは除外
- 共通の認証・認可ロジックの基盤を提供

### 2. ApiController - API 専用ベース

```ruby
class ApiController < ActionController::API
  # CSRF protection is disabled for API endpoints
  # but you can add authentication/authorization here
end
```

**設計のポイント:**

- `ActionController::API` を継承して軽量な API レスポンス
- 将来的な認証・認可機能の拡張ポイント
- JSON レスポンスに特化した設計

### 3. Api::V1::TodosController - RESTful API

```ruby
class Api::V1::TodosController < ApiController
  before_action :find_todo, only: [:show, :update, :destroy]

  def index
    todos = Todo.all
    render json: todos.map(&:to_hash)
  end

  def create
    todo = Todo.create(todo_params)

    # カスタム成功判定ロジック
    if todo.id.present? && (!todo.respond_to?(:errors) || todo.errors.empty?)
      render json: todo.to_hash, status: :created
    else
      render json: {
        error: "Failed to create todo",
        details: todo.errors&.full_messages || ["Unknown error"]
      }, status: :unprocessable_entity
    end
  rescue => e
    render json: {
      error: "Server error",
      message: e.message
    }, status: :internal_server_error
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end

  def find_todo
    @todo = Todo.find(params[:id])
    render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end
end
```

**設計のポイント:**

- RESTful な API 設計パターンの実装
- Strong Parameters によるパラメータフィルタリング
- 例外処理とエラーレスポンスの統一
- before_action による共通処理の抽出

## 🗄️ モデル設計パターン

### ActiveModel::Model ベースの設計

```ruby
class Todo
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization
  include ActiveModel::Validations

  # 属性定義
  attribute :id, :integer
  attribute :title, :string
  attribute :completed, :boolean, default: false
  attribute :created_at, :string

  # バリデーション
  validates :title, presence: true, length: { minimum: 1 }

  # データファイルの定数定義
  DATA_FILE = Rails.root.join('data', 'todos.json')
end
```

**設計のポイント:**

- ActiveRecord を使わずにモデル機能を実現
- 型安全な属性定義
- Rails 標準のバリデーション機能を活用
- ファイルパスの一元管理

### ファイルベース永続化パターン

```ruby
class Todo
  # クラスメソッドによるファインダーパターン
  def self.all
    load_data.map { |data| new(data) }
  end

  def self.find(id)
    all.find { |todo| todo.id == id.to_i }
  end

  def self.create(attributes)
    todo = new(attributes.merge(
      id: next_id,
      created_at: Time.current.iso8601
    ))

    if todo.valid?
      todos = all
      todos << todo
      save_data(todos.map(&:to_hash))
      todo.instance_variable_set(:@persisted, true)
      todo
    else
      todo
    end
  end

  # インスタンスメソッドによる操作
  def update(attributes)
    assign_attributes(attributes)
    save
  end

  def save
    todos = self.class.all
    index = todos.find_index { |t| t.id == id }
    todos[index] = self if index
    self.class.save_data(todos.map(&:to_hash))
    self
  end

  def destroy
    todos = self.class.all.reject { |t| t.id == id }
    self.class.save_data(todos.map(&:to_hash))
    true
  end

  # ActiveRecord 風の永続化状態管理
  def persisted?
    @persisted == true || (id.present? && errors.empty?)
  end

  private

  # ファイル I/O の抽象化
  def self.load_data
    return [] unless File.exist?(DATA_FILE)

    begin
      content = File.read(DATA_FILE, encoding: 'UTF-8')
      JSON.parse(content)
    rescue JSON::ParserError, Errno::ENOENT => e
      Rails.logger.error "Error loading data: #{e.message}"
      []
    end
  end

  def self.save_data(todos_array)
    begin
      FileUtils.mkdir_p(File.dirname(DATA_FILE))
      File.write(DATA_FILE, JSON.pretty_generate(todos_array), encoding: 'UTF-8')
    rescue => e
      Rails.logger.error "Error saving data: #{e.message}"
      raise e
    end
  end

  def self.next_id
    existing_ids = load_data.map { |t| t['id'] }.compact
    existing_ids.empty? ? 1 : existing_ids.max + 1
  end
end
```

**設計のポイント:**

- ActiveRecord 風の API を ActiveModel::Model で実現
- ファイル I/O の例外処理とエラーハンドリング
- ID 自動生成とユニーク性の保証
- UTF-8 エンコーディングの明示的指定
- JSON フォーマットでの可読性確保

## 🔀 ルーティング設計

### API とフロントエンドの分離

```ruby
Rails.application.routes.draw do
  # API ルートを最初に定義（優先度確保）
  namespace :api do
    namespace :v1 do
      resources :todos, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # フロントエンド配信
  root 'frontend#index'

  # SPA フォールバック（API パス以外）
  get '*path', to: 'frontend#index', constraints: ->(req) {
    !req.path.start_with?('/api') && !req.xhr? && req.format.html?
  }
end
```

**設計のポイント:**

- API ルートの優先順位を確保
- SPA ルーティングとの競合回避
- 制約条件による適切なルート分岐
- バージョニング対応（v1 namespace）

## 🔧 設定とミドルウェア

### アプリケーション設定

```ruby
module ViteRails
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true  # API モードを有効化
  end
end
```

**設計のポイント:**

- Rails 7.0 のデフォルト設定を活用
- API モード有効化による軽量化
- 将来的な設定拡張の基盤

## 🎯 設計パターンの特徴

### 1. Repository パターンの実装

```ruby
class Todo
  # Repository Pattern の実装例
  def self.all
    load_data.map { |data| new(data) }
  end

  def self.find(id)
    all.find { |todo| todo.id == id.to_i }
  end

  private

  def self.load_data
    # データアクセスロジックの抽象化
  end
end
```

### 2. Factory パターンの活用

```ruby
def self.create(attributes)
  todo = new(attributes.merge(
    id: next_id,
    created_at: Time.current.iso8601
  ))
  # オブジェクト生成ロジックの集約
end
```

### 3. Template Method パターン

```ruby
def create
  todo = Todo.create(todo_params)

  if success_condition?(todo)
    success_response(todo)
  else
    error_response(todo)
  end
rescue => e
  exception_response(e)
end
```

## 🚀 パフォーマンス考慮事項

### 1. ファイル I/O の最適化

```ruby
# キャッシュ機能の実装例
class Todo
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

    file_mtime = File.mtime(DATA_FILE)
    @@cache_timestamp >= file_mtime
  end
end
```

### 2. メモリ効率の向上

```ruby
# 遅延読み込みパターン
def self.find(id)
  # 全データを読み込まずに特定のレコードを検索
  load_data.lazy.map { |data| new(data) }.find { |todo| todo.id == id.to_i }
end
```

## 🔍 デバッグとログ戦略

### 1. 構造化ログ

```ruby
def self.create(attributes)
  Rails.logger.info "Todo.create called with: #{attributes.inspect}"

  todo = new(attributes)
  Rails.logger.info "Todo instance created: #{todo.inspect}"
  Rails.logger.info "Todo valid?: #{todo.valid?}"

  if todo.valid?
    Rails.logger.info "Todo saved successfully"
  else
    Rails.logger.error "Todo validation failed: #{todo.errors.full_messages}"
  end
end
```

### 2. エラー追跡

```ruby
rescue => e
  Rails.logger.error "Error saving todo: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
  todo.errors.add(:base, "Failed to save: #{e.message}")
end
```

## 🧪 テスト戦略

### 1. モデルテストパターン

```ruby
# spec/models/todo_spec.rb
RSpec.describe Todo, type: :model do
  describe 'validations' do
    it 'requires title' do
      todo = Todo.new
      expect(todo).not_to be_valid
      expect(todo.errors[:title]).to include("can't be blank")
    end
  end

  describe 'persistence' do
    it 'saves to file system' do
      todo = Todo.create(title: 'Test')
      expect(todo.persisted?).to be true
      expect(Todo.find(todo.id)).to be_present
    end
  end
end
```

### 2. コントローラーテストパターン

```ruby
# spec/controllers/api/v1/todos_controller_spec.rb
RSpec.describe Api::V1::TodosController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new todo' do
        expect {
          post :create, params: { todo: { title: 'Test' } }
        }.to change(Todo, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
```

## 🔄 拡張可能性

### 1. データベース移行準備

```ruby
# app/models/todo.rb (ActiveRecord 移行準備)
class Todo < ApplicationRecord
  # ファイルベースからの移行時の互換性維持
  def to_hash
    attributes.symbolize_keys
  end
end
```

### 2. 認証システム統合

```ruby
class ApiController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    # JWT トークン検証ロジック
  end
end
```

### 3. キャッシュ戦略

```ruby
class Todo
  # Redis キャッシュ統合例
  def self.all
    Rails.cache.fetch("todos:all", expires_in: 5.minutes) do
      load_data.map { |data| new(data) }
    end
  end
end
```

## 📋 ベストプラクティス

### 1. コード品質

- Single Responsibility Principle の遵守
- DRY (Don't Repeat Yourself) の実践
- 明確な命名規則の統一

### 2. エラーハンドリング

- 例外の適切なキャッチと処理
- ユーザーフレンドリーなエラーメッセージ
- ログによる問題追跡の容易化

### 3. パフォーマンス

- ファイル I/O の最小化
- メモリ使用量の最適化
- 適切なキャッシュ戦略

### 4. セキュリティ

- Strong Parameters による入力検証
- CSRF 保護の適切な設定
- SQL インジェクション対策（将来的な DB 移行時）

このアーキテクチャは、小規模から中規模のアプリケーションに適した設計となっており、将来的なスケールアップや技術スタックの変更にも対応できる柔軟性を持っています。
