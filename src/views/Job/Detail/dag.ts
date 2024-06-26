import { uniq } from 'lodash-es'
import { DagreLayout } from '@antv/layout'

export default function parse(job: Job) {
  const { scripts } = job
  const scriptMap: Map<string, ScriptGroup> = new Map()
  for (const script of scripts) {
    const { name, dependencies } = script
    const mainId = name.split('.')[0]
    const mainDepdencies = uniq(dependencies?.map((dep: string) => dep.split('.')[0]) || []).filter(dep => dep !== mainId)
    if (!scriptMap.has(mainId)) {
      scriptMap.set(mainId, {
        id: mainId,
        dependencies: [],
        list: [],
      })
    }
    const group = scriptMap.get(mainId)!
    group.dependencies = uniq([...group.dependencies, ...mainDepdencies])
    group.list.push(script)
  }
  const nodes = Array.from(scriptMap.values()).map(group => group.id)
  const edges = Array.from(scriptMap.values()).map(group => group.dependencies.map(dep => [dep, group.id])).flat() as [string, string][]
  return { scriptMap, nodes, edges }
}

// https://x6.antv.antgroup.com/temp/layout
export async function layout2(nodes: string[], edges: [string, string][]) {
  const data = {
    nodes: nodes.map(node => ({ id: node, size: {
      width: Math.max(node.length * 15, 200),
      height: 100,
    } })),
    edges: edges.map(edge => ({ source: edge[0], target: edge[1] })),
  }
  const dagreLayout = new DagreLayout({
    type: 'dagre',
    rankdir: 'TB',
    nodesep: 20,
    ranksep: 20,
  })
  const layoutData = dagreLayout.layout(data)
  const { maxX, maxY } = (layoutData.nodes || []).reduce((acc, node: any) => {
    return {
      maxX: Math.max(acc.maxX, node.x + node.size.width),
      maxY: Math.max(acc.maxY, node.y + node.size.height),
    }
  }, { maxX: 0, maxY: 0 })
  return {
    canvas: { width: maxX, height: maxY },
    nodes: (layoutData.nodes || []).map((node: any) => {
      return {
        name: node.id,
        x: node.x - node.size.width / 2,
        y: node.y - node.size.height / 2,
        width: node.size.width,
        height: node.size.height,
      }
    }),
    edges,
  }
}
