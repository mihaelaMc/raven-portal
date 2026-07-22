export default function RoleBadge({ role }) {
  const isAdmin = role === "admin"

  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${
        isAdmin ? "bg-torch/20 text-torch" : "bg-arcane/20 text-arcane"
      }`}
    >
      {role}
    </span>
  )
}
