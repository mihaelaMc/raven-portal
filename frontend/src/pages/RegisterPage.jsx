import { useState } from "react"
import { useNavigate, Link } from "react-router-dom"
import { useAuth } from "../auth/AuthContext"

function errorMessage(err) {
  return err.response?.data?.errors?.join(", ") || err.response?.data?.error || "Something went wrong."
}

export default function RegisterPage() {
  const { register } = useAuth()
  const navigate = useNavigate()
  const [crawlerName, setCrawlerName] = useState("")
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [passwordConfirmation, setPasswordConfirmation] = useState("")
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(event) {
    event.preventDefault()
    setError(null)
    setSubmitting(true)

    try {
      await register({ email, password, passwordConfirmation, crawlerName })
      navigate("/dashboard")
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <div className="w-full max-w-sm">
        <h1 className="text-3xl font-bold text-parchment">Create Your Crawler</h1>
        <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-4">
          <label className="flex flex-col gap-1 text-sm">
            Crawler name
            <input
              value={crawlerName}
              onChange={(e) => setCrawlerName(e.target.value)}
              required
              className="rounded-md border border-dungeon-border bg-dungeon-panel px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm">
            Email
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="rounded-md border border-dungeon-border bg-dungeon-panel px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm">
            Password
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="rounded-md border border-dungeon-border bg-dungeon-panel px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm">
            Confirm password
            <input
              type="password"
              value={passwordConfirmation}
              onChange={(e) => setPasswordConfirmation(e.target.value)}
              required
              className="rounded-md border border-dungeon-border bg-dungeon-panel px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
          </label>
          {error && <p className="text-sm text-ember">{error}</p>}
          <button
            type="submit"
            disabled={submitting}
            className="rounded-md bg-torch py-2 font-semibold text-dungeon disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "Entering..." : "Enter the dungeon"}
          </button>
        </form>
        <p className="mt-4 text-sm">
          Already a crawler?{" "}
          <Link to="/login" className="text-arcane hover:underline">
            Sign in
          </Link>
        </p>
      </div>
    </div>
  )
}
