import path from 'node:path'
import process from 'node:process'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  base: './',
  resolve: {
    alias: {
      '@': path.resolve(process.cwd(), 'src'),
    },
  },
  plugins: [
    vue(),
  ],
  optimizeDeps: {
    exclude: [
      '@futuregene/gamma-web-plot',
    ],
    include: [
      '@futuregene/gamma-web-plot > konva',
      '@futuregene/gamma-web-plot > @jcoreio/async-throttle',
    ],
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vue: [
            'vue',
            'vue-router',
            'pinia',
            'vite/modulepreload-polyfill',
            '\0commonjsHelpers.js',
            '\0plugin-vue:export-helper',
          ],
          api: [
            'src/config/index.ts',
            'src/stores/index.ts',
            'src/apis/index.ts',
          ],
          d3: [
            'd3',
          ],
          x6: [
            '@antv/x6',
            '@antv/x6-vue-shape',
          ],
          layout: [
            '@antv/layout',
          ],
          ag: [
            '@ag-grid-community/core',
            '@ag-grid-community/styles',
            '@ag-grid-community/client-side-row-model',
            '@ag-grid-community/vue3',
          ],
        },
      },
    },
  },
  server: {
    fs: {
      // 允许为项目根目录的上一级提供服务
      allow: ['..'],
    },
    proxy: {
      '/api/': {
        target: 'http://localhost:3000',
      },
    },
  },
})
