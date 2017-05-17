class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :application_name
      t.string :api_key

      t.timestamps null: false
    end
  end
end
