require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { User.new(role: :admin) }
  let(:user) { User.new(role: :user) }
  let(:other_user) { User.new(role: :user) }

  describe "#show?" do
    it "allows an admin to view anyone" do
      expect(described_class.new(admin, other_user)).to be_show
    end

    it "allows a user to view themself" do
      expect(described_class.new(user, user)).to be_show
    end

    it "forbids a user from viewing someone else" do
      expect(described_class.new(user, other_user)).not_to be_show
    end
  end
end
