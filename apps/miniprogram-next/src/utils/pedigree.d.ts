/**
 * utils/pedigree.js 的类型声明。
 * 实现仍在 JS（C 端原生页 require 着），经营端 TS 页面通过本文件复用同一份排版逻辑，
 * 不再拄第二份。
 */

export type PedigreeRowNode = {
  role: string
  name: string
  sex: string
  public: boolean
  id: string
  tappable: boolean
}

export type PedigreeRow = {
  label: string
  nodes: PedigreeRowNode[]
}

export function buildPedigreeRows(data: unknown, fallbackRootId?: string): PedigreeRow[]
