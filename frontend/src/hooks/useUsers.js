import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { deleteUser, listUsers, updateUser } from "../api/users"

export function useUsersQuery({ page, perPage, q }) {
  return useQuery({
    queryKey: ["users", { page, perPage, q }],
    queryFn: () => listUsers({ page, perPage, q }),
    placeholderData: (previousData) => previousData,
  })
}

export function useUpdateUserMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }) => updateUser(id, data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["users"] }),
  })
}

export function useDeleteUserMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id) => deleteUser(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["users"] }),
  })
}
