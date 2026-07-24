import { useEffect, useState } from "react"
import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import toast from "react-hot-toast"
import { Link } from "react-router-dom"
import { useAuth } from "../auth/AuthContext"
import { apiAssetUrl } from "../api/client"
import { changePassword, updateProfile } from "../api/profile"

const ALLOWED_AVATAR_TYPES = ["image/png", "image/jpeg", "image/webp"]
const MAX_AVATAR_SIZE = 5 * 1024 * 1024

const profileSchema = z.object({
  crawlerName: z.string().min(1, "Crawler name is required"),
  notifySecurityAlerts: z.boolean(),
  avatar: z
    .instanceof(FileList)
    .optional()
    .refine(
      (files) => !files?.length || ALLOWED_AVATAR_TYPES.includes(files[0].type),
      "Must be a PNG, JPEG, or WEBP image"
    )
    .refine((files) => !files?.length || files[0].size <= MAX_AVATAR_SIZE, "Must be smaller than 5MB"),
})

const passwordSchema = z
  .object({
    currentPassword: z.string().min(1, "Current password is required"),
    password: z.string().min(6, "Password must be at least 6 characters"),
    passwordConfirmation: z.string().min(1, "Please confirm your new password"),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    message: "Passwords don't match",
    path: ["passwordConfirmation"],
  })

function errorMessage(err, fallback) {
  return err.response?.data?.errors?.join(", ") || err.response?.data?.error || fallback
}

export default function ProfilePage() {
  const { user, refreshUser } = useAuth()
  const [previewUrl, setPreviewUrl] = useState(null)

  const profileForm = useForm({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      crawlerName: user?.crawler_name ?? "",
      notifySecurityAlerts: user?.notify_security_alerts ?? true,
    },
  })

  const avatarFiles = profileForm.watch("avatar")

  useEffect(() => {
    const file = avatarFiles?.[0]
    if (!file) {
      setPreviewUrl(null)
      return
    }
    const url = URL.createObjectURL(file)
    setPreviewUrl(url)
    return () => URL.revokeObjectURL(url)
  }, [avatarFiles])

  async function onProfileSubmit(values) {
    try {
      await updateProfile(user.id, {
        crawlerName: values.crawlerName,
        notifySecurityAlerts: values.notifySecurityAlerts,
        avatarFile: values.avatar?.[0],
      })
      await refreshUser()
      toast.success("Profile updated.")
      profileForm.reset({
        crawlerName: values.crawlerName,
        notifySecurityAlerts: values.notifySecurityAlerts,
        avatar: undefined,
      })
    } catch (err) {
      toast.error(errorMessage(err, "Couldn't update profile."))
    }
  }

  const passwordForm = useForm({
    resolver: zodResolver(passwordSchema),
    defaultValues: { currentPassword: "", password: "", passwordConfirmation: "" },
  })

  async function onPasswordSubmit(values) {
    try {
      await changePassword(values)
      toast.success("Password changed.")
      passwordForm.reset()
    } catch (err) {
      toast.error(errorMessage(err, "Couldn't change password."))
    }
  }

  return (
    <div className="mx-auto max-w-2xl p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-parchment">Your Profile</h1>
        <Link to="/dashboard" className="text-sm text-arcane hover:underline">
          Back to dashboard
        </Link>
      </div>

      <section className="mt-8 rounded-lg border border-dungeon-border bg-dungeon-panel p-6">
        <h2 className="text-lg font-semibold text-parchment">Profile</h2>
        <form onSubmit={profileForm.handleSubmit(onProfileSubmit)} className="mt-4 flex flex-col gap-4">
          <div className="flex items-center gap-4">
            {previewUrl || user?.avatar_url ? (
              <img
                src={previewUrl || apiAssetUrl(user.avatar_url)}
                alt=""
                className="h-16 w-16 rounded-full object-cover"
              />
            ) : (
              <div className="h-16 w-16 rounded-full bg-dungeon-border" />
            )}
            <label className="flex flex-col gap-1 text-sm text-parchment">
              Avatar
              <input
                type="file"
                accept="image/png,image/jpeg,image/webp"
                {...profileForm.register("avatar")}
                className="text-sm text-parchment/80"
              />
              {profileForm.formState.errors.avatar && (
                <span className="text-sm text-ember">{profileForm.formState.errors.avatar.message}</span>
              )}
            </label>
          </div>

          <label className="flex flex-col gap-1 text-sm text-parchment">
            Crawler name
            <input
              {...profileForm.register("crawlerName")}
              className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
            {profileForm.formState.errors.crawlerName && (
              <span className="text-sm text-ember">{profileForm.formState.errors.crawlerName.message}</span>
            )}
          </label>

          <div className="text-sm text-parchment/60">Email: {user?.email}</div>

          <label className="flex items-center gap-2 text-sm text-parchment">
            <input type="checkbox" {...profileForm.register("notifySecurityAlerts")} className="accent-torch" />
            Email me when my password is changed
          </label>

          <button
            type="submit"
            disabled={profileForm.formState.isSubmitting}
            className="self-start rounded-md bg-torch px-4 py-2 text-sm font-semibold text-dungeon disabled:opacity-60"
          >
            {profileForm.formState.isSubmitting ? "Saving..." : "Save profile"}
          </button>
        </form>
      </section>

      <section className="mt-8 rounded-lg border border-dungeon-border bg-dungeon-panel p-6">
        <h2 className="text-lg font-semibold text-parchment">Change password</h2>
        <form onSubmit={passwordForm.handleSubmit(onPasswordSubmit)} className="mt-4 flex flex-col gap-4">
          <label className="flex flex-col gap-1 text-sm text-parchment">
            Current password
            <input
              type="password"
              {...passwordForm.register("currentPassword")}
              className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
            {passwordForm.formState.errors.currentPassword && (
              <span className="text-sm text-ember">{passwordForm.formState.errors.currentPassword.message}</span>
            )}
          </label>
          <label className="flex flex-col gap-1 text-sm text-parchment">
            New password
            <input
              type="password"
              {...passwordForm.register("password")}
              className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
            {passwordForm.formState.errors.password && (
              <span className="text-sm text-ember">{passwordForm.formState.errors.password.message}</span>
            )}
          </label>
          <label className="flex flex-col gap-1 text-sm text-parchment">
            Confirm new password
            <input
              type="password"
              {...passwordForm.register("passwordConfirmation")}
              className="rounded-md border border-dungeon-border bg-dungeon px-3 py-2 text-parchment focus:outline-none focus:ring-2 focus:ring-torch"
            />
            {passwordForm.formState.errors.passwordConfirmation && (
              <span className="text-sm text-ember">{passwordForm.formState.errors.passwordConfirmation.message}</span>
            )}
          </label>
          <button
            type="submit"
            disabled={passwordForm.formState.isSubmitting}
            className="self-start rounded-md bg-torch px-4 py-2 text-sm font-semibold text-dungeon disabled:opacity-60"
          >
            {passwordForm.formState.isSubmitting ? "Changing..." : "Change password"}
          </button>
        </form>
      </section>
    </div>
  )
}
