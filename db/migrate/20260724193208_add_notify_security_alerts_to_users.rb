class AddNotifySecurityAlertsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notify_security_alerts, :boolean, default: true, null: false
  end
end
