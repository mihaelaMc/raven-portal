import axios from "axios"
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from "../auth/tokenStore"

const baseURL = import.meta.env.VITE_API_BASE_URL || "http://localhost:3000/api/v1"

const client = axios.create({ baseURL })

// The API returns asset paths (e.g. avatar_url) relative to its own origin.
// A bare relative src in an <img> would resolve against the frontend's origin
// (the Vite dev server) instead, so anchor it to the API's origin explicitly.
export function apiAssetUrl(path) {
  if (!path) return null
  return new URL(path, new URL(baseURL).origin).href
}

// Tokens are stored raw (no "Bearer " prefix) in tokenStore; the login/signup Authorization
// response header comes with the prefix and gets stripped before storage in AuthContext, and
// the refresh endpoint's access_token is already raw — so this is the one place it gets added.
client.interceptors.request.use((config) => {
  const token = getAccessToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

let onAuthFailure = null

export function setOnAuthFailure(callback) {
  onAuthFailure = callback
}

client.interceptors.response.use(
  (response) => response,
  async (error) => {
    const { config, response } = error

    if (!response || response.status !== 401 || config._retried || config.url === "/refresh") {
      return Promise.reject(error)
    }

    const refreshToken = getRefreshToken()
    if (!refreshToken) {
      clearTokens()
      onAuthFailure?.()
      return Promise.reject(error)
    }

    try {
      const refreshResponse = await client.post("/refresh", { refresh_token: refreshToken })
      setTokens({
        accessToken: refreshResponse.data.access_token,
        refreshToken: refreshResponse.data.refresh_token,
      })

      config._retried = true
      config.headers.Authorization = `Bearer ${refreshResponse.data.access_token}`
      return client(config)
    } catch (refreshError) {
      clearTokens()
      onAuthFailure?.()
      return Promise.reject(refreshError)
    }
  }
)

export default client
