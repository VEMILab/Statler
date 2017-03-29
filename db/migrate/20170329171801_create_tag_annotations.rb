class CreateTagAnnotations < ActiveRecord::Migration
  def change
    create_table :tag_annotations do |t|
		t.integer :annotation_id
		t.integer :semantic_tag_id
    end
  end

end
