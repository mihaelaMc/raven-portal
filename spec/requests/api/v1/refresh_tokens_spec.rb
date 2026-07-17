require "rails_helper"

RSpec.describe "Api::V1::RefreshTokens", type: :request do
  let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }

  def refresh_token_for(user)
    RefreshToken.issue_for(user).last
  end

  describe "POST /api/v1/refresh" do
    it "exchanges a valid refresh token for a new access token and rotates it" do
      raw_token = refresh_token_for(user)

      post "/api/v1/refresh", params: { refresh_token: raw_token }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["access_token"]).to be_present
      expect(body["refresh_token"]).to be_present
      expect(body["refresh_token"]).not_to eq(raw_token)

      # the old refresh token was rotated out, so re-using it fails
      post "/api/v1/refresh", params: { refresh_token: raw_token }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an expired refresh token" do
      refresh_token, raw_token = RefreshToken.issue_for(user)
      refresh_token.update!(expires_at: 1.day.ago)

      post "/api/v1/refresh", params: { refresh_token: raw_token }

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an unknown refresh token" do
      post "/api/v1/refresh", params: { refresh_token: "not-a-real-token" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
