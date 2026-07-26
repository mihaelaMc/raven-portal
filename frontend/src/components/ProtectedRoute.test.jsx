import { describe, it, expect, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import { MemoryRouter, Routes, Route } from "react-router-dom"
import ProtectedRoute from "./ProtectedRoute"
import { useAuth } from "../auth/AuthContext"

vi.mock("../auth/AuthContext", () => ({ useAuth: vi.fn() }))

function renderAt(path) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <div>secret dashboard</div>
            </ProtectedRoute>
          }
        />
        <Route path="/login" element={<div>login page</div>} />
      </Routes>
    </MemoryRouter>
  )
}

describe("ProtectedRoute", () => {
  it("redirects anonymous visitors to /login", () => {
    useAuth.mockReturnValue({ status: "anonymous" })

    renderAt("/dashboard")

    expect(screen.getByText("login page")).toBeInTheDocument()
    expect(screen.queryByText("secret dashboard")).not.toBeInTheDocument()
  })

  it("renders children for authenticated users", () => {
    useAuth.mockReturnValue({ status: "authenticated" })

    renderAt("/dashboard")

    expect(screen.getByText("secret dashboard")).toBeInTheDocument()
  })
})
