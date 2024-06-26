export function mean(numbers: number[]): number {
  const sum = numbers.reduce((acc, val) => acc + val, 0)
  return sum / numbers.length
}

export function standardDeviation(numbers: number[], mean: number): number {
  const variance = numbers.reduce((acc, val) => acc + (val - mean) ** 2, 0) / numbers.length
  return Math.sqrt(variance)
}

export function gt95(list: number[]) {
  const m = mean(list)
  const sd = standardDeviation(list, m)
  const zScore = 1.96
  const value = m + zScore * sd
  return value
}

export function gt90(list: number[]) {
  const m = mean(list)
  const sd = standardDeviation(list, m)
  const zScore = 1.645
  const value = m + zScore * sd
  return value
}
