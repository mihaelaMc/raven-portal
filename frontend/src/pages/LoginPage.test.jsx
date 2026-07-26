import { describe, it, expect, beforeEach, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { MemoryRouter, Routes, Route } from "react-router-dom"
import LoginPage from "./LoginPage"
import { AuthProvider } from "../auth/AuthContext"
import client from "../api/client"

vi.mock("../api/client", () => ({
  default: { post: vi.fn(), get: vi.fn(), delete: vi.fn() },
  setOnAuthFailure: vi.fn(),
  apiAssetUrl: vi.fn((path) => path),
}))

function renderLogin() {
  return render(
    <AuthProvider>
      <MemoryRouter initialEntries={["/login"]}>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/dashboard" element={<div>dashboard landing</div>} />
        </Routes>
      </MemoryRouter>
    </AuthProvider>
  )
}

async function submitCredentials(email, password) {
  await userEvent.type(screen.getByLabelText(/email/i), email)
  await userEvent.type(screen.getByLabelText(/password/i), password)
  await userEvent.click(screen.getByRole("button", { name: /sign in/i }))
}

describe("LoginPage", () => {
  beforeEach(() => vi.clearAllMocks())

  it("logs in and navigates to the dashboard", async () => {
    client.post.mockResolvedValue({
      headers: { authorization: "Bearer jwt-token" },
      data: { user: { crawler_name: "Grix", role: "user" }, refresh_token: "refresh-1" },
    })

    renderLogin()
    await submitCredentials("grix@example.com", "password123")

    expect(await screen.findByText("dashboard landing")).toBeInTheDocument()
    expect(client.post).toHaveBeenCalledWith("/login", {
      user: { email: "grix@example.com", password: "password123" },
    })
  })

  it("surfaces the API's error message on failure", async () => {
    client.post.mockRejectedValue({ response: { data: { error: "Invalid Email or password." } } })

    renderLogin()
    await submitCredentials("grix@example.com", "wrong")

    expect(await screen.findByText("Invalid Email or password.")).toBeInTheDocument()
    expect(screen.queryByText("dashboard landing")).not.toBeInTheDocument()
  })
})
