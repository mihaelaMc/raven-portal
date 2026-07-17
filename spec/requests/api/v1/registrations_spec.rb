require "rails_helper"

RSpec.describe "Api::V1::Registrations", type: :request do
  describe "POST /api/v1/signup" do
    it "creates a crawler and returns a JWT plus a refresh token" do
      post "/api/v1/signup", params: {
        user: { email: "crawler@example.com", password: "password123", crawler_name: "Grix" }
      }

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to be_present

      body = JSON.parse(response.body)
      expect(body["user"]["crawler_name"]).to eq("Grix")
      expect(body["user"]["role"]).to eq("user")
      expect(body["refresh_token"]).to be_present
    end

    it "rejects a signup without a crawler_name" do
      post "/api/v1/signup", params: {
        user: { email: "crawler@example.com", password: "password123" }
      }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include(a_string_matching(/crawler name/i))
    end
  end
end
