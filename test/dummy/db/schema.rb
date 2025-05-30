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

ActiveRecord::Schema[8.0].define(version: 2025_05_30_130341) do
  create_table "emergency_passkey_registrations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "passkey_id"
    t.integer "ip_address_id"
    t.integer "user_agent_id"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address_id"], name: "index_emergency_passkey_registrations_on_ip_address_id"
    t.index ["passkey_id"], name: "index_emergency_passkey_registrations_on_passkey_id"
    t.index ["user_agent_id"], name: "index_emergency_passkey_registrations_on_user_agent_id"
    t.index ["user_id"], name: "index_emergency_passkey_registrations_on_user_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "ip_addresses", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_ip_addresses_on_address", unique: true
  end

  create_table "moderators", force: :cascade do |t|
    t.string "email", null: false
    t.string "webauthn_id", null: false
    t.datetime "remember_created_at"
    t.text "remember_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_moderators_on_email", unique: true
    t.index ["remember_token"], name: "index_moderators_on_remember_token", unique: true
  end

  create_table "passkeys", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "label", null: false
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.integer "sign_count"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_passkeys_on_external_id", unique: true
    t.index ["public_key"], name: "index_passkeys_on_public_key", unique: true
    t.index ["user_id"], name: "index_passkeys_on_user_id"
  end

  create_table "user_agents", force: :cascade do |t|
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_agent"], name: "index_user_agents_on_user_agent", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "webauthn_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remember_created_at"
    t.text "remember_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
  end

  add_foreign_key "emergency_passkey_registrations", "ip_addresses"
  add_foreign_key "emergency_passkey_registrations", "passkeys"
  add_foreign_key "emergency_passkey_registrations", "user_agents"
  add_foreign_key "emergency_passkey_registrations", "users"
  add_foreign_key "passkeys", "users"
end
