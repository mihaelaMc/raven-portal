import { createContext, useContext, useEffect, useMemo, useState } from "react"
import client, { setOnAuthFailure } from "../api/client"
import { setTokens, clearTokens } from "./tokenStore"

const AuthContext = createContext(null)

function extractAccessToken(response) {
  return response.headers.authorization?.replace(/^Bearer\s+/i, "") ?? null
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [status, setStatus] = useState("anonymous") // "anonymous" | "authenticated"

  useEffect(() => {
    setOnAuthFailure(() => {
      setUser(null)
      setStatus("anonymous")
    })
  }, [])

  async function login(email, password) {
    const response = await client.post("/login", { user: { email, password } })

    setTokens({ accessToken: extractAccessToken(response), refreshToken: response.data.refresh_token })
    setUser(response.data.user)
    setStatus("authenticated")
  }

  async function register({ email, password, passwordConfirmation, crawlerName }) {
    const response = await client.post("/signup", {
      user: {
        email,
        password,
        password_confirmation: passwordConfirmation,
        crawler_name: crawlerName,
      },
    })

    setTokens({ accessToken: extractAccessToken(response), refreshToken: response.data.refresh_token })
    setUser(response.data.user)
    setStatus("authenticated")
  }

  async function logout() {
    try {
      await client.delete("/logout")
    } finally {
      clearTokens()
      setUser(null)
      setStatus("anonymous")
    }
  }

  const value = useMemo(() => ({ user, status, login, register, logout }), [user, status])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}
