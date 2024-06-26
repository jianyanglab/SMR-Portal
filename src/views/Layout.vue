<script setup lang="ts">
import { RouterView, useRoute } from 'vue-router'
import { computed } from 'vue'
import Nav from './Common/Nav.vue'

const route = useRoute()
const isHome = computed(() => route.name === 'Home')
</script>

<template>
  <Nav />
  <div class="min-h-screen" :class="isHome ? '' : 'pt-18'">
    <RouterView />
  </div>
</template>
