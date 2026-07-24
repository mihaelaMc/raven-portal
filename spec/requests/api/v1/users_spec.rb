require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let!(:admin) { User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin) }
  let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }
  let!(:other_user) { User.create!(email: "other@example.com", password: "password123", crawler_name: "Fenn") }

  def token_for(user)
    post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
    response.headers["Authorization"]
  end

  describe "GET /api/v1/users" do
    it "lets an admin list all users with pagination metadata" do
      auth = token_for(admin)

      get "/api/v1/users", params: { per_page: 2 }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["users"].size).to eq(2)
      expect(body["meta"]).to eq("current_page" => 1, "total_pages" => 2, "total_count" => 3)
    end

    it "forbids a non-admin" do
      auth = token_for(user)

      get "/api/v1/users", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
    end

    it "filters by crawler_name or email with the q param" do
      auth = token_for(admin)

      get "/api/v1/users", params: { q: "fenn" }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["users"].map { |u| u["crawler_name"] }).to eq([ "Fenn" ])
      expect(body["meta"]).to eq("current_page" => 1, "total_pages" => 1, "total_count" => 1)
    end

    it "escapes ILIKE wildcard characters in the q param" do
      auth = token_for(admin)

      get "/api/v1/users", params: { q: "%" }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["users"]).to eq([])
    end
  end

  describe "GET /api/v1/users/:id" do
    it "lets an admin view any user" do
      auth = token_for(admin)

      get "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["user"]["crawler_name"]).to eq("Fenn")
    end

    it "lets a user view themself" do
      auth = token_for(user)

      get "/api/v1/users/#{user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
    end

    it "forbids a user from viewing someone else" do
      auth = token_for(user)

      get "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      get "/api/v1/users/#{other_user.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/users/:id" do
    it "lets a user update their own crawler_name" do
      auth = token_for(user)

      patch "/api/v1/users/#{user.id}", params: { user: { crawler_name: "Grix the Bold" } }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(user.reload.crawler_name).to eq("Grix the Bold")
    end

    it "ignores a role change from a non-admin" do
      auth = token_for(user)

      patch "/api/v1/users/#{user.id}", params: { user: { role: "admin" } }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(user.reload.role).to eq("user")
    end

    it "lets an admin change another user's role" do
      auth = token_for(admin)

      patch "/api/v1/users/#{user.id}", params: { user: { role: "admin" } }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(user.reload.role).to eq("admin")
    end

    it "forbids a user from updating someone else" do
      auth = token_for(user)

      patch "/api/v1/users/#{other_user.id}", params: { user: { crawler_name: "Hijacked" } }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
      expect(other_user.reload.crawler_name).to eq("Fenn")
    end

    it "logs a self profile update" do
      auth = token_for(user)

      expect {
        patch "/api/v1/users/#{user.id}", params: { user: { crawler_name: "Grix the Bold" } }, headers: { "Authorization" => auth }
      }.to have_enqueued_job(AuditLogJob).with(hash_including(actor_id: user.id, subject_id: user.id, action: "profile_updated"))
    end

    it "logs an admin update of another user" do
      auth = token_for(admin)

      expect {
        patch "/api/v1/users/#{user.id}", params: { user: { role: "admin" } }, headers: { "Authorization" => auth }
      }.to have_enqueued_job(AuditLogJob).with(hash_including(actor_id: admin.id, subject_id: user.id, action: "admin_updated_user"))
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "lets a user delete themself and cascades their refresh tokens" do
      auth = token_for(user)
      RefreshToken.issue_for(user)

      delete "/api/v1/users/#{user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:no_content)
      expect(User.exists?(user.id)).to be false
      expect(RefreshToken.where(user_id: user.id)).to be_empty
    end

    it "lets an admin delete another user" do
      auth = token_for(admin)

      delete "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:no_content)
      expect(User.exists?(other_user.id)).to be false
    end

    it "forbids a user from deleting someone else" do
      auth = token_for(user)

      delete "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
      expect(User.exists?(other_user.id)).to be true
    end

    it "logs a self-delete" do
      auth = token_for(user)
      user_id = user.id

      expect {
        delete "/api/v1/users/#{user_id}", headers: { "Authorization" => auth }
      }.to have_enqueued_job(AuditLogJob).with(hash_including(actor_id: user_id, subject_id: user_id, action: "account_deleted"))
    end

    it "logs an admin delete of another user" do
      auth = token_for(admin)

      expect {
        delete "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }
      }.to have_enqueued_job(AuditLogJob).with(hash_including(actor_id: admin.id, subject_id: other_user.id, action: "admin_deleted_user"))
    end
  end
end
