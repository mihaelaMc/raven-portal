import { useEffect, useState } from "react"

export default function EditUserDialog({ open, user, isAdminViewer, onSave, onCancel, busy, error }) {
  const [crawlerName, setCrawlerName] = useState("")
  const [role, setRole] = useState("user")

  useEffect(() => {
    if (user) {
      setCrawlerName(user.crawler_name)
      setRole(user.role)
    }
  }, [user])

  if (!open || !user) return null

  function handleSubmit(event) {
    event.preventDefault()
    const fields = { crawler_name: crawlerName }
    if (isAdminViewer) fields.role = role
    onSave(fields)
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-sm rounded-lg border border-dungeon-border bg-dungeon-panel p-6">
        <h2 className="text-lg font-semibold text-parchment">Edit {user.crawler_name}</h2>
        <form onSubmit={handleSubmit} className="mt-4 flex flex-col gap-4">
          <label className="flex flex-col gap-1 text-sm text-parchment">
            Crawler name
            <input
              value={crawlerName}
              onChange={(e) => setCrawlerName(e.target.value)}
              required
              className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
          </label>
          {isAdminViewer && (
            <label className="flex flex-col gap-1 text-sm text-parchment">
              Role
              <select
                value={role}
                onChange={(e) => setRole(e.target.value)}
                className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
              >
                <option value="user">user</option>
                <option value="admin">admin</option>
              </select>
            </label>
          )}
          {error && <p className="text-sm text-ember">{error}</p>}
          <div className="mt-2 flex justify-end gap-3">
            <button
              type="button"
              onClick={onCancel}
              disabled={busy}
              className="rounded-md px-4 py-2 text-sm text-parchment/80 hover:text-parchment"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={busy}
              className="rounded-md bg-torch px-4 py-2 text-sm font-semibold text-dungeon disabled:opacity-60"
            >
              {busy ? "Saving..." : "Save"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
