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

ActiveRecord::Schema.define(version: 20160811162500) do

  create_table "bag_man_requests", force: :cascade do |t|
    t.string   "source_location",                         null: false
    t.string   "preservation_location"
    t.integer  "last_step_completed",     default: 0
    t.string   "fixity"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "cancelled",               default: false
    t.integer  "replication_transfer_id"
    t.text     "cancel_reason"
    t.string   "unpacked_location"
    t.text     "last_error"
  end

  create_table "bags", force: :cascade do |t|
    t.string   "uuid"
    t.string   "local_id"
    t.integer  "size",              limit: 8
    t.integer  "version",                     null: false
    t.integer  "version_family_id",           null: false
    t.integer  "ingest_node_id",              null: false
    t.integer  "admin_node_id",               null: false
    t.string   "type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "member_id"
  end

  add_index "bags", ["uuid"], name: "index_bags_on_uuid", unique: true

  create_table "data_interpretive", force: :cascade do |t|
    t.integer "data_bag_id",         null: false
    t.integer "interpretive_bag_id", null: false
  end

  add_index "data_interpretive", ["data_bag_id", "interpretive_bag_id"], name: "index_data_interpretive_on_data_bag_id_and_interpretive_bag_id", unique: true

  create_table "data_rights", force: :cascade do |t|
    t.integer "data_bag_id",   null: false
    t.integer "rights_bag_id", null: false
  end

  add_index "data_rights", ["data_bag_id", "rights_bag_id"], name: "index_data_rights_on_data_bag_id_and_rights_bag_id", unique: true

  create_table "fixity_algs", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fixity_algs", ["name"], name: "index_fixity_algs_on_name", unique: true

  create_table "fixity_checks", force: :cascade do |t|
    t.string   "fixity_check_id", null: false
    t.integer  "bag_id",          null: false
    t.integer  "node_id",         null: false
    t.boolean  "success",         null: false
    t.datetime "fixity_at",       null: false
    t.datetime "created_at",      null: false
  end

  add_index "fixity_checks", ["fixity_check_id"], name: "index_fixity_checks_on_fixity_check_id", unique: true

  create_table "ingests", force: :cascade do |t|
    t.string   "ingest_id",  null: false
    t.integer  "bag_id",     null: false
    t.boolean  "ingested",   null: false
    t.datetime "created_at", null: false
  end

  add_index "ingests", ["ingest_id"], name: "index_ingests_on_ingest_id", unique: true

  create_table "members", force: :cascade do |t|
    t.string   "member_id",  null: false
    t.string   "name",       null: false
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "members", ["member_id"], name: "index_members_on_member_id", unique: true

  create_table "message_digests", force: :cascade do |t|
    t.integer  "bag_id",        null: false
    t.integer  "fixity_alg_id", null: false
    t.text     "value",         null: false
    t.integer  "node_id",       null: false
    t.datetime "created_at",    null: false
  end

  add_index "message_digests", ["bag_id", "fixity_alg_id"], name: "index_message_digests_on_bag_id_and_fixity_alg_id", unique: true

  create_table "nodes", force: :cascade do |t|
    t.string   "namespace",          null: false
    t.string   "name"
    t.string   "ssh_pubkey"
    t.integer  "storage_region_id",  null: false
    t.integer  "storage_type_id",    null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "api_root"
    t.string   "private_auth_token"
    t.string   "auth_credential"
  end

  add_index "nodes", ["api_root"], name: "index_nodes_on_api_root", unique: true
  add_index "nodes", ["namespace"], name: "index_nodes_on_namespace", unique: true
  add_index "nodes", ["private_auth_token"], name: "index_nodes_on_private_auth_token", unique: true

  create_table "nodes_ingests", force: :cascade do |t|
    t.integer "node_id",   null: false
    t.integer "ingest_id", null: false
  end

  add_index "nodes_ingests", ["node_id", "ingest_id"], name: "index_nodes_ingests_on_node_id_and_ingest_id", unique: true

  create_table "protocols", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "protocols", ["name"], name: "index_protocols_on_name", unique: true

  create_table "replicating_nodes", force: :cascade do |t|
    t.integer "node_id", null: false
    t.integer "bag_id",  null: false
  end

  add_index "replicating_nodes", ["node_id", "bag_id"], name: "index_replicating_nodes_on_node_id_and_bag_id", unique: true

  create_table "replication_agreements", force: :cascade do |t|
    t.integer  "from_node_id", null: false
    t.integer  "to_node_id",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "replication_transfers", force: :cascade do |t|
    t.integer  "bag_id",                          null: false
    t.integer  "from_node_id",                    null: false
    t.integer  "to_node_id",                      null: false
    t.integer  "protocol_id",                     null: false
    t.string   "link",                            null: false
    t.integer  "fixity_alg_id",                   null: false
    t.text     "fixity_nonce"
    t.string   "fixity_value"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "replication_id",                  null: false
    t.boolean  "store_requested", default: false, null: false
    t.boolean  "stored",          default: false, null: false
    t.boolean  "cancelled",       default: false, null: false
    t.text     "cancel_reason"
  end

  add_index "replication_transfers", ["replication_id"], name: "index_replication_transfers_on_replication_id", unique: true

  create_table "restore_agreements", force: :cascade do |t|
    t.integer  "from_node_id", null: false
    t.integer  "to_node_id",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "restore_transfers", force: :cascade do |t|
    t.integer  "bag_id",                        null: false
    t.integer  "from_node_id",                  null: false
    t.integer  "to_node_id",                    null: false
    t.integer  "protocol_id",                   null: false
    t.string   "link"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "restore_id",                    null: false
    t.boolean  "accepted",      default: false, null: false
    t.boolean  "finished",      default: false, null: false
    t.boolean  "cancelled",     default: false, null: false
    t.string   "cancel_reason"
  end

  add_index "restore_transfers", ["restore_id"], name: "index_restore_transfers_on_restore_id", unique: true

  create_table "run_times", force: :cascade do |t|
    t.string   "name",                                         null: false
    t.datetime "last_success", default: '1970-01-01 00:00:00', null: false
  end

  add_index "run_times", ["name"], name: "index_run_times_on_name", unique: true

  create_table "storage_regions", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "storage_regions", ["name"], name: "index_storage_regions_on_name", unique: true

  create_table "storage_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "storage_types", ["name"], name: "index_storage_types_on_name", unique: true

  create_table "supported_fixity_algs", force: :cascade do |t|
    t.integer "node_id",       null: false
    t.integer "fixity_alg_id", null: false
  end

  add_index "supported_fixity_algs", ["node_id", "fixity_alg_id"], name: "index_supported_fixity_algs_on_node_id_and_fixity_alg_id", unique: true

  create_table "supported_protocols", force: :cascade do |t|
    t.integer "node_id",     null: false
    t.integer "protocol_id", null: false
  end

  add_index "supported_protocols", ["node_id", "protocol_id"], name: "index_supported_protocols_on_node_id_and_protocol_id", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "",    null: false
    t.boolean  "admin",               default: false, null: false
    t.string   "encrypted_password",  default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "version_families", force: :cascade do |t|
    t.string "uuid", null: false
  end

  add_index "version_families", ["uuid"], name: "index_version_families_on_uuid", unique: true

end
