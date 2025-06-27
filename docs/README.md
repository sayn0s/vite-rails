# 📚 Vite Rails + Vue.js 統合プロジェクト ドキュメント

## 🎯 プロジェクト概要

このプロジェクトは、Rails 7.0 + Vue.js 2.7 + vite_rails を統合した TODO アプリケーションです。Docker 環境で開発され、多くの技術的課題を解決した実装となっています。

## 📖 ドキュメント一覧

### 1. [📚 Vite Rails 導入ガイド](01_vite_rails_setup_guide.md)

vite_rails の導入手順とベストプラクティスを詳しく解説。Docker 環境での設定から基本的な統合まで、ステップバイステップで説明しています。

**主な内容:**

- 環境構築手順
- Dockerfile の最適化
- ApplicationController の適切な設定
- ディレクトリ構造の理解

### 2. [🚨 トラブルシューティングガイド](02_troubleshooting_guide.md)

実際に遭遇したエラーと解決策を体系的にまとめたガイド。開発中に発生しやすい問題の対処法を網羅しています。

**主な内容:**

- インストール関連エラー（`bundler: command not found: vite`等）
- HTML ビューレンダリング問題
- Vue.js 処理エラー
- 文字エンコーディング問題
- API 通信エラー

### 3. [⚙️ 設定ファイル解説ガイド](03_configuration_guide.md)

各設定ファイルの詳細な説明と最適化のポイント。本番環境への展開を見据えた設定方法も解説しています。

**主な内容:**

- `config/vite.json`の詳細解説
- `vite.config.mjs`の Vue.js 統合設定
- Docker 環境最適化
- デバッグ設定

### 4. [🏗️ API 仕様とアーキテクチャガイド](04_api_and_architecture.md)

システム全体のアーキテクチャと API 仕様の詳細説明。データフローと拡張可能性についても解説しています。

**主な内容:**

- 完全な API 仕様
- システムアーキテクチャ図
- データフロー解説
- セキュリティ考慮事項
- パフォーマンス最適化

### 5. [🏛️ Ruby アーキテクチャ構成ガイド](05_ruby_architecture_guide.md)

Ruby/Rails 固有のアーキテクチャ設計と実装パターンの詳細解説。ActiveModel::Model を使用したファイルベース永続化の実装について説明しています。

**主な内容:**

- Rails アプリケーション構成
- ActiveModel::Model ベースの設計パターン
- ファイルベース永続化の実装
- コントローラー階層の設計
- Ruby 固有の設計パターン
- パフォーマンス最適化とテスト戦略

## 🚀 プロジェクトの特徴

### ✨ 技術スタック

- **Frontend**: Vue.js 2.7 + Vite
- **Backend**: Rails 7.0 + ActionController::Base
- **Integration**: vite_rails gem
- **Environment**: Docker
- **Data Storage**: JSON file-based

### 🎯 解決した主要な技術課題

1. **vite_rails インストール問題**

   - Gemfile.lock の依存関係エラー解決
   - Docker 環境でのクリーンインストール手法確立

2. **フレームワーク統合**

   - `ActionController::API`から`ActionController::Base`への適切な移行
   - Vue.js 2.7 と Vite の統合設定

3. **文字エンコーディング**

   - 日本語対応での文字化け問題解決
   - ERB テンプレートの適切な設定

4. **API 設計**
   - ActiveModel::Model での永続化ロジック実装
   - 422 エラー問題の解決（`todo.persisted?`の代替実装）

## 🔧 クイックスタート

```bash
# 1. リポジトリクローン
git clone <repository-url>
cd vite-rails

# 2. Docker環境起動
docker compose up --build

# 3. アプリケーションアクセス
open http://localhost:4000
```

詳細な手順は[導入ガイド](01_vite_rails_setup_guide.md)を参照してください。

## 📋 開発時のベストプラクティス

### 🔍 トラブルシューティング手順

1. **エラー発生時**

   - [トラブルシューティングガイド](02_troubleshooting_guide.md)で類似エラーを検索
   - ログファイルの確認（`docker compose logs app`）
   - 設定ファイルの検証

2. **設定変更時**

   - [設定ファイル解説](03_configuration_guide.md)で推奨設定を確認
   - 開発環境と本番環境の設定差分を考慮
   - チェックリストで必須項目を確認

3. **API 拡張時**

   - [API 仕様ガイド](04_api_and_architecture.md)の規約に従う
   - セキュリティ考慮事項の確認
   - パフォーマンス影響の検討

4. **Ruby コード拡張時**
   - [Ruby アーキテクチャガイド](05_ruby_architecture_guide.md)の設計パターンに従う
   - ActiveModel::Model の制約を考慮
   - ファイルベース永続化の特性を理解

## 🎉 成果と学び

### 🏆 達成したこと

- **安定した vite_rails 統合**: Vue.js 2.7 との完全統合
- **包括的なエラー対策**: 実際のエラー事例とその解決策の文書化
- **本番対応設定**: スケーラブルな設定体系の確立
- **開発効率向上**: ホットリロード対応の開発環境
- **Ruby 設計パターンの確立**: ActiveModel::Model による柔軟なデータ永続化

### 📚 得られた知見

1. **vite_rails は強力だが、設定の理解が重要**
2. **ActionController 継承の選択が統合の成否を左右**
3. **Docker 環境では依存関係管理により注意が必要**
4. **エラーメッセージの詳細な記録が後の開発効率を大きく向上**
5. **ActiveModel::Model による柔軟なデータ層設計の可能性**

## 🔗 関連リンク

- [vite_rails 公式ドキュメント](https://vite-ruby.netlify.app/)
- [Vue.js 2.7 ドキュメント](https://v2.vuejs.org/)
- [Rails 7.0 ガイド](https://guides.rubyonrails.org/)

## 🤝 コントリビューション

この知見が他の開発者の役に立つことを願っています。同様の課題に直面した際は、これらのドキュメントを参考に、より効率的な開発を進めてください。

---

**Happy Coding! 🎉**
