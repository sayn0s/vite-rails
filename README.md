# 📝 TODO アプリ

Vue.js 2.5 + Vite + Ruby on Rails API で構築されたモダンな TODO アプリケーション（**統合構成：Rails サーバーのみでフロントエンドと API を配信**）

## 🚀 特徴

- **フロントエンド**: Vue.js 2.5 + Vite（高速開発環境）
- **バックエンド**: Ruby on Rails API mode
- **データ保存**: JSON ファイル（データベース不要）
- **Docker**: ワンクリックで起動可能
- **モダン UI**: レスポンシブ対応の美しいインターフェース

## 🛠️ 技術スタック

- **Ruby**: 3.0.7
- **Rails**: 7.0.x
- **Vue.js**: 2.7.16
- **Vite**: 4.x.x
- **Docker**: 環境構築

## 📦 機能

### ✨ TODO 管理機能

- ✅ TODO 作成（タイトル・説明・優先度）
- ✅ TODO 編集（インライン編集）
- ✅ TODO 削除
- ✅ 完了/未完了の切り替え
- ✅ 優先度設定（高・中・低）

### 📊 フィルタリング・統計

- 🔍 すべて/未完了/完了済みでフィルタリング
- 📈 進捗バーで完了率の可視化
- 📅 作成日時の表示

### 🎨 UI/UX

- 📱 レスポンシブデザイン
- 🌈 グラデーション背景
- ✨ ホバーエフェクト
- 🎯 直感的な操作

## 🏃‍♂️ クイックスタート

### 🐳 Docker 環境（統合構成）

```bash
# 1. リポジトリのクローン
git clone <repository-url>
cd vite-rails

# 2. Docker Composeで起動
docker-compose up --build

# 3. フロントエンド＆APIにアクセス
# http://localhost:3001
```

### 💻 ローカル環境（企業プロキシ環境推奨）

```bash
# 1. 依存関係のインストール
bundle install
yarn install

# 2. フロントエンドをビルド
cd frontend
yarn build
cd ..

# 3. ビルド成果物をpublic/にコピー
cp -r frontend/dist/* public/

# 4. Rails API サーバー起動
bundle exec rails server

# 5. ブラウザでアクセス
# http://localhost:4000
```

## 📁 プロジェクト構造

```
vite-rails/
├── 📋 docker-compose.yml         # Docker設定
├── 🐳 Dockerfile                 # Dockerイメージ設定
├── 💎 Gemfile                    # Ruby gems
├── 📦 package.json               # Node.js依存関係
├── ⚙️ vite.config.js            # Vite設定
├── 🏠 app/                       # Rails アプリケーション
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/v1/todos_controller.rb
│   └── models/
│       └── todo.rb               # JSONベースのTODOモデル
├── ⚙️ config/                    # Rails設定
│   ├── application.rb
│   ├── routes.rb
│   └── environments/
├── 🎨 frontend/                  # Vue.js アプリケーション
│   ├── main.js                   # エントリーポイント
│   ├── App.vue                   # メインコンポーネント
│   └── components/
│       ├── TodoList.vue          # TODO一覧
│       ├── TodoForm.vue          # TODO作成フォーム
│       └── TodoItem.vue          # TODOアイテム
│   └── dist/                     # Viteビルド成果物（本番用）
├── 🌐 public/
│   └── index.html                # フロントエンド配信（distからコピー）
└── 💾 data/
    └── todos.json                # TODO データ（自動生成）
```

※ `frontend/dist/` のビルド成果物は `public/` 配下にコピーされ、Rails サーバーで配信されます。

## 🔗 API エンドポイント

| Method | Endpoint            | 説明          |
| ------ | ------------------- | ------------- |
| GET    | `/api/v1/todos`     | TODO 一覧取得 |
| POST   | `/api/v1/todos`     | TODO 作成     |
| GET    | `/api/v1/todos/:id` | TODO 詳細取得 |
| PUT    | `/api/v1/todos/:id` | TODO 更新     |
| DELETE | `/api/v1/todos/:id` | TODO 削除     |

## 🎯 TODO データ形式

```json
{
  "id": 1,
  "title": "サンプルTODO",
  "description": "TODO の詳細説明",
  "completed": false,
  "priority": "medium",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

## 🌟 今後の拡張予定

- [ ] ユーザー認証
- [ ] カテゴリ機能
- [ ] 期限設定
- [ ] 通知機能
- [ ] ダークモード

## 🤝 コントリビューション

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

---

**楽しい TODO 管理を！** 🎉
