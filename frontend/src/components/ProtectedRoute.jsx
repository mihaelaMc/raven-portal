import { Navigate } from "react-router-dom"
import { useAuth } from "../auth/AuthContext"

export default function ProtectedRoute({ children }) {
  const { status } = useAuth()

  if (status !== "authenticated") {
    return <Navigate to="/login" replace />
  }

  return children
}
