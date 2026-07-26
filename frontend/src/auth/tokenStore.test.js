import { describe, it, expect, beforeEach } from "vitest"
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from "./tokenStore"

describe("tokenStore", () => {
  beforeEach(() => clearTokens())

  it("starts empty", () => {
    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
  })

  it("round-trips both tokens", () => {
    setTokens({ accessToken: "access-123", refreshToken: "refresh-456" })

    expect(getAccessToken()).toBe("access-123")
    expect(getRefreshToken()).toBe("refresh-456")
  })

  it("clears both tokens", () => {
    setTokens({ accessToken: "access-123", refreshToken: "refresh-456" })
    clearTokens()

    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
  })
})
