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

  it "defaults notify_security_alerts to true" do
    user = User.create!(email: "crawler@example.com", password: "password123", crawler_name: "Grix")
    expect(user.notify_security_alerts).to be true
  end

  describe "avatar" do
    def user_with_avatar(io:, filename:, content_type:)
      user = User.new(email: "crawler@example.com", password: "password123", crawler_name: "Grix")
      user.avatar.attach(io: io, filename: filename, content_type: content_type)
      user
    end

    it "accepts an allowed image type under the size limit" do
      user = user_with_avatar(io: StringIO.new("fake image data"), filename: "avatar.png", content_type: "image/png")

      expect(user).to be_valid
    end

    it "rejects a disallowed content type" do
      user = user_with_avatar(io: StringIO.new("fake pdf data"), filename: "avatar.pdf", content_type: "application/pdf")

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end

    it "rejects a file over the size limit" do
      user = user_with_avatar(
        io: StringIO.new("a" * (User::MAX_AVATAR_SIZE + 1)),
        filename: "avatar.png",
        content_type: "image/png"
      )

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end
  end
end
