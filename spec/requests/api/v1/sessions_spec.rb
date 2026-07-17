require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }

  describe "POST /api/v1/login" do
    it "authenticates and returns a JWT plus a refresh token" do
      post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to be_present
      expect(JSON.parse(response.body)["refresh_token"]).to be_present
    end

    it "rejects the wrong password" do
      post "/api/v1/login", params: { user: { email: user.email, password: "wrong" } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/logout" do
    it "revokes the access token so it can no longer authenticate" do
      post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
      token = response.headers["Authorization"]

      delete "/api/v1/logout", headers: { "Authorization" => token }
      expect(response).to have_http_status(:ok)

      get "/api/v1/me", headers: { "Authorization" => token }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
