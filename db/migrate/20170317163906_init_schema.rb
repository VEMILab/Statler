class InitSchema < ActiveRecord::Migration
  def up

    Could not dump table "annotations" because of following NoMethodError
      undefined method `[]' for nil:NilClass

    create_table "annotations_locations", id: false, force: :cascade do |t|
      t.integer "annotation_id", null: false
      t.integer "location_id",   null: false
    end

    create_table "annotations_videos", id: false, force: :cascade do |t|
      t.integer "annotation_id", null: false
      t.integer "video_id",      null: false
    end

    create_table "annotators", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "dummythings", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "locations", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "locations_videos", id: false, force: :cascade do |t|
      t.integer "video_id",    null: false
      t.integer "location_id", null: false
    end

    create_table "semantic_tags", force: :cascade do |t|
      t.string   "tag"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "users", force: :cascade do |t|
      t.string   "name"
      t.string   "email"
      t.string   "password_digest"
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

    create_table "videos", force: :cascade do |t|
      t.string   "title"
      t.string   "author"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
