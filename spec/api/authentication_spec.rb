require "swagger_helper"

RSpec.describe "Authentication", type: :request do
  def bearer_for(user)
    "Bearer #{Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first}"
  end

  path "/api/v1/signup" do
    post "Register a new crawler" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, minLength: 6 },
              password_confirmation: { type: :string },
              crawler_name: { type: :string }
            },
            required: %w[email password crawler_name]
          }
        },
        required: %w[user]
      }

      response "200", "crawler created and signed in" do
        header "Authorization", schema: { type: :string }, description: "Bearer JWT access token (expires in 30 minutes)"
        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: { "$ref" => "#/components/schemas/user" },
                 refresh_token: { type: :string, description: "Single-use; rotate at /refresh" }
               },
               required: %w[user refresh_token]
        let(:credentials) { { user: { email: "grix@example.com", password: "password123", crawler_name: "Grix" } } }
        run_test!
      end

      response "422", "validation failure" do
        schema "$ref" => "#/components/schemas/errors"
        let(:credentials) { { user: { email: "grix@example.com", password: "password123" } } }
        run_test!
      end
    end

    patch "Change the current user's password" do
      tags "Authentication"
      description "Requires the current password. Sends a security-alert email unless the user has opted out via notify_security_alerts."
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              current_password: { type: :string },
              password: { type: :string, minLength: 6 },
              password_confirmation: { type: :string }
            },
            required: %w[current_password password password_confirmation]
          }
        },
        required: %w[user]
      }

      let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }
      let(:credentials) do
        { user: { current_password: "password123", password: "newpassword456", password_confirmation: "newpassword456" } }
      end

      response "200", "password changed" do
        schema type: :object,
               properties: { message: { type: :string }, user: { "$ref" => "#/components/schemas/user" } },
               required: %w[user]
        let(:Authorization) { bearer_for(user) }
        run_test!
      end

      response "422", "wrong current password" do
        schema "$ref" => "#/components/schemas/errors"
        let(:Authorization) { bearer_for(user) }
        let(:credentials) do
          { user: { current_password: "wrong", password: "newpassword456", password_confirmation: "newpassword456" } }
        end
        run_test!
      end

      response "401", "missing or invalid token" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/login" do
    post "Sign in" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: %w[email password]
          }
        },
        required: %w[user]
      }

      let!(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }

      response "200", "signed in" do
        header "Authorization", schema: { type: :string }, description: "Bearer JWT access token (expires in 30 minutes)"
        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: { "$ref" => "#/components/schemas/user" },
                 refresh_token: { type: :string, description: "Single-use; rotate at /refresh" }
               },
               required: %w[user refresh_token]
        let(:credentials) { { user: { email: "grix@example.com", password: "password123" } } }
        run_test!
      end

      response "401", "bad credentials" do
        schema "$ref" => "#/components/schemas/error"
        let(:credentials) { { user: { email: "grix@example.com", password: "wrong" } } }
        run_test!
      end
    end
  end

  path "/api/v1/logout" do
    delete "Sign out" do
      tags "Authentication"
      description "Revokes the presented JWT (denylist) and all of the user's outstanding refresh tokens."
      security [ bearer_auth: [] ]
      produces "application/json"

      let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }

      response "200", "signed out" do
        schema type: :object, properties: { message: { type: :string } }, required: %w[message]
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
end
