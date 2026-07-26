import { describe, it, expect } from "vitest"
import { render, screen } from "@testing-library/react"
import RoleBadge from "./RoleBadge"

describe("RoleBadge", () => {
  it("renders an admin badge in the torch accent", () => {
    render(<RoleBadge role="admin" />)

    const badge = screen.getByText("admin")
    expect(badge).toBeInTheDocument()
    expect(badge.className).toContain("text-torch")
  })

  it("renders a user badge in the arcane accent", () => {
    render(<RoleBadge role="user" />)

    const badge = screen.getByText("user")
    expect(badge).toBeInTheDocument()
    expect(badge.className).toContain("text-arcane")
  })
})
