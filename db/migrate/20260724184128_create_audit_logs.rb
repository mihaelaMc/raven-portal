class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      # No foreign keys: an audit log must survive the deletion of the user
      # it describes (e.g. logging that an account, or its own actor, was deleted).
      t.bigint :actor_id, null: false
      t.bigint :subject_id, null: false
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_address

      t.timestamps
    end

    add_index :audit_logs, :actor_id
    add_index :audit_logs, :subject_id
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
