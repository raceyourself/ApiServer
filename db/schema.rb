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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140529133638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analytics_queries", id: false, force: true do |t|
    t.string   "id",         null: false
    t.text     "sql",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "analytics_views", id: false, force: true do |t|
    t.string   "id",         null: false
    t.text     "script",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.text     "provider_data"
    t.string   "email"
    t.string   "token"
    t.string   "token_secret"
    t.boolean  "token_expires"
    t.datetime "token_expires_at"
    t.string   "refresh_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permissions"
  end

  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", unique: true, using: :btree

  create_table "challenge_attempts", id: false, force: true do |t|
    t.integer "challenge_id", null: false
    t.integer "device_id",    null: false
    t.integer "track_id",     null: false
  end

  create_table "challenge_subscribers", id: false, force: true do |t|
    t.integer "challenge_id",                 null: false
    t.integer "user_id",                      null: false
    t.boolean "accepted",     default: false
  end

  create_table "challenges", force: true do |t|
    t.datetime "start_time"
    t.datetime "stop_time"
    t.boolean  "public",         default: false
    t.integer  "creator_id"
    t.string   "type"
    t.integer  "distance"
    t.integer  "time"
    t.integer  "duration"
    t.integer  "pace"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "name"
    t.text     "description"
    t.integer  "points_awarded", default: 0,     null: false
    t.string   "prize"
  end

  create_table "configurations", force: true do |t|
    t.string   "type",          null: false
    t.json     "configuration", null: false
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "devices", force: true do |t|
    t.string   "manufacturer",     null: false
    t.string   "model",            null: false
    t.string   "glassfit_version", null: false
    t.string   "push_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.integer  "ts",         limit: 8, null: false
    t.integer  "version",              null: false
    t.integer  "device_id",            null: false
    t.integer  "session_id",           null: false
    t.integer  "user_id",              null: false
    t.json     "data",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", id: false, force: true do |t|
    t.string   "identity_type", null: false
    t.string   "identity_uid",  null: false
    t.string   "friend_type",   null: false
    t.string   "friend_uid",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "game_states", force: true do |t|
    t.boolean  "locked"
    t.boolean  "enabled"
    t.string   "game_id",    null: false
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_states", ["game_id"], name: "index_game_states_on_game_id", using: :btree

  create_table "games", id: false, force: true do |t|
    t.string   "id",              null: false
    t.string   "name",            null: false
    t.string   "description",     null: false
    t.integer  "tier",            null: false
    t.integer  "price_in_points", null: false
    t.integer  "price_in_gems",   null: false
    t.string   "scene_name",      null: false
    t.string   "type",            null: false
    t.datetime "deleted_at"
    t.string   "activity"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", id: false, force: true do |t|
    t.integer "user_id",  null: false
    t.integer "group_id", null: false
  end

  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id", "group_id"], name: "index_groups_users_on_user_id_and_group_id", using: :btree

  create_table "identities", id: false, force: true do |t|
    t.integer  "user_id"
    t.boolean  "has_glass",    default: false
    t.string   "type",                                         null: false
    t.string   "uid",                                          null: false
    t.string   "name"
    t.string   "photo"
    t.string   "screen_name"
    t.datetime "refreshed_at", default: '1970-01-01 00:00:00', null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "invites", id: false, force: true do |t|
    t.string   "code",          null: false
    t.datetime "expires_at"
    t.datetime "used_at"
    t.integer  "user_id"
    t.string   "identity_type"
    t.string   "identity_uid"
  end

  add_index "invites", ["identity_type", "identity_uid"], name: "index_invites_on_identity_type_and_identity_uid", using: :btree

  create_table "matched_tracks", id: false, force: true do |t|
    t.integer "user_id",   null: false
    t.integer "device_id", null: false
    t.integer "track_id",  null: false
  end

  create_table "menu_items", force: true do |t|
    t.string  "icon",    null: false
    t.integer "column",  null: false
    t.integer "row",     null: false
    t.string  "game_id", null: false
  end

  add_index "menu_items", ["game_id"], name: "index_menu_items_on_game_id", using: :btree

  create_table "notifications", force: true do |t|
    t.boolean  "read",       default: false, null: false
    t.json     "message",                    null: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.string   "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.string   "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "positions", id: false, force: true do |t|
    t.integer  "device_id",                                null: false
    t.integer  "position_id",                              null: false
    t.integer  "track_id",                                 null: false
    t.integer  "state_id",                                 null: false
    t.integer  "gps_ts",                         limit: 8, null: false
    t.integer  "device_ts",                      limit: 8, null: false
    t.float    "lng",                                      null: false
    t.float    "lat",                                      null: false
    t.float    "alt",                                      null: false
    t.float    "bearing",                                  null: false
    t.float    "corrected_bearing"
    t.float    "corrected_bearing_R"
    t.float    "corrected_bearing_significance"
    t.float    "speed"
    t.float    "epe"
    t.string   "nmea"
    t.integer  "user_id",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "positions", ["device_id", "track_id"], name: "index_positions_on_device_id_and_track_id", using: :btree
  add_index "positions", ["user_id"], name: "index_positions_on_user_id", using: :btree

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree

  create_table "survey_beta_insights", force: true do |t|
    t.integer  "response_id"
    t.datetime "time_started"
    t.datetime "time_submitted"
    t.string   "status"
    t.text     "contact_id"
    t.text     "legacy_comments"
    t.text     "comments"
    t.text     "language"
    t.text     "referrer"
    t.text     "extended_referrer"
    t.text     "session_id"
    t.text     "user_agent"
    t.text     "extended_user_agent"
    t.string   "ip_address"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "country_auto"
    t.string   "city"
    t.string   "region"
    t.string   "post_code"
    t.string   "mobile_device_1"
    t.string   "mobile_device_2"
    t.string   "wearable_glass"
    t.string   "wearable_other_title"
    t.string   "wearable_other"
    t.string   "running_fitness"
    t.string   "cycling_fitness"
    t.string   "workout_fitness"
    t.string   "goal_faster"
    t.string   "goal_further"
    t.string   "goal_slimmer"
    t.string   "goal_stronger"
    t.string   "goal_happier"
    t.string   "goal_live_longer"
    t.string   "goal_manage_condition"
    t.string   "goal_other_title"
    t.string   "goal_other"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "url"
    t.string   "gender"
    t.string   "age_group"
    t.string   "country_as_entered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cohort"
  end

  create_table "tracks", id: false, force: true do |t|
    t.integer  "device_id",                               null: false
    t.integer  "track_id",                                null: false
    t.string   "track_name"
    t.integer  "ts",            limit: 8,                 null: false
    t.boolean  "public",                  default: false
    t.float    "distance"
    t.integer  "time"
    t.integer  "user_id",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "track_type_id",           default: 1,     null: false
  end

  add_index "tracks", ["user_id"], name: "index_tracks_on_user_id", using: :btree

  create_table "transactions", id: false, force: true do |t|
    t.integer  "device_id",                                  null: false
    t.integer  "transaction_id",                             null: false
    t.integer  "ts",                 limit: 8,               null: false
    t.string   "transaction_type",                           null: false
    t.string   "transaction_calc",                           null: false
    t.string   "source_id",                                  null: false
    t.integer  "points_delta",                 default: 0,   null: false
    t.integer  "points_balance",               default: 0,   null: false
    t.integer  "gems_delta",                   default: 0,   null: false
    t.integer  "gems_balance",                 default: 0,   null: false
    t.float    "metabolism_delta",             default: 0.0, null: false
    t.float    "metabolism_balance",           default: 0.0, null: false
    t.float    "cash_delta",                   default: 0.0, null: false
    t.string   "currency"
    t.integer  "user_id",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "transactions", ["ts"], name: "index_transactions_on_ts", using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",                         default: "",    null: false
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                  default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "token"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                            default: false, null: false
    t.integer  "sync_key",                         default: 0,     null: false
    t.datetime "sync_timestamp"
    t.string   "gender",                 limit: 1
    t.integer  "invites",                          default: 0
    t.json     "profile",                          default: "{}"
    t.text     "image"
    t.integer  "timezone"
    t.string   "cohort"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["sync_key"], name: "index_users_on_sync_key", using: :btree
  add_index "users", ["token"], name: "index_users_on_token", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
