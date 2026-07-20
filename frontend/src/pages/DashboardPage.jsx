import { useNavigate } from "react-router-dom"
import { useAuth } from "../auth/AuthContext"

export default function DashboardPage() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  async function handleLogout() {
    await logout()
    navigate("/login")
  }

  return (
    <div className="dashboard-page">
      <h1>Welcome, {user?.crawler_name}</h1>
      <p>Role: {user?.role}</p>
      <button onClick={handleLogout}>Log out</button>
    </div>
  )
}
