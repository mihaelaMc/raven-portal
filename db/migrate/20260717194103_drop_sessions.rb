class DropSessions < ActiveRecord::Migration[8.1]
  def change
    drop_table :sessions do |t|
      t.integer :user_id, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
