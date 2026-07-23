import { Link, useNavigate } from "react-router-dom"
import { useAuth } from "../auth/AuthContext"
import RoleBadge from "../components/RoleBadge"
import UserTable from "../components/UserTable"

export default function DashboardPage() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  async function handleLogout() {
    await logout()
    navigate("/login")
  }

  return (
    <div className="mx-auto max-w-5xl p-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-parchment">Welcome, {user?.crawler_name}</h1>
          <div className="mt-1">
            <RoleBadge role={user?.role} />
          </div>
        </div>
        <div className="flex items-center gap-4">
          <Link to="/profile" className="text-sm text-arcane hover:underline">
            Profile
          </Link>
          <button onClick={handleLogout} className="rounded-md bg-torch px-4 py-2 text-sm font-semibold text-dungeon">
            Log out
          </button>
        </div>
      </div>

      {user?.role === "admin" && <UserTable />}
    </div>
  )
}
