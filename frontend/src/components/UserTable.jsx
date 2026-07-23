import { useEffect, useMemo, useState } from "react"
import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from "@tanstack/react-table"
import toast from "react-hot-toast"
import { useAuth } from "../auth/AuthContext"
import { useDeleteUserMutation, useUpdateUserMutation, useUsersQuery } from "../hooks/useUsers"
import RoleBadge from "./RoleBadge"
import ConfirmDialog from "./ConfirmDialog"
import EditUserDialog from "./EditUserDialog"

const PER_PAGE = 10
const columnHelper = createColumnHelper()

export default function UserTable() {
  const { user: currentUser } = useAuth()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState("")
  const [debouncedSearch, setDebouncedSearch] = useState("")
  const [editingUser, setEditingUser] = useState(null)
  const [deletingUser, setDeletingUser] = useState(null)
  const [editError, setEditError] = useState(null)

  useEffect(() => {
    const timeout = setTimeout(() => {
      setDebouncedSearch(search)
      setPage(1)
    }, 300)
    return () => clearTimeout(timeout)
  }, [search])

  const { data, isLoading, isError } = useUsersQuery({ page, perPage: PER_PAGE, q: debouncedSearch })
  const updateMutation = useUpdateUserMutation()
  const deleteMutation = useDeleteUserMutation()

  const columns = useMemo(
    () => [
      columnHelper.accessor("avatar_url", {
        header: "",
        cell: (info) =>
          info.getValue() ? (
            <img src={info.getValue()} alt="" className="h-8 w-8 rounded-full object-cover" />
          ) : (
            <div className="h-8 w-8 rounded-full bg-dungeon-border" />
          ),
      }),
      columnHelper.accessor("crawler_name", { header: "Crawler" }),
      columnHelper.accessor("email", { header: "Email" }),
      columnHelper.accessor("role", {
        header: "Role",
        cell: (info) => <RoleBadge role={info.getValue()} />,
      }),
      columnHelper.accessor("created_at", {
        header: "Joined",
        cell: (info) => new Date(info.getValue()).toLocaleDateString(),
      }),
      columnHelper.display({
        id: "actions",
        header: "",
        cell: ({ row }) => (
          <div className="flex justify-end gap-3">
            <button
              onClick={() => {
                setEditError(null)
                setEditingUser(row.original)
              }}
              className="text-sm text-arcane hover:underline"
            >
              Edit
            </button>
            <button onClick={() => setDeletingUser(row.original)} className="text-sm text-ember hover:underline">
              Delete
            </button>
          </div>
        ),
      }),
    ],
    []
  )

  const table = useReactTable({
    data: data?.users ?? [],
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  async function handleSave(fields) {
    try {
      await updateMutation.mutateAsync({ id: editingUser.id, data: fields })
      toast.success(`${editingUser.crawler_name}'s profile updated.`)
      setEditingUser(null)
    } catch (err) {
      setEditError(err.response?.data?.errors?.join(", ") || "Something went wrong.")
    }
  }

  async function handleDelete() {
    try {
      await deleteMutation.mutateAsync(deletingUser.id)
      toast.success(`${deletingUser.crawler_name} was deleted.`)
      setDeletingUser(null)
    } catch {
      toast.error("Couldn't delete that crawler.")
    }
  }

  const meta = data?.meta

  return (
    <div className="mt-8">
      <div className="flex items-center justify-between gap-4">
        <h2 className="text-xl font-semibold text-parchment">Crawlers</h2>
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by name or email..."
          className="w-64 rounded-md border border-dungeon-border bg-dungeon-panel px-3 py-2 text-sm text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
        />
      </div>

      <div className="mt-4 overflow-x-auto rounded-lg border border-dungeon-border">
        <table className="w-full text-left text-sm">
          <thead className="bg-dungeon-panel text-parchment/70">
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <th key={header.id} className="px-4 py-3 font-medium">
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {isLoading && (
              <tr>
                <td colSpan={columns.length} className="px-4 py-6 text-center text-parchment/60">
                  Loading...
                </td>
              </tr>
            )}
            {isError && (
              <tr>
                <td colSpan={columns.length} className="px-4 py-6 text-center text-ember">
                  Couldn't load users.
                </td>
              </tr>
            )}
            {!isLoading && !isError && table.getRowModel().rows.length === 0 && (
              <tr>
                <td colSpan={columns.length} className="px-4 py-6 text-center text-parchment/60">
                  No crawlers found.
                </td>
              </tr>
            )}
            {table.getRowModel().rows.map((row) => (
              <tr key={row.id} className="border-t border-dungeon-border">
                {row.getVisibleCells().map((cell) => (
                  <td key={cell.id} className="px-4 py-3 text-parchment">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {meta && (
        <div className="mt-4 flex items-center justify-between text-sm text-parchment/70">
          <span>
            Page {meta.current_page} of {meta.total_pages} ({meta.total_count} total)
          </span>
          <div className="flex gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={meta.current_page <= 1}
              className="rounded-md border border-dungeon-border px-3 py-1 disabled:opacity-40"
            >
              Previous
            </button>
            <button
              onClick={() => setPage((p) => Math.min(meta.total_pages, p + 1))}
              disabled={meta.current_page >= meta.total_pages}
              className="rounded-md border border-dungeon-border px-3 py-1 disabled:opacity-40"
            >
              Next
            </button>
          </div>
        </div>
      )}

      <EditUserDialog
        open={!!editingUser}
        user={editingUser}
        isAdminViewer={currentUser?.role === "admin"}
        onSave={handleSave}
        onCancel={() => setEditingUser(null)}
        busy={updateMutation.isPending}
        error={editError}
      />

      <ConfirmDialog
        open={!!deletingUser}
        title="Delete crawler"
        message={deletingUser ? `Remove ${deletingUser.crawler_name} permanently? This cannot be undone.` : ""}
        confirmLabel="Delete"
        onConfirm={handleDelete}
        onCancel={() => setDeletingUser(null)}
        busy={deleteMutation.isPending}
      />
    </div>
  )
}
