require "rails_helper"

RSpec.describe AuditLogJob, type: :job do
  it "creates an audit log record from the given arguments" do
    expect {
      described_class.perform_now(
        actor_id: 1,
        subject_id: 2,
        action: "login",
        metadata: { "foo" => "bar" },
        ip_address: "127.0.0.1"
      )
    }.to change(AuditLog, :count).by(1)

    log = AuditLog.last
    expect(log.actor_id).to eq(1)
    expect(log.subject_id).to eq(2)
    expect(log.action).to eq("login")
    expect(log.metadata).to eq("foo" => "bar")
    expect(log.ip_address).to eq("127.0.0.1")
  end

  it "defaults metadata to an empty hash and ip_address to nil" do
    described_class.perform_now(actor_id: 1, subject_id: 1, action: "logout")

    log = AuditLog.last
    expect(log.metadata).to eq({})
    expect(log.ip_address).to be_nil
  end
end
