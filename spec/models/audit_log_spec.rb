require "rails_helper"

RSpec.describe AuditLog, type: :model do
  it "rejects an action outside the known list" do
    log = AuditLog.new(actor_id: 1, subject_id: 1, action: "bogus")

    expect(log).not_to be_valid
    expect(log.errors[:action]).to be_present
  end

  it "accepts any action in the known list" do
    AuditLog::ACTIONS.each do |action|
      log = AuditLog.new(actor_id: 1, subject_id: 1, action: action)
      expect(log).to be_valid
    end
  end
end
