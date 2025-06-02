# frozen_string_literal: true

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

ActiveRecord::Schema[8.0].define(version: 2025_06_02_221215) do
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

  create_table "membership_invitations", force: :cascade do |t|
    t.integer "membership_type", limit: 1, null: false
    t.boolean "visible", default: true, null: false
    t.string "email", null: false
    t.integer "organization_id", null: false
    t.integer "membership_id"
    t.integer "user_id"
    t.integer "sender_id"
    t.datetime "last_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_membership_invitations_on_email"
    t.index ["membership_id"], name: "index_membership_invitations_on_membership_id"
    t.index ["organization_id"], name: "index_membership_invitations_on_organization_id"
    t.index ["sender_id"], name: "index_membership_invitations_on_sender_id"
    t.index ["user_id"], name: "index_membership_invitations_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "state", limit: 2, null: false
    t.datetime "accepted_at"
    t.integer "membership_type", limit: 2, null: false
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "moderator_emergency_passkey_registrations", force: :cascade do |t|
    t.integer "moderator_id", null: false
    t.integer "moderator_passkey_id"
    t.integer "ip_address_id"
    t.integer "user_agent_id"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address_id"], name: "idx_on_ip_address_id_f229b147e9"
    t.index ["moderator_id"], name: "idx_on_moderator_id_0f6d1fe49a"
    t.index ["moderator_passkey_id"], name: "idx_on_moderator_passkey_id_38c1dc176e"
    t.index ["user_agent_id"], name: "idx_on_user_agent_id_9c77f3ea22"
  end

  create_table "moderator_passkeys", force: :cascade do |t|
    t.integer "moderator_id", null: false
    t.string "label", null: false
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.integer "sign_count"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_moderator_passkeys_on_external_id", unique: true
    t.index ["moderator_id"], name: "index_moderator_passkeys_on_moderator_id"
    t.index ["public_key"], name: "index_moderator_passkeys_on_public_key", unique: true
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

  create_table "organization_attachments", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.json "attachment_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_attachments_on_organization_id"
    t.index ["user_id"], name: "index_organization_attachments_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "membership_invitations", "memberships"
  add_foreign_key "membership_invitations", "organizations"
  add_foreign_key "membership_invitations", "users"
  add_foreign_key "membership_invitations", "users", column: "sender_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "moderator_emergency_passkey_registrations", "ip_addresses"
  add_foreign_key "moderator_emergency_passkey_registrations", "moderator_passkeys"
  add_foreign_key "moderator_emergency_passkey_registrations", "moderators"
  add_foreign_key "moderator_emergency_passkey_registrations", "user_agents"
  add_foreign_key "moderator_passkeys", "moderators"
  add_foreign_key "organization_attachments", "organizations"
  add_foreign_key "organization_attachments", "users"
  add_foreign_key "passkeys", "users"
end
