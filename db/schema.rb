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

ActiveRecord::Schema.define(version: 20150327155207) do

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
  end

  add_index "bags", ["admin_node_id"], name: "fk_rails_7179128865", using: :btree
  add_index "bags", ["ingest_node_id"], name: "fk_rails_64c9acf17a", using: :btree
  add_index "bags", ["uuid"], name: "index_bags_on_uuid", unique: true, using: :btree
  add_index "bags", ["version_family_id"], name: "fk_rails_aa40652df0", using: :btree

  create_table "data_interpretive", force: :cascade do |t|
    t.integer  "data_bag_id",         limit: 4, null: false
    t.integer  "interpretive_bag_id", limit: 4, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "data_interpretive", ["data_bag_id", "interpretive_bag_id"], name: "index_data_interpretive_on_data_bag_id_and_interpretive_bag_id", unique: true, using: :btree
  add_index "data_interpretive", ["interpretive_bag_id"], name: "fk_rails_a7cf8eff35", using: :btree

  create_table "data_rights", force: :cascade do |t|
    t.integer  "data_bag_id",   limit: 4, null: false
    t.integer  "rights_bag_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "data_rights", ["data_bag_id", "rights_bag_id"], name: "index_data_rights_on_data_bag_id_and_rights_bag_id", unique: true, using: :btree
  add_index "data_rights", ["rights_bag_id"], name: "fk_rails_cb080c7f5e", using: :btree

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
  add_index "fixity_checks", ["fixity_alg_id"], name: "fk_rails_f056dbc9d8", using: :btree

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
  end

  add_index "nodes", ["api_root"], name: "index_nodes_on_api_root", unique: true, using: :btree
  add_index "nodes", ["namespace"], name: "index_nodes_on_namespace", unique: true, using: :btree
  add_index "nodes", ["private_auth_token"], name: "index_nodes_on_private_auth_token", unique: true, using: :btree
  add_index "nodes", ["storage_region_id"], name: "fk_rails_b56236bb81", using: :btree
  add_index "nodes", ["storage_type_id"], name: "fk_rails_9a883e466e", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "protocols", ["name"], name: "index_protocols_on_name", unique: true, using: :btree

  create_table "replicating_nodes", force: :cascade do |t|
    t.integer  "node_id",    limit: 4, null: false
    t.integer  "bag_id",     limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "replicating_nodes", ["bag_id"], name: "fk_rails_3f0b261344", using: :btree
  add_index "replicating_nodes", ["node_id", "bag_id"], name: "index_replicating_nodes_on_node_id_and_bag_id", unique: true, using: :btree

  create_table "replication_agreements", force: :cascade do |t|
    t.integer  "from_node_id", limit: 4, null: false
    t.integer  "to_node_id",   limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "replication_agreements", ["from_node_id"], name: "fk_rails_0af29abbf7", using: :btree
  add_index "replication_agreements", ["to_node_id"], name: "fk_rails_0bb46fb702", using: :btree

  create_table "replication_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "replication_statuses", ["name"], name: "index_replication_statuses_on_name", unique: true, using: :btree

  create_table "replication_transfers", force: :cascade do |t|
    t.integer  "bag_id",                limit: 4,     null: false
    t.integer  "from_node_id",          limit: 4,     null: false
    t.integer  "to_node_id",            limit: 4,     null: false
    t.integer  "replication_status_id", limit: 4,     null: false
    t.integer  "protocol_id",           limit: 4,     null: false
    t.string   "link",                  limit: 255,   null: false
    t.boolean  "bag_valid",             limit: 1
    t.integer  "fixity_alg_id",         limit: 4,     null: false
    t.text     "fixity_nonce",          limit: 65535
    t.string   "fixity_value",          limit: 255
    t.boolean  "fixity_accept",         limit: 1
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "replication_id",        limit: 255
  end

  add_index "replication_transfers", ["bag_id"], name: "fk_rails_2bc045c303", using: :btree
  add_index "replication_transfers", ["fixity_alg_id"], name: "fk_rails_3f99493f03", using: :btree
  add_index "replication_transfers", ["from_node_id"], name: "fk_rails_235ca00ae3", using: :btree
  add_index "replication_transfers", ["protocol_id"], name: "fk_rails_87983c3d6c", using: :btree
  add_index "replication_transfers", ["replication_id"], name: "index_replication_transfers_on_replication_id", unique: true, using: :btree
  add_index "replication_transfers", ["replication_status_id"], name: "fk_rails_1cd29f9eee", using: :btree
  add_index "replication_transfers", ["to_node_id"], name: "fk_rails_e0944bdfbd", using: :btree

  create_table "restore_agreements", force: :cascade do |t|
    t.integer  "from_node_id", limit: 4, null: false
    t.integer  "to_node_id",   limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "restore_agreements", ["from_node_id"], name: "fk_rails_0c14c6a32e", using: :btree
  add_index "restore_agreements", ["to_node_id"], name: "fk_rails_6eae78af09", using: :btree

  create_table "restore_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "restore_statuses", ["name"], name: "index_restore_statuses_on_name", unique: true, using: :btree

  create_table "restore_transfers", force: :cascade do |t|
    t.integer  "bag_id",            limit: 4,   null: false
    t.integer  "from_node_id",      limit: 4,   null: false
    t.integer  "to_node_id",        limit: 4,   null: false
    t.integer  "restore_status_id", limit: 4,   null: false
    t.integer  "protocol_id",       limit: 4,   null: false
    t.string   "link",              limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "restore_id",        limit: 255
  end

  add_index "restore_transfers", ["bag_id"], name: "fk_rails_bf5ff4508e", using: :btree
  add_index "restore_transfers", ["from_node_id"], name: "fk_rails_25d9f72fc4", using: :btree
  add_index "restore_transfers", ["protocol_id"], name: "fk_rails_f77781df6e", using: :btree
  add_index "restore_transfers", ["restore_id"], name: "index_restore_transfers_on_restore_id", unique: true, using: :btree
  add_index "restore_transfers", ["restore_status_id"], name: "fk_rails_93c485b021", using: :btree
  add_index "restore_transfers", ["to_node_id"], name: "fk_rails_4121d8ca3b", using: :btree

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

  add_index "supported_fixity_algs", ["fixity_alg_id"], name: "fk_rails_3566a4ca25", using: :btree
  add_index "supported_fixity_algs", ["node_id", "fixity_alg_id"], name: "index_supported_fixity_algs_on_node_id_and_fixity_alg_id", unique: true, using: :btree

  create_table "supported_protocols", force: :cascade do |t|
    t.integer "node_id",     limit: 4, null: false
    t.integer "protocol_id", limit: 4, null: false
  end

  add_index "supported_protocols", ["node_id", "protocol_id"], name: "index_supported_protocols_on_node_id_and_protocol_id", unique: true, using: :btree
  add_index "supported_protocols", ["protocol_id"], name: "fk_rails_ca0de226da", using: :btree

  create_table "version_families", force: :cascade do |t|
    t.string "uuid", limit: 255, null: false
  end

  add_index "version_families", ["uuid"], name: "index_version_families_on_uuid", unique: true, using: :btree

  add_foreign_key "bags", "nodes", column: "admin_node_id", on_update: :cascade
  add_foreign_key "bags", "nodes", column: "ingest_node_id", on_update: :cascade
  add_foreign_key "bags", "version_families"
  add_foreign_key "data_interpretive", "bags", column: "data_bag_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "data_interpretive", "bags", column: "interpretive_bag_id", on_update: :cascade
  add_foreign_key "data_rights", "bags", column: "data_bag_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "data_rights", "bags", column: "rights_bag_id", on_update: :cascade
  add_foreign_key "fixity_checks", "bags", on_update: :cascade
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
  add_foreign_key "replication_transfers", "replication_statuses", on_update: :cascade
  add_foreign_key "restore_agreements", "nodes", column: "from_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_agreements", "nodes", column: "to_node_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_transfers", "bags", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restore_transfers", "nodes", column: "from_node_id", on_update: :cascade
  add_foreign_key "restore_transfers", "nodes", column: "to_node_id", on_update: :cascade
  add_foreign_key "restore_transfers", "protocols", on_update: :cascade
  add_foreign_key "restore_transfers", "restore_statuses", on_update: :cascade
  add_foreign_key "supported_fixity_algs", "fixity_algs", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_fixity_algs", "nodes", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_protocols", "nodes", on_update: :cascade, on_delete: :cascade
  add_foreign_key "supported_protocols", "protocols", on_update: :cascade
end
