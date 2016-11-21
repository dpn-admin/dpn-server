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

ActiveRecord::Schema.define(version: 20151215211317) do

  create_table "bag_man_requests", force: :cascade do |t|
    t.string   "source_location",         limit: 255,                 null: false
    t.string   "preservation_location",   limit: 255
    t.integer  "status",                  limit: 4,   default: 0
    t.string   "fixity",                  limit: 255
    t.boolean  "validity"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "cancelled",                           default: false
    t.integer  "replication_transfer_id", limit: 4
  end

  add_index "bag_man_requests", ["replication_transfer_id"], name: "fk_rails_5435800328", using: :btree

  create_table "bags", force: :cascade do |t|
    t.string   "uuid",              limit: 255
    t.string   "local_id",          limit: 255
    t.integer  "size",              limit: 8
    t.integer  "version",           limit: 4,   null: false
    t.integer  "version_family_id", limit: 4,   null: false
    t.integer  "ingest_node_id",    limit: 4,   null: false
    t.integer  "admin_node_id",     limit: 4,   null: false
    t.string   "type",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "member_id",         limit: 4
  end

  add_index "bags", ["admin_node_id"], name: "fk_rails_d0674264a5", using: :btree
  add_index "bags", ["ingest_node_id"], name: "fk_rails_795fef728d", using: :btree
  add_index "bags", ["member_id"], name: "fk_rails_6fea84f9e1", using: :btree
  add_index "bags", ["uuid"], name: "index_bags_on_uuid", unique: true, using: :btree
  add_index "bags", ["version_family_id"], name: "fk_rails_d89749b6c0", using: :btree

  create_table "data_interpretive", force: :cascade do |t|
    t.integer "data_bag_id",         limit: 4, null: false
    t.integer "interpretive_bag_id", limit: 4, null: false
  end

  add_index "data_interpretive", ["data_bag_id", "interpretive_bag_id"], name: "index_data_interpretive_on_data_bag_id_and_interpretive_bag_id", unique: true, using: :btree
  add_index "data_interpretive", ["interpretive_bag_id"], name: "fk_rails_85a17aa1b6", using: :btree

  create_table "data_rights", force: :cascade do |t|
    t.integer "data_bag_id",   limit: 4, null: false
    t.integer "rights_bag_id", limit: 4, null: false
  end

  add_index "data_rights", ["data_bag_id", "rights_bag_id"], name: "index_data_rights_on_data_bag_id_and_rights_bag_id", unique: true, using: :btree
  add_index "data_rights", ["rights_bag_id"], name: "fk_rails_47a0c95df2", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "fixity_algs", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "fixity_algs", ["name"], name: "index_fixity_algs_on_name", unique: true, using: :btree

  create_table "fixity_checks", force: :cascade do |t|
    t.integer "bag_id",        limit: 4,     null: false
    t.integer "fixity_alg_id", limit: 4,     null: false
    t.text    "value",         limit: 65535, null: false
  end

  add_index "fixity_checks", ["bag_id", "fixity_alg_id"], name: "index_fixity_checks_on_bag_id_and_fixity_alg_id", unique: true, using: :btree
  add_index "fixity_checks", ["fixity_alg_id"], name: "fk_rails_592f5598b9", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "uuid",       limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "members", ["uuid"], name: "index_members_on_uuid", unique: true, using: :btree

  create_table "nodes", force: :cascade do |t|
    t.string   "namespace",          limit: 255, null: false
    t.string   "name",               limit: 255
    t.string   "ssh_pubkey",         limit: 255
    t.integer  "storage_region_id",  limit: 4,   null: false
    t.integer  "storage_type_id",    limit: 4,   null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "api_root",           limit: 255
    t.string   "private_auth_token", limit: 255
    t.string   "auth_credential",    limit: 255
  end

  add_index "nodes", ["api_root"], name: "index_nodes_on_api_root", unique: true, using: :btree
  add_index "nodes", ["namespace"], name: "index_nodes_on_namespace", unique: true, using: :btree
  add_index "nodes", ["private_auth_token"], name: "index_nodes_on_private_auth_token", unique: true, using: :btree
  add_index "nodes", ["storage_region_id"], name: "fk_rails_1fe628e40f", using: :btree
  add_index "nodes", ["storage_type_id"], name: "fk_rails_05a92ea279", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "protocols", ["name"], name: "index_protocols_on_name", unique: true, using: :btree

  create_table "replicating_nodes", force: :cascade do |t|
    t.integer "node_id", limit: 4, null: false
    t.integer "bag_id",  limit: 4, null: false
  end

  add_index "replicating_nodes", ["bag_id"], name: "fk_rails_95171b0178", using: :btree
  add_index "replicating_nodes", ["node_id", "bag_id"], name: "index_replicating_nodes_on_node_id_and_bag_id", unique: true, using: :btree

  create_table "replication_agreements", force: :cascade do |t|
    t.integer  "from_node_id", limit: 4, null: false
    t.integer  "to_node_id",   limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "replication_agreements", ["from_node_id"], name: "fk_rails_ab8b5501fe", using: :btree
  add_index "replication_agreements", ["to_node_id"], name: "fk_rails_c759f01ad8", using: :btree

  create_table "replication_transfers", force: :cascade do |t|
    t.integer  "bag_id",         limit: 4,                 null: false
    t.integer  "from_node_id",   limit: 4,                 null: false
    t.integer  "to_node_id",     limit: 4,                 null: false
    t.integer  "protocol_id",    limit: 4,                 null: false
    t.string   "link",           limit: 255,               null: false
    t.boolean  "bag_valid"
    t.integer  "fixity_alg_id",  limit: 4,                 null: false
    t.text     "fixity_nonce",   limit: 65535
    t.string   "fixity_value",   limit: 255
    t.boolean  "fixity_accept"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "replication_id", limit: 255
    t.integer  "status",         limit: 4,     default: 0, null: false
  end

  add_index "replication_transfers", ["bag_id"], name: "fk_rails_48eccb8bbb", using: :btree
  add_index "replication_transfers", ["fixity_alg_id"], name: "fk_rails_050d348534", using: :btree
  add_index "replication_transfers", ["from_node_id"], name: "fk_rails_c6e2144b67", using: :btree
  add_index "replication_transfers", ["protocol_id"], name: "fk_rails_df8a843188", using: :btree
  add_index "replication_transfers", ["replication_id"], name: "index_replication_transfers_on_replication_id", unique: true, using: :btree
  add_index "replication_transfers", ["to_node_id"], name: "fk_rails_8c50f0bbfb", using: :btree

  create_table "restore_agreements", force: :cascade do |t|
    t.integer  "from_node_id", limit: 4, null: false
    t.integer  "to_node_id",   limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "restore_agreements", ["from_node_id"], name: "fk_rails_8986b1be73", using: :btree
  add_index "restore_agreements", ["to_node_id"], name: "fk_rails_267791e259", using: :btree

  create_table "restore_transfers", force: :cascade do |t|
    t.integer  "bag_id",       limit: 4,               null: false
    t.integer  "from_node_id", limit: 4,               null: false
    t.integer  "to_node_id",   limit: 4,               null: false
    t.integer  "protocol_id",  limit: 4,               null: false
    t.string   "link",         limit: 255,             null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "restore_id",   limit: 255
    t.integer  "status",       limit: 4,   default: 0, null: false
  end

  add_index "restore_transfers", ["bag_id"], name: "fk_rails_38da897ad9", using: :btree
  add_index "restore_transfers", ["from_node_id"], name: "fk_rails_299b60791e", using: :btree
  add_index "restore_transfers", ["protocol_id"], name: "fk_rails_e2cdff6b5c", using: :btree
  add_index "restore_transfers", ["restore_id"], name: "index_restore_transfers_on_restore_id", unique: true, using: :btree
  add_index "restore_transfers", ["to_node_id"], name: "fk_rails_fbf87e73d8", using: :btree

  create_table "storage_regions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "storage_regions", ["name"], name: "index_storage_regions_on_name", unique: true, using: :btree

  create_table "storage_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "storage_types", ["name"], name: "index_storage_types_on_name", unique: true, using: :btree

  create_table "supported_fixity_algs", force: :cascade do |t|
    t.integer "node_id",       limit: 4, null: false
    t.integer "fixity_alg_id", limit: 4, null: false
  end

  add_index "supported_fixity_algs", ["fixity_alg_id"], name: "fk_rails_39e9299717", using: :btree
  add_index "supported_fixity_algs", ["node_id", "fixity_alg_id"], name: "index_supported_fixity_algs_on_node_id_and_fixity_alg_id", unique: true, using: :btree

  create_table "supported_protocols", force: :cascade do |t|
    t.integer "node_id",     limit: 4, null: false
    t.integer "protocol_id", limit: 4, null: false
  end

  add_index "supported_protocols", ["node_id", "protocol_id"], name: "index_supported_protocols_on_node_id_and_protocol_id", unique: true, using: :btree
  add_index "supported_protocols", ["protocol_id"], name: "fk_rails_f09b486eb9", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255, default: "",    null: false
    t.boolean  "admin",                           default: false, null: false
    t.string   "encrypted_password",  limit: 255, default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "version_families", force: :cascade do |t|
    t.string "uuid", limit: 255, null: false
  end

  add_index "version_families", ["uuid"], name: "index_version_families_on_uuid", unique: true, using: :btree

  add_foreign_key "bag_man_requests", "replication_transfers", on_update: :cascade, on_delete: :cascade
  add_foreign_key "bags", "members", on_update: :cascade
  add_foreign_key "bags", "nodes", column: "admin_node_id", on_update: :cascade
  add_foreign_key "bags", "nodes", column: "ingest_node_id", on_update: :cascade
  add_foreign_key "bags", "version_families"
  add_foreign_key "data_interpretive", "bags", column: "data_bag_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "data_interpretive", "bags", column: "interpretive_bag_id", on_update: :cascade
  add_foreign_key "data_rights", "bags", column: "data_bag_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "data_rights", "bags", column: "rights_bag_id", on_update: :cascade
  add_foreign_key "fixity_checks", "bags", on_update: :cascade, on_delete: :cascade
  add_foreign_key "fixity_checks", "fixity_algs", on_update: :cascade, on_delete: :cascade
  add_foreign_key "nodes", "storage_regions", on_update: :cascade
  add_foreign_key "nodes", "storage_types", on_update: :cascade
  add_foreign_key "replicating_nodes", "bags", on_update: :cascade, on_delete: :cascade
  add_foreign_key "replicating_nodes", "nodes", on_update: :cascade, on_delete: :cascade
  add_foreign_key "replication_agreements", "nodes", column: "from_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "replication_agreements", "nodes", column: "to_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "replication_transfers", "bags", on_update: :cascade, on_delete: :cascade
  add_foreign_key "replication_transfers", "fixity_algs", on_update: :cascade
  add_foreign_key "replication_transfers", "nodes", column: "from_node_id", on_update: :cascade
  add_foreign_key "replication_transfers", "nodes", column: "to_node_id", on_update: :cascade
  add_foreign_key "replication_transfers", "protocols", on_update: :cascade
  add_foreign_key "restore_agreements", "nodes", column: "from_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_agreements", "nodes", column: "to_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_transfers", "bags", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_transfers", "nodes", column: "from_node_id", on_update: :cascade
  add_foreign_key "restore_transfers", "nodes", column: "to_node_id", on_update: :cascade
  add_foreign_key "restore_transfers", "protocols", on_update: :cascade
  add_foreign_key "supported_fixity_algs", "fixity_algs", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_fixity_algs", "nodes", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_protocols", "nodes", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_protocols", "protocols", on_update: :cascade
end
