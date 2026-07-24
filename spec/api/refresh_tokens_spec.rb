require "swagger_helper"

RSpec.describe "Refresh tokens", type: :request do
  path "/api/v1/refresh" do
    post "Exchange a refresh token for a new access token" do
      tags "Authentication"
      description "Rotates the refresh token: the presented one is revoked and a new one is returned alongside the fresh access token."
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: { refresh_token: { type: :string } },
        required: %w[refresh_token]
      }

      let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }

      response "200", "token rotated" do
        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 refresh_token: { type: :string },
                 user: { "$ref" => "#/components/schemas/user" }
               },
               required: %w[access_token refresh_token user]
        let(:payload) { { refresh_token: RefreshToken.issue_for(user).last } }
        run_test!
      end

      response "401", "invalid, expired, or already-rotated token" do
        schema "$ref" => "#/components/schemas/error"
        let(:payload) { { refresh_token: "not-a-real-token" } }
        run_test!
      end
    end
  end
end
