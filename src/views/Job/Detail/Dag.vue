<script setup lang="ts">
import { Graph } from '@antv/x6'
import { getTeleport, register } from '@antv/x6-vue-shape'
import { onMounted, ref } from 'vue'
import Node from './Node.vue'

const props = defineProps<{
  data: {
    canvas: {
      width: number
      height: number
    }
    nodes: {
      name: string
      x: number
      y: number
      width: number
      height: number
    }[]
    edges: [string, string][]
  }
}>()

const dagContainer = ref<HTMLDivElement | null>(null)

register({
  shape: 'vueNode',
  component: Node,
})

const TeleportContainer = getTeleport()

onMounted(() => {
  const { canvas, nodes, edges } = props.data
  if (nodes.length === 0 || edges.length === 0 || !dagContainer.value)
    return

  const graph = new Graph({
    container: dagContainer.value,
    width: canvas.width + 1,
    height: canvas.height + 1,
    interacting: false,
  })
  for (const node of nodes) {
    graph.addNode({
      id: node.name,
      x: node.x,
      y: node.y,
      width: node.width,
      height: node.height,
      label: node.name,
      shape: 'vueNode',
      data: {
        name: node.name,
      },
    })
  }
  for (const edge of edges) {
    graph.addEdge({
      source: edge[0],
      target: edge[1],
      shape: 'edge',
    })
  }
})
</script>

<template>
  <div ref="dagContainer" />
  <TeleportContainer />
</template>
