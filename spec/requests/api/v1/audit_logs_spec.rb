require "rails_helper"

RSpec.describe "Api::V1::AuditLogs", type: :request do
  let!(:admin) { User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin) }
  let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }

  def token_for(user)
    post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
    response.headers["Authorization"]
  end

  describe "GET /api/v1/audit_logs" do
    it "forbids a non-admin" do
      auth = token_for(user)

      get "/api/v1/audit_logs", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
    end

    it "lets an admin list logs with pagination metadata" do
      AuditLog.create!(actor_id: user.id, subject_id: user.id, action: "login")
      AuditLog.create!(actor_id: user.id, subject_id: user.id, action: "logout")

      auth = token_for(admin)
      # the login above enqueued its own AuditLogJob; run it so the count below is deterministic
      perform_enqueued_jobs

      get "/api/v1/audit_logs", params: { per_page: 2 }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["audit_logs"].size).to eq(2)
      expect(body["meta"]["total_count"]).to be >= 3
    end

    it "filters by action" do
      AuditLog.create!(actor_id: user.id, subject_id: user.id, action: "login")
      AuditLog.create!(actor_id: user.id, subject_id: user.id, action: "logout")

      auth = token_for(admin)
      perform_enqueued_jobs

      get "/api/v1/audit_logs", params: { audit_action: "logout" }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["audit_logs"]).to all(include("action" => "logout"))
    end

    it "filters by subject_id" do
      AuditLog.create!(actor_id: admin.id, subject_id: user.id, action: "admin_updated_user")

      auth = token_for(admin)
      perform_enqueued_jobs

      get "/api/v1/audit_logs", params: { subject_id: user.id }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["audit_logs"]).to all(include("subject_id" => user.id))
    end
  end
end
