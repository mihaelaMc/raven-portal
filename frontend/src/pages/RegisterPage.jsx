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
    <div className="auth-page">
      <h1>Create Your Crawler</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Crawler name
          <input value={crawlerName} onChange={(e) => setCrawlerName(e.target.value)} required />
        </label>
        <label>
          Email
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label>
          Password
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </label>
        <label>
          Confirm password
          <input
            type="password"
            value={passwordConfirmation}
            onChange={(e) => setPasswordConfirmation(e.target.value)}
            required
          />
        </label>
        {error && <p className="form-error">{error}</p>}
        <button type="submit" disabled={submitting}>
          {submitting ? "Entering..." : "Enter the dungeon"}
        </button>
      </form>
      <p>
        Already a crawler? <Link to="/login">Sign in</Link>
      </p>
    </div>
  )
}
