import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ContextMenu from '@imengyu/vue3-context-menu'
import App from './App.vue'
import { setupRouter } from './router'
import plugins from '@/plugins'

import '@imengyu/vue3-context-menu/lib/vue3-context-menu.css'

(async function () {
  const app = createApp(App)
  const pinia = createPinia()
  app.use(plugins)
  app.use(pinia)
  app.use(ContextMenu)
  await setupRouter(app)
  app.mount('#app')
})()
