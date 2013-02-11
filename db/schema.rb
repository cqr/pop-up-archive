# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130211222250) do

  add_extension "hstore"

  create_table "collection_grants", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "collection_grants", ["collection_id"], :name => "index_collection_grants_on_collection_id"
  add_index "collection_grants", ["user_id"], :name => "index_collection_grants_on_user_id"

  create_table "collections", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.boolean  "items_visible_by_default", :default => false
  end

  create_table "contributions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "item_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "contributions", ["item_id"], :name => "index_contributions_on_item_id"
  add_index "contributions", ["person_id"], :name => "index_contributions_on_person_id"

  create_table "csv_imports", :force => true do |t|
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "file"
    t.integer  "state_index",   :default => 0
    t.string   "headers",                                      :array => true
    t.string   "file_name"
    t.string   "error_message"
    t.text     "backtrace"
    t.integer  "collection_id"
    t.integer  "user_id"
  end

  add_index "csv_imports", ["user_id"], :name => "index_csv_imports_on_user_id"

  create_table "csv_rows", :force => true do |t|
    t.text     "values",                        :array => true
    t.integer  "csv_import_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "csv_rows", ["csv_import_id"], :name => "index_csv_rows_on_csv_import_id"

  create_table "geolocations", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.decimal  "latitude"
    t.decimal  "longitude"
  end

  create_table "import_mappings", :force => true do |t|
    t.string   "data_type"
    t.string   "column"
    t.integer  "csv_import_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "position"
  end

  add_index "import_mappings", ["csv_import_id"], :name => "index_import_mappings_on_csv_import_id"

  create_table "items", :force => true do |t|
    t.string   "title"
    t.string   "episode_title"
    t.string   "series_title"
    t.text     "description"
    t.string   "identifier"
    t.date     "date_broadcast"
    t.date     "date_created"
    t.string   "rights"
    t.string   "physical_format"
    t.string   "digital_format"
    t.string   "physical_location"
    t.string   "digital_location"
    t.integer  "duration"
    t.string   "music_sound_used"
    t.string   "date_peg"
    t.text     "notes"
    t.text     "transcription"
    t.string   "tags",                              :array => true
    t.integer  "geolocation_id"
    t.hstore   "extra"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "csv_import_id"
  end

  add_index "items", ["csv_import_id"], :name => "index_items_on_csv_import_id"
  add_index "items", ["geolocation_id"], :name => "index_items_on_geolocation_id"

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                         :default => "", :null => false
    t.string   "encrypted_password",            :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.integer  "default_public_collection_id"
    t.integer  "default_private_collection_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
