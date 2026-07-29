export type PhenotypeSeries = { code: string; name: string; phenotypes: string[] }

export function readPhenotypeSeries(response: any): PhenotypeSeries[] {
  const payload = response?.data || response || {}
  if (!Array.isArray(payload.series)) return []
  return payload.series
    .map((item: any) => ({
      code: String(item?.code || '').trim(),
      name: String(item?.name || item?.code || '').trim(),
      phenotypes: Array.isArray(item?.phenotypes) ? item.phenotypes.map((value: any) => String(value).trim()).filter(Boolean) : []
    }))
    .filter((item: PhenotypeSeries) => item.code)
}

export function encodePhenotype(series: string, label: string): string {
  const normalizedSeries = series.trim()
  const normalizedLabel = label.trim()
  return normalizedSeries && normalizedLabel ? `${normalizedSeries}|${normalizedLabel}` : normalizedLabel
}

export function decodePhenotype(value: string): { series: string; label: string } | null {
  const [series, label] = value.split('|', 2).map((part) => part.trim())
  if (!series || !label) return null
  return { series, label }
}
