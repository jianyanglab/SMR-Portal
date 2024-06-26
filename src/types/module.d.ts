declare module '*.vue' {
  import type { defineComponent } from 'vue'

  const component: ReturnType<typeof defineComponent>
  export default component
}

declare module 'virtua/vue' {
  import type { defineComponent } from 'vue'

  const component: ReturnType<typeof defineComponent>
  export const VList = component
}
