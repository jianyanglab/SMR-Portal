import * as d3 from 'd3'

export function ramp(color: d3.ScaleSequential<string, never>, n = 256) {
  const domain = color.domain()
  const length = domain.length
  const _color = color.copy().domain(d3.quantize(d3.interpolate(0, 1), length)) as d3.ScaleSequential<string, never>
  const canvas = document.createElement('canvas')
  canvas.width = 256
  canvas.height = 1
  const context = canvas.getContext('2d')
  if (!context)
    return canvas.toDataURL()
  for (let i = 0; i < n; ++i) {
    context.fillStyle = _color(i / (n - 1))
    context.fillRect(i, 0, 1, 1)
  }
  return canvas.toDataURL()
}
