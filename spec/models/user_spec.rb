require "rails_helper"

RSpec.describe User, type: :model do
  it "requires a crawler_name" do
    user = User.new(email: "crawler@example.com", password: "password123")
    expect(user).not_to be_valid
    expect(user.errors[:crawler_name]).to be_present
  end

  it "defaults role to user" do
    user = User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix")
    expect(user.role).to eq("user")
    expect(user.user?).to be true
  end

  it "allows role to be set to admin" do
    user = User.create!(email: "admin@example.com", password: "password123", crawler_name: "Overseer", role: :admin)
    expect(user.admin?).to be true
  end
end
