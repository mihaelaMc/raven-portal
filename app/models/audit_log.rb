class AuditLog < ApplicationRecord
  ACTIONS = %w[
    login logout signup password_changed profile_updated
    admin_updated_user account_deleted admin_deleted_user
  ].freeze

  validates :action, inclusion: { in: ACTIONS }
end
