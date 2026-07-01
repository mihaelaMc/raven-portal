class AddCrawlerNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :crawler_name, :string
  end
end
