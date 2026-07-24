require "swagger_helper"

RSpec.describe "Users", type: :request do
  def bearer_for(user)
    "Bearer #{Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first}"
  end

  let(:admin) { User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin) }
  let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }
  let(:other_user) { User.create!(email: "fenn@example.com", password: "password123", crawler_name: "Fenn") }

  path "/api/v1/users" do
    get "List users" do
      tags "Users"
      description "Admin only. Paginated; q searches crawler_name and email (case-insensitive substring)."
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, schema: { type: :integer, default: 1 }, required: false
      parameter name: :per_page, in: :query, schema: { type: :integer, default: 25, minimum: 1, maximum: 100 }, required: false,
                description: "Values outside 1..100 are clamped"
      parameter name: :q, in: :query, schema: { type: :string }, required: false,
                description: "Search by crawler name or email"

      response "200", "paginated users" do
        schema type: :object,
               properties: {
                 users: { type: :array, items: { "$ref" => "#/components/schemas/user" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[users meta]
        let(:Authorization) { bearer_for(admin) }
        run_test!
      end

      response "403", "not an admin" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { bearer_for(user) }
        run_test!
      end

      response "401", "missing or invalid token" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "View a user" do
      tags "Users"
      description "A user can view themself; admins can view anyone."
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "the user" do
        schema type: :object,
               properties: { user: { "$ref" => "#/components/schemas/user" } },
               required: %w[user]
        let(:Authorization) { bearer_for(admin) }
        let(:id) { other_user.id }
        run_test!
      end

      response "403", "viewing someone else without admin role" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { bearer_for(user) }
        let(:id) { other_user.id }
        run_test!
      end

      response "404", "no such user" do
        let(:Authorization) { bearer_for(admin) }
        let(:id) { 999_999 }
        run_test!
      end
    end

    patch "Update a user" do
      tags "Users"
      description "A user can update themself; admins can update anyone. `role` is applied only when the caller is an admin " \
                  "(silently ignored otherwise). Avatar uploads use multipart/form-data with the same field names " \
                  "(user[avatar] as a PNG/JPEG/WEBP file up to 5MB)."
      security [ bearer_auth: [] ]
      consumes "application/json", "multipart/form-data"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              crawler_name: { type: :string },
              notify_security_alerts: { type: :boolean },
              role: { type: :string, enum: %w[user admin], description: "Admin callers only" },
              avatar: { type: :string, format: :binary, description: "multipart/form-data only" }
            }
          }
        },
        required: %w[user]
      }

      response "200", "updated" do
        schema type: :object,
               properties: { user: { "$ref" => "#/components/schemas/user" } },
               required: %w[user]
        let(:Authorization) { bearer_for(user) }
        let(:id) { user.id }
        let(:payload) { { user: { crawler_name: "Grix the Bold" } } }
        run_test!
      end

      response "422", "validation failure" do
        schema "$ref" => "#/components/schemas/errors"
        let(:Authorization) { bearer_for(user) }
        let(:id) { user.id }
        let(:payload) { { user: { crawler_name: "" } } }
        run_test!
      end

      response "403", "updating someone else without admin role" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { bearer_for(user) }
        let(:id) { other_user.id }
        let(:payload) { { user: { crawler_name: "Hijacked" } } }
        run_test!
      end
    end

    delete "Delete a user" do
      tags "Users"
      description "A user can delete themself; admins can delete anyone. Cascades the user's refresh tokens; audit history is preserved."
      security [ bearer_auth: [] ]

      response "204", "deleted" do
        let(:Authorization) { bearer_for(admin) }
        let(:id) { other_user.id }
        run_test!
      end

      response "403", "deleting someone else without admin role" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { bearer_for(user) }
        let(:id) { other_user.id }
        run_test!
      end
    end
  end
end
