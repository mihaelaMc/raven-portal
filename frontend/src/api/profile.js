import client from "./client"

export function getProfile() {
  return client.get("/me").then((res) => res.data)
}

// Uses FormData (not plain JSON like api/users.js#updateUser) because this is the
// one place an avatar File can be part of the payload, which needs multipart encoding.
export function updateProfile(id, { crawlerName, notifySecurityAlerts, avatarFile }) {
  const formData = new FormData()
  if (crawlerName !== undefined) formData.append("user[crawler_name]", crawlerName)
  if (notifySecurityAlerts !== undefined) formData.append("user[notify_security_alerts]", notifySecurityAlerts)
  if (avatarFile) formData.append("user[avatar]", avatarFile)

  return client.patch(`/users/${id}`, formData).then((res) => res.data)
}

export function changePassword({ currentPassword, password, passwordConfirmation }) {
  return client
    .patch("/signup", {
      user: {
        current_password: currentPassword,
        password,
        password_confirmation: passwordConfirmation,
      },
    })
    .then((res) => res.data)
}
