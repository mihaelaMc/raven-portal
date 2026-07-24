require "swagger_helper"

RSpec.describe "Audit logs", type: :request do
  def bearer_for(user)
    "Bearer #{Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first}"
  end

  let(:admin) { User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin) }
  let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }

  path "/api/v1/audit_logs" do
    get "Query the audit log" do
      tags "Audit logs"
      description "Admin only. Most recent first. All filters are optional and combinable."
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :audit_action, in: :query, schema: { type: :string, enum: AuditLog::ACTIONS }, required: false,
                description: "Named audit_action (not action) because action is Rails' reserved routing param"
      parameter name: :actor_id, in: :query, schema: { type: :integer }, required: false
      parameter name: :subject_id, in: :query, schema: { type: :integer }, required: false
      parameter name: :from, in: :query, schema: { type: :string, format: "date-time" }, required: false
      parameter name: :to, in: :query, schema: { type: :string, format: "date-time" }, required: false
      parameter name: :page, in: :query, schema: { type: :integer, default: 1 }, required: false
      parameter name: :per_page, in: :query, schema: { type: :integer, default: 25, minimum: 1, maximum: 100 }, required: false

      response "200", "paginated audit log entries" do
        schema type: :object,
               properties: {
                 audit_logs: { type: :array, items: { "$ref" => "#/components/schemas/audit_log" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[audit_logs meta]
        let(:Authorization) do
          AuditLog.create!(actor_id: admin.id, subject_id: admin.id, action: "login", ip_address: "127.0.0.1")
          bearer_for(admin)
        end
        run_test!
      end

      response "403", "not an admin" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { bearer_for(user) }
        run_test!
      end
    end
  end
end
