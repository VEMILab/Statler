class AddTokenCreatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_created_at, :datetime
  end
end
