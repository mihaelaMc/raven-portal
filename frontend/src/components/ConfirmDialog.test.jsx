import { describe, it, expect, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import ConfirmDialog from "./ConfirmDialog"

const baseProps = {
  title: "Delete crawler",
  message: "Remove Grix permanently?",
  confirmLabel: "Delete",
}

describe("ConfirmDialog", () => {
  it("renders nothing when closed", () => {
    const { container } = render(<ConfirmDialog {...baseProps} open={false} />)

    expect(container).toBeEmptyDOMElement()
  })

  it("shows title and message when open", () => {
    render(<ConfirmDialog {...baseProps} open />)

    expect(screen.getByText("Delete crawler")).toBeInTheDocument()
    expect(screen.getByText("Remove Grix permanently?")).toBeInTheDocument()
  })

  it("fires the confirm and cancel callbacks", async () => {
    const onConfirm = vi.fn()
    const onCancel = vi.fn()
    render(<ConfirmDialog {...baseProps} open onConfirm={onConfirm} onCancel={onCancel} />)

    await userEvent.click(screen.getByRole("button", { name: "Delete" }))
    await userEvent.click(screen.getByRole("button", { name: "Cancel" }))

    expect(onConfirm).toHaveBeenCalledTimes(1)
    expect(onCancel).toHaveBeenCalledTimes(1)
  })

  it("disables both buttons while busy", () => {
    render(<ConfirmDialog {...baseProps} open busy />)

    expect(screen.getByRole("button", { name: "Working..." })).toBeDisabled()
    expect(screen.getByRole("button", { name: "Cancel" })).toBeDisabled()
  })
})
