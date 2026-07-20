require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { User.new(role: :admin) }
  let(:user) { User.new(role: :user) }
  let(:other_user) { User.new(role: :user) }

  describe "#index?" do
    it "allows an admin" do
      expect(described_class.new(admin, User)).to be_index
    end

    it "forbids a non-admin" do
      expect(described_class.new(user, User)).not_to be_index
    end
  end

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

  describe "#update?" do
    it "allows an admin to update anyone" do
      expect(described_class.new(admin, other_user)).to be_update
    end

    it "allows a user to update themself" do
      expect(described_class.new(user, user)).to be_update
    end

    it "forbids a user from updating someone else" do
      expect(described_class.new(user, other_user)).not_to be_update
    end
  end

  describe "#destroy?" do
    it "allows an admin to destroy anyone" do
      expect(described_class.new(admin, other_user)).to be_destroy
    end

    it "allows a user to destroy themself" do
      expect(described_class.new(user, user)).to be_destroy
    end

    it "forbids a user from destroying someone else" do
      expect(described_class.new(user, other_user)).not_to be_destroy
    end
  end
end
