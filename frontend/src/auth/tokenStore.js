// Access + refresh tokens live in memory only — never localStorage/sessionStorage.
// A hard page reload loses them (the user has to log in again); that's a deliberate
// tradeoff for a stored-token that would otherwise be readable by any injected script.
let accessToken = null
let refreshToken = null

export function getAccessToken() {
  return accessToken
}

export function getRefreshToken() {
  return refreshToken
}

export function setTokens({ accessToken: access, refreshToken: refresh }) {
  accessToken = access
  refreshToken = refresh
}

export function clearTokens() {
  accessToken = null
  refreshToken = null
}
