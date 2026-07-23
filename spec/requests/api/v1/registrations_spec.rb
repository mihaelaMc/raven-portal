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

  describe "PATCH /api/v1/signup" do
    let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }

    def token_for(user)
      post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
      response.headers["Authorization"]
    end

    it "changes the password when current_password is correct, without minting a refresh token" do
      auth = token_for(user)

      patch "/api/v1/signup", params: {
        user: { current_password: "password123", password: "newpassword456", password_confirmation: "newpassword456" }
      }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).not_to have_key("refresh_token")

      post "/api/v1/login", params: { user: { email: user.email, password: "newpassword456" } }
      expect(response).to have_http_status(:ok)
    end

    it "rejects the wrong current_password" do
      auth = token_for(user)

      patch "/api/v1/signup", params: {
        user: { current_password: "wrongpassword", password: "newpassword456", password_confirmation: "newpassword456" }
      }, headers: { "Authorization" => auth }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include(a_string_matching(/current password/i))

      post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
      expect(response).to have_http_status(:ok)
    end

    it "requires authentication" do
      patch "/api/v1/signup", params: {
        user: { current_password: "password123", password: "newpassword456", password_confirmation: "newpassword456" }
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
