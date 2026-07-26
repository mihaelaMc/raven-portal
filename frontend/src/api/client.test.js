import { describe, it, expect, beforeEach, vi } from "vitest"
import client, { apiAssetUrl, setOnAuthFailure } from "./client"
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from "../auth/tokenStore"

function ok(config, data) {
  return { data, status: 200, statusText: "OK", headers: {}, config }
}

function unauthorized(config) {
  return Promise.reject({ config, response: { status: 401 } })
}

describe("apiAssetUrl", () => {
  it("returns null for null/undefined paths", () => {
    expect(apiAssetUrl(null)).toBeNull()
    expect(apiAssetUrl(undefined)).toBeNull()
  })

  it("anchors relative paths to the API origin, not the frontend origin", () => {
    expect(apiAssetUrl("/rails/active_storage/blobs/abc/avatar.png")).toBe(
      "http://localhost:3000/rails/active_storage/blobs/abc/avatar.png"
    )
  })
})

describe("401 refresh-and-retry interceptor", () => {
  let calls

  beforeEach(() => {
    calls = []
    clearTokens()
    setOnAuthFailure(null)
  })

  it("refreshes once on a 401 and retries the original request with the new token", async () => {
    setTokens({ accessToken: "stale", refreshToken: "refresh-1" })

    client.defaults.adapter = async (config) => {
      calls.push(config.url)
      if (config.url === "/refresh") {
        expect(config.data).toContain("refresh-1")
        return ok(config, { access_token: "fresh", refresh_token: "refresh-2", user: { id: 1 } })
      }
      if (config._retried) {
        expect(config.headers.get("Authorization")).toBe("Bearer fresh")
        return ok(config, { secret: "loot" })
      }
      return unauthorized(config)
    }

    const response = await client.get("/protected")

    expect(response.data).toEqual({ secret: "loot" })
    expect(calls).toEqual(["/protected", "/refresh", "/protected"])
    expect(getAccessToken()).toBe("fresh")
    expect(getRefreshToken()).toBe("refresh-2")
  })

  it("clears tokens and reports auth failure when the refresh itself fails", async () => {
    setTokens({ accessToken: "stale", refreshToken: "dead-refresh" })
    const onFailure = vi.fn()
    setOnAuthFailure(onFailure)

    client.defaults.adapter = async (config) => {
      calls.push(config.url)
      return unauthorized(config)
    }

    await expect(client.get("/protected")).rejects.toBeTruthy()

    expect(calls).toEqual(["/protected", "/refresh"])
    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
    expect(onFailure).toHaveBeenCalledTimes(1)
  })

  it("gives up immediately on 401 when no refresh token is held", async () => {
    setTokens({ accessToken: "stale", refreshToken: null })
    const onFailure = vi.fn()
    setOnAuthFailure(onFailure)

    client.defaults.adapter = async (config) => {
      calls.push(config.url)
      return unauthorized(config)
    }

    await expect(client.get("/protected")).rejects.toBeTruthy()

    expect(calls).toEqual(["/protected"])
    expect(onFailure).toHaveBeenCalledTimes(1)
  })
})
