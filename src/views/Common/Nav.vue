<script setup lang="ts">
import { Avatar, Button, ConfigProvider, Menu, Popover } from 'ant-design-vue'
import { storeToRefs } from 'pinia'
import { computed, defineAsyncComponent } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useWindowScroll } from '@vueuse/core'
import { useAuthStore, useUserStore, useViewNavStore } from '@/stores'

const Login = defineAsyncComponent(() => import('./Login.vue'))
const User = defineAsyncComponent(() => import('./User.vue'))

interface MenuItem {
  key: string
  label: string
  path: string
  recommended?: boolean
  children?: MenuItem[]
}

const menu: MenuItem[] = [
  {
    key: 'Job',
    path: '/task',
    label: 'Analysis ',
  },
  {
    key: 'Database',
    path: '/database',
    label: 'Database',
  },
  {
    key: 'Tutorial',
    path: '/doc/tutorial',
    label: 'Tutorial',
  },
  {
    key: 'About',
    path: '/doc/about',
    label: 'About',
  },
  {
    key: 'Yanglab',
    path: 'https://yanglab.westlake.edu.cn/',
    label: 'YangLab',
  },
]

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const { token } = storeToRefs(authStore)
const userStore = useUserStore()
const { user, firstLetter, lastEmail } = storeToRefs(userStore)
const hasAccount = computed(() => !!lastEmail.value)
const viewNavStore = useViewNavStore()
const { login } = viewNavStore
const { showLogin } = storeToRefs(viewNavStore)

function openWindow(url: string) {
  window.open(url)
}

const isHome = computed(() => route.name === 'Home')
const { y } = useWindowScroll()
const onTop = computed(() => y.value < 10)
const reserved = computed(() => isHome.value && onTop.value)
</script>

<template>
  <div
    class="nav fixed top-0 w-full min-w-[1024px] flex justify-between h-18 px-8 z-50 transition-colors duration-300"
    :class="reserved ? 'bg-transparent' : 'bg-white/[.9] backdrop-blur-sm shadow'"
  >
    <div class="flex gap-4 items-center">
      <RouterLink to="/">
        <h1
          class="font-lexend font-bold tracking-tight text-4xl/loose "
          :class="reserved ? 'text-white' : 'text-gamma-secondary'"
        >
          SMR Portal
        </h1>
      </RouterLink>
    </div>
    <ConfigProvider
      :theme="{
        components: {
          Menu: {
            ...(reserved ? {
              colorItemText: 'rgba(255,255,255,.8)',
              colorItemTextHover: 'white',
              colorItemTextSelectedHorizontal: 'white',
            } : {}),
            colorSplit: 'transparent',
            colorItemBg: 'transparent',
            colorActiveBarHeight: 4,
            fontSize: 18,
          },
        },
      }"
    >
      <Menu
        mode="horizontal"
        :items="menu"
        :selected-keys="[route.matched[1]?.name as string]"
        @click="async ({ item }) => {
          const { path } = item as MenuItem
          if (route.path !== path){
            if (path.startsWith('http')){
              openWindow(path)
            }
            else {
              await router.push(path)
            }
          }
        }"
      />
    </ConfigProvider>
    <div class="user flex gap-4 items-center">
      <template v-if="token">
        <div v-if="user">
          <Popover
            trigger="click"
            overlay-class-name="no-arrow"
            placement="bottom"
            :get-popup-container="(node) => {
              return node.parentElement as HTMLElement
            }"
          >
            <template #content>
              <div class="w-[228px]">
                <User />
              </div>
            </template>
            <Avatar class="cursor-pointer">
              {{ firstLetter }}
            </Avatar>
          </Popover>
        </div>
      </template>
      <template v-else>
        <div
          :class="hasAccount ? 'order-last' : ''"
        >
          <ConfigProvider
            :theme="reserved ? {
              components: {
                Button: {
                  colorLink: 'rgba(255, 255, 255, 0.8)',
                  colorLinkHover: 'white',
                },
              },
            } : undefined"
          >
            <Button
              :type="hasAccount ? 'primary' : 'link'"
              @click="login()"
            >
              Log In
            </Button>
          </ConfigProvider>
        </div>
        <div>
          <RouterLink to="/signup">
            <ConfigProvider
              :theme="reserved ? {
                components: {
                  Button: {
                    colorLink: 'rgba(255, 255, 255, 0.8)',
                    colorLinkHover: 'white',
                  },
                },
              } : undefined"
            >
              <Button
                :type="hasAccount ? 'link' : 'primary'"
              >
                Sign Up
              </Button>
            </ConfigProvider>
          </RouterLink>
        </div>
      </template>
    </div>
  </div>
  <div>
    <Login v-if="showLogin" />
  </div>
</template>

<style>
.nav .ant-menu-horizontal > li {
  min-width: 110px;
  text-align: center;
}
</style>
