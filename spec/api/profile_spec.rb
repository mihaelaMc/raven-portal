require "swagger_helper"

RSpec.describe "Profile", type: :request do
  path "/api/v1/me" do
    get "Current user's profile" do
      tags "Profile"
      security [ bearer_auth: [] ]
      produces "application/json"

      let(:user) { User.create!(email: "grix@example.com", password: "password123", crawler_name: "Grix") }

      response "200", "the authenticated user" do
        schema type: :object,
               properties: { user: { "$ref" => "#/components/schemas/user" } },
               required: %w[user]
        let(:Authorization) { "Bearer #{Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first}" }
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
