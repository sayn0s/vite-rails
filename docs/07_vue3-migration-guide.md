# Vue 3 移行ガイド

このドキュメントでは、現在のVite + Rails統合環境でVue 2.7.16からVue 3への移行手順を説明します。

## 現在の構成

- Vue.js 2.7.16（Composition API対応版）
- Vite 5.0.0 + @vitejs/plugin-vue2
- Rails 7.0統合環境

## 移行戦略

### フェーズ1: @vue/compat導入

`@vue/compat`（移行ビルド）を使用して段階的に移行を行います。これにより、Vue 2のコードがVue 3環境で動作し、非推奨機能に対する警告を確認できます。

#### 1. パッケージの更新

```bash
# Vue 3と@vue/compatのインストール
yarn add vue@^3.4.0 @vue/compat@^3.4.0

# Viteプラグインの更新
yarn remove @vitejs/plugin-vue2
yarn add @vitejs/plugin-vue@^5.0.0
```

#### 2. Vite設定の更新

`vite.config.mjs`を更新（Rails統合環境では`vite-plugin-ruby`を使用）：

```javascript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue({
      template: {
        compilerOptions: {
          compatConfig: {
            MODE: 2 // Vue 2 互換モード
          }
        }
      }
    })
  ],
  resolve: {
    alias: {
      vue: '@vue/compat' // Vue 3の代わりに@vue/compatを使用
    }
  }
})
```

#### 3. メインエントリポイントの設定

`app/frontend/entrypoints/application.js`にglobal互換設定を追加：

```javascript
import { createApp, configureCompat } from 'vue'
import App from '../App.vue'

// グローバル互換設定
configureCompat({
  MODE: 2, // Vue 2 互換モード
  GLOBAL_MOUNT: false,
  GLOBAL_EXTEND: false,
  GLOBAL_PROTOTYPE: false,
  GLOBAL_SET: false,
  GLOBAL_DELETE: false,
  GLOBAL_OBSERVABLE: false,
  CONFIG_SILENT: false,
  CONFIG_DEVTOOLS: false,
  CONFIG_KEY_CODES: false,
  CONFIG_PRODUCTION_TIP: false,
  CONFIG_IGNORED_ELEMENTS: false,
  CONFIG_WHITESPACE: false,
  CONFIG_OPTION_MERGE_STRATS: false,
  INSTANCE_SET: false,
  INSTANCE_DELETE: false,
  INSTANCE_DESTROY: false,
  INSTANCE_EVENT_EMITTER: false,
  INSTANCE_EVENT_HOOKS: false,
  INSTANCE_CHILDREN: false,
  INSTANCE_LISTENERS: false,
  INSTANCE_SCOPED_SLOTS: false,
  PROPS_DEFAULT_THIS: false,
  INSTANCE_ATTRS_CLASS_STYLE: false,
  OPTIONS_DATA_FN: false,
  OPTIONS_DATA_MERGE: false,
  OPTIONS_BEFORE_DESTROY: false,
  OPTIONS_DESTROYED: false,
  WATCH_ARRAY: false,
  V_ON_KEYCODE_MODIFIER: false,
  CUSTOM_DIR: false,
  ATTR_FALSE_VALUE: false,
  ATTR_ENUMERATED_COERCION: false,
  TRANSITION_CLASSES: false,
  COMPONENT_ASYNC: false,
  COMPONENT_FUNCTIONAL: false,
  COMPONENT_V_MODEL: false,
  RENDER_FUNCTION: false,
  FILTERS: false,
  PRIVATE_APIS: false
})

const app = createApp(App)
app.mount('#vue-app')
```

#### 4. App.vueの確認

現在のApp.vueは既に`<script setup>`で書かれているため、基本的にVue 3対応済みです。

### フェーズ2: 警告の修正

#### 1. 開発サーバーでの確認

```bash
bin/rails server
```

ブラウザのコンソールで非推奨機能の警告を確認し、一つずつ修正します。

#### 2. よくある警告と対応

- **GLOBAL_MOUNT**: `new Vue()`の代わりに`createApp()`を使用
- **INSTANCE_EVENT_EMITTER**: `$on`, `$off`, `$once`の代わりにmittやカスタムイベントを使用
- **FILTERS**: フィルターの代わりに計算プロパティやメソッドを使用
- **COMPONENT_V_MODEL**: `v-model`の実装方法が変更

### フェーズ3: 依存関係の更新

Vue 3対応のライブラリに更新：

```bash
# 必要に応じて他のVue関連パッケージも更新
# 例: Vue Router, Vuex/Pinia等
```

### フェーズ4: 標準Vue 3への移行

すべての警告を修正後、標準のVue 3に移行：

#### 1. パッケージの更新

```bash
yarn remove @vue/compat
```

#### 2. Vite設定の更新

`vite.config.mjs`から互換設定を削除：

```javascript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [RubyPlugin(), vue()]
})
```

#### 3. メインエントリポイントの清理

`app/frontend/entrypoints/application.js`から互換設定を削除：

```javascript
import { createApp } from 'vue'
import App from '../App.vue'

const app = createApp(App)
app.mount('#vue-app')
```

## 注意事項

### パフォーマンス
- 移行ビルドは標準Vue 3より少し重い
- 本番環境では標準Vue 3を使用することを推奨

### 依存関係
- Vite関連のプラグインもVue 3対応版に要更新
- サードパーティライブラリのVue 3対応状況を確認

### テスト
- 各フェーズでアプリケーションの動作を十分にテスト
- 特にイベント処理、リアクティビティ、ライフサイクルの動作を確認

## チェックリスト

- [ ] @vue/compatの導入
- [ ] Vite設定の更新
- [ ] 開発サーバーでの動作確認
- [ ] 警告の確認・修正
- [ ] 依存関係の更新
- [ ] 標準Vue 3への移行
- [ ] 本番ビルドの確認

## 参考資料

- [Vue 3 Migration Build](https://v3-migration.vuejs.org/ja/migration-build.html)
- [Vue 3 Migration Guide](https://v3-migration.vuejs.org/ja/)
- [Composition API RFC](https://composition-api.vuejs.org/)