class AuditLogJob < ApplicationJob
  queue_as :default

  def perform(actor_id:, subject_id:, action:, metadata: {}, ip_address: nil)
    AuditLog.create!(
      actor_id: actor_id,
      subject_id: subject_id,
      action: action,
      metadata: metadata,
      ip_address: ip_address
    )
  end
end
