import type { App } from 'vue'
import { Modal } from 'ant-design-vue'
import { BizError, HttpError } from '@/types/error'
import { useUserStore, useViewNavStore } from '@/stores'

function errorHandler(error: HttpError | BizError) {
  if (error.status === 401) {
    useUserStore().signOut()
    useViewNavStore().login(true)
  }
  else if (error.status === 403) {
    const { title, content } = error.title ? { title: error.title, content: error.message } : { title: error.message, content: undefined }
    Modal.confirm({
      title,
      content,
      closable: false,
      maskClosable: false,
      centered: true,
      okText: 'Go to home page',
      wrapClassName: 'plugin-modal',
      autoFocusButton: null,
      onOk: () => {
        location.href = '/'
      },
    })
  }
  else {
    const { title, content } = error.title ? { title: error.title, content: error.message } : { title: error.message, content: undefined }
    Modal.error({
      title,
      content,
      closable: false,
      maskClosable: false,
      centered: true,
      okText: 'OK',
      autoFocusButton: null,
      wrapClassName: 'plugin-modal',
    })
  }
}

export default (app: App) => {
  app.config.errorHandler = (err: unknown) => {
    if ((err instanceof HttpError) || (err instanceof BizError))
      errorHandler(err)
    else
      console.error(err)
  }

  window.addEventListener('unhandledrejection', (event) => {
    const { reason } = event
    if ((reason instanceof HttpError) || (reason instanceof BizError))
      errorHandler(reason)
  })
}
