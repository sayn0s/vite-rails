import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue";

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
});