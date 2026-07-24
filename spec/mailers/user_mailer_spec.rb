require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { User.new(crawler_name: "Grix", email: "grix@example.com") }

  describe "#welcome_email" do
    let(:mail) { described_class.welcome_email(user) }

    it "is addressed to the new crawler" do
      expect(mail.to).to eq([ "grix@example.com" ])
      expect(mail.subject).to match(/selected for entry/i)
    end

    it "mentions the crawler by name in the body" do
      expect(mail.body.encoded).to include("Grix")
    end
  end

  describe "#security_alert" do
    let(:mail) { described_class.security_alert(user) }

    it "is addressed to the crawler and warns about the password change" do
      expect(mail.to).to eq([ "grix@example.com" ])
      expect(mail.subject).to match(/password was just changed/i)
      expect(mail.body.encoded).to include("Grix")
    end
  end
end
