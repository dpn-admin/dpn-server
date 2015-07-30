class AddForeignKeys < ActiveRecord::Migration
  def change

    add_foreign_key :bags, :version_families,
        column: :version_family_id,
        on_delete: :restrict,
        on_update: :restrict

    add_foreign_key :bags, :nodes,
        column: :ingest_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :bags, :nodes,
        column: :admin_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :data_interpretive, :bags,
        column: :data_bag_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :data_interpretive, :bags,
        column: :interpretive_bag_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :data_rights, :bags,
        column: :data_bag_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :data_rights, :bags,
        column: :rights_bag_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :fixity_checks, :bags,
        column: :bag_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :fixity_checks, :fixity_algs,
        column: :fixity_alg_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :nodes, :storage_regions,
        column: :storage_region_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :nodes, :storage_types,
        column: :storage_type_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :replicating_nodes, :nodes,
        column: :node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :replicating_nodes, :bags,
        column: :bag_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :replication_agreements, :nodes,
        column: :from_node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :replication_agreements, :nodes,
        column: :to_node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :replication_transfers, :bags,
        column: :bag_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :replication_transfers, :nodes,
        column: :from_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :replication_transfers, :nodes,
        column: :to_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :replication_transfers, :replication_statuses,
        column: :replication_status_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :replication_transfers, :protocols,
        column: :protocol_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :replication_transfers, :fixity_algs,
        column: :fixity_alg_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :restore_agreements, :nodes,
        column: :from_node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :restore_agreements, :nodes,
        column: :to_node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :restore_transfers, :bags,
        column: :bag_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :restore_transfers, :nodes,
        column: :from_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :restore_transfers, :nodes,
        column: :to_node_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :restore_transfers, :restore_statuses,
        column: :restore_status_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :restore_transfers, :protocols,
        column: :protocol_id,
        on_delete: :restrict,
        on_update: :cascade

    add_foreign_key :supported_fixity_algs, :nodes,
        column: :node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :supported_fixity_algs, :fixity_algs,
        column: :fixity_alg_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :supported_protocols, :nodes,
        column: :node_id,
        on_delete: :cascade,
        on_update: :cascade

    add_foreign_key :supported_protocols, :protocols,
        column: :protocol_id,
        on_delete: :restrict,
        on_update: :cascade

  end
end
