import { describe, expect, it } from 'vitest'

import { sha256 } from '../src/utils/sha256'

describe('SHA-256', () => {
  it('matches the standard abc known vector', () => {
    expect(sha256(new TextEncoder().encode('abc').buffer)).toBe('ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')
  })
})
