# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_10_141537) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "district"
    t.string "number"
    t.string "complement"
    t.string "city"
    t.string "uf"
    t.string "zip_code"
    t.string "phone"
    t.string "cellphone"
    t.string "fax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "representative_id"
    t.index ["representative_id"], name: "index_addresses_on_representative_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.integer "branch_number"
    t.decimal "discount_request", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "representative_id"
    t.index ["representative_id"], name: "index_branches_on_representative_id"
  end

  create_table "closings", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "closing", limit: 20
    t.integer "last_envelope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
  end

  create_table "prescribers", force: :cascade do |t|
    t.string "name"
    t.string "council"
    t.decimal "partnership", default: "0.0"
    t.string "secretary"
    t.string "note"
    t.decimal "consider_discount_of_up_to", default: "0.0"
    t.decimal "percentage_ciscount", default: "0.0"
    t.decimal "repetitions", default: "0.0"
    t.boolean "allows_changes_values", default: false
    t.decimal "discount_value", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "representative_id"
    t.string "class_council", limit: 1
    t.string "number_council"
    t.string "uf_council", limit: 2
    t.date "birthdate"
    t.index ["representative_id"], name: "index_prescribers_on_representative_id"
  end

  create_table "representatives", force: :cascade do |t|
    t.string "name"
    t.decimal "partnership", default: "0.0"
    t.boolean "performs_closing", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "branch_id"
    t.index ["branch_id"], name: "index_representatives_on_branch_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "role"
    t.string "image"
    t.string "salt"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "representatives"
  add_foreign_key "branches", "representatives"
  add_foreign_key "prescribers", "representatives"
  add_foreign_key "representatives", "branches"
end
