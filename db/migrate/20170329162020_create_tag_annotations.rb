class CreateTagAnnotations < ActiveRecord::Migration
  def change
    create_table :tag_annotations do |t|
      t.integer :anno_id
      t.integer :tag_id

      t.timestamps null: false
    end
  end
end
