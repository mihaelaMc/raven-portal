import client from "./client"

export function listUsers({ page = 1, perPage = 10, q = "" } = {}) {
  return client.get("/users", { params: { page, per_page: perPage, q: q || undefined } }).then((res) => res.data)
}

export function updateUser(id, data) {
  return client.patch(`/users/${id}`, { user: data }).then((res) => res.data)
}

export function deleteUser(id) {
  return client.delete(`/users/${id}`)
}
