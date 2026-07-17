require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let!(:admin) { User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin) }
  let!(:user) { User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix") }
  let!(:other_user) { User.create!(email: "other@example.com", password: "password123", crawler_name: "Fenn") }

  def token_for(user)
    post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
    response.headers["Authorization"]
  end

  describe "GET /api/v1/users/:id" do
    it "lets an admin view any user" do
      auth = token_for(admin)

      get "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["user"]["crawler_name"]).to eq("Fenn")
    end

    it "lets a user view themself" do
      auth = token_for(user)

      get "/api/v1/users/#{user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:ok)
    end

    it "forbids a user from viewing someone else" do
      auth = token_for(user)

      get "/api/v1/users/#{other_user.id}", headers: { "Authorization" => auth }

      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      get "/api/v1/users/#{other_user.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
