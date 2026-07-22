export default function ConfirmDialog({ open, title, message, confirmLabel = "Confirm", onConfirm, onCancel, busy }) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-sm rounded-lg border border-dungeon-border bg-dungeon-panel p-6">
        <h2 className="text-lg font-semibold text-parchment">{title}</h2>
        <p className="mt-2 text-sm text-parchment/80">{message}</p>
        <div className="mt-6 flex justify-end gap-3">
          <button
            type="button"
            onClick={onCancel}
            disabled={busy}
            className="rounded-md px-4 py-2 text-sm text-parchment/80 hover:text-parchment"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={busy}
            className="rounded-md bg-ember px-4 py-2 text-sm font-semibold text-dungeon disabled:opacity-60"
          >
            {busy ? "Working..." : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
