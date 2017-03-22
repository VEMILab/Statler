class AddTagsToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :tags, :text
  end
end
