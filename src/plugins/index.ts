import type { App } from 'vue'
import setupErrorHandler from './error'

export default {
  install: (app: App) => {
    setupErrorHandler(app)
  },
}
