import type { App } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore, useViewNavStore } from '@/stores'
import { base } from '@/config'

export const router = createRouter({
  history: createWebHistory(base),
  routes: [
    {
      path: '/',
      name: 'Root',
      component: () => import('@/views/Layout.vue'),
      children: [
        {
          path: '/',
          name: 'Home',
          component: () => import('@/views/Home/Home.vue'),
        },
        {
          path: '/signup',
          name: 'Signup',
          component: () => import('@/views/User/SignUp.vue'),
          meta: {
            title: 'Sign Up',
          },
        },
        {
          path: '/reset',
          name: 'SendResetEmail',
          component: () => import('@/views/User/SendResetEmail.vue'),
          meta: {
            title: 'Reset Password',
          },
        },
        {
          path: '/reset/:token',
          name: 'ResetPassword',
          component: () => import('@/views/User/ResetPassword.vue'),
          props: true,
          meta: {
            title: 'Reset Password',
          },
        },
        {
          path: '/change',
          name: 'ChangePassword',
          component: () => import('@/views/User/Change.vue'),
          meta: {
            title: 'Change Password',
            auth: true,
          },
        },
        {
          path: '/activate/:token',
          name: 'Activate',
          component: () => import('@/views/User/Activate.vue'),
          props: true,
          meta: {
            title: 'Activate User',
          },
        },
        {
          path: '/task',
          name: 'Job',
          component: () => import('@/views/Job/Layout.vue'),
          children: [
            {
              path: '/task',
              name: 'JobList',
              components: {
                default: () => import('@/views/Job/List.vue'),
              },
              meta: {
                title: 'Task List',
                auth: true,
              },
            },
            {
              path: '/task/create',
              name: 'JobCreate',
              components: {
                default: () => import('@/views/Job/Create/index.vue'),
              },
              meta: {
                title: 'Create Task',
                auth: true,
              },
            },
            {
              path: '/task/:id(\\d+)',
              name: 'JobDetail',
              props: true,
              components: {
                default: () => import('@/views/Job/Detail/index.vue'),
              },
              meta: {
                title: 'Task Log',
                auth: true,
              },
            },
          ],
        },
        {
          path: '/file',
          name: 'File',
          component: () => import('@/views/File/Layout.vue'),
          children: [
            {
              path: '/file',
              name: 'FileList',
              components: {
                default: () => import('@/views/File/List.vue'),
                // side: () => import('@/views/Common/Side.vue'),
              },
              meta: {
                title: 'File List',
              },
            },
          ],
        },
        {
          path: '/database',
          name: 'Database',
          children: [
            {
              path: '/database',
              name: 'DatabaseSearch',
              component: () => import('@/views/Database/index.vue'),
              meta: {
                title: 'Database',
              },
            },
            {
              path: '/database/trait/:traitName([A-z0-9_]+)',
              name: 'DatabaseTrait',
              props: true,
              component: () => import('@/views/Database/Trait.vue'),
              meta: {
                title: 'Database',
              },
            },
            {
              path: '/database/gene/:gene([A-z0-9_]+)',
              name: 'DatabaseGene',
              props: true,
              component: () => import('@/views/Database/Gene.vue'),
              meta: {
                title: 'Database',
              },
            },
          ],

        },
        {
          path: '/doc/tutorial',
          name: 'Tutorial',
          component: () => import('@/views/Document/Tutorial/index.vue'),
          meta: {
            title: 'Tutorial',
          },
        },
        {
          path: 'doc/about',
          name: 'About',
          component: () => import('@/views/Document/About/index.vue'),
          meta: {
            title: 'About',
          },
        },
        {
          path: 'doc/privacy',
          name: 'Privacy',
          component: () => import('@/views/Document/Privacy/index.vue'),
          meta: {
            title: 'Privacy Policy',
          },
        },
        {
          path: 'doc/terms',
          name: 'Terms',
          component: () => import('@/views/Document/Terms/index.vue'),
          meta: {
            title: 'Terms of Service',
          },
        },
      ],
    },
    {
      path: '/task/:id(\\d+)/report',
      name: 'Report',
      children: [{
        name: 'ReportPrivate',
        path: '/task/:id(\\d+)/report',
        props: true,
        component: () => import('@/views/Laboratory/index.vue'),
        meta: {
          title: 'Task Report',
          auth: true,
        },
      }, {
        path: '/task/:id(\\d+)/report/:isShared(shared)',
        name: 'ReportShared',
        props: true,
        component: () => import('@/views/Laboratory/index.vue'),
        meta: {
          title: 'Task Report',
        },
      }],
    },
    {
      path: '/database/report/:traitName([A-z0-9_]+)',
      name: 'DatabaseReport',
      props: true,
      component: () => import('@/views/Laboratory/index.vue'),
      meta: {
        title: 'Database Report',
      },
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      redirect: {
        name: 'Home',
      },
    },
  ],
  scrollBehavior(to) {
    if (to.hash) {
      return {
        el: to.hash,
        behavior: 'smooth',
      }
    }
    else {
      return {
        top: 0,
      }
    }
  },
})

router.beforeEach(async (to, from, next) => {
  if (to.meta.title)
    document.title = `${to.meta.title as string} - ` + 'SMR'
  else
    document.title = 'SMR'

  const userStore = useUserStore()
  if (!userStore.user && userStore.token) {
    try {
      await userStore.getProfile()
    }
    catch (e) {
      console.error(e)
    }
  }
  if (to.meta.auth && !userStore.user)
    useViewNavStore().login(true)

  next()
})

export async function setupRouter(app: App) {
  app.use(router)
  await router.isReady()
}
