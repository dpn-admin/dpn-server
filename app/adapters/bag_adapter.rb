# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagAdapter < ::AbstractAdapter

  map_simple :uuid, :uuid
  map_simple :local_id, :local_id
  map_simple :size, :size
  map_simple :version, :version

  map_belongs_to :ingest_node, :ingest_node, model_class: Node, sub_method: :namespace
  map_belongs_to :admin_node, :admin_node, model_class: Node, sub_method: :namespace
  map_belongs_to :member, :member, sub_method: :uuid

  map_has_many :interpretive_bags, :interpretive, sub_method: :uuid
  map_has_many :rights_bags, :rights, sub_method: :uuid
  map_has_many :replicating_nodes, :replicating_nodes, model_class: Node, sub_method: :namespace

  map_from_public :bag_type do |typechar|
    {type: model_bag_type(typechar)}
  end
  map_to_public :type do |typestring|
    {bag_type: typestring.to_s[0]}
  end

  map_to_public :version_family do |record|
    {first_version_uuid: record ? record.uuid : nil}
  end
  map_from_public :first_version_uuid do |uuid|
    {version_family: VersionFamily.find_or_initialize_by(uuid: uuid)}
  end

  map_from_public :fixities do |public_fixities|
    fixity_checks = []
    if public_fixities.respond_to? :keys
      public_fixities.keys.each do |public_fixity_alg|
        fixity_checks << FixityCheck.find_or_initialize_by(
          fixity_alg: FixityAlg.find_by_name(public_fixity_alg),
          value: public_fixities[public_fixity_alg]
        )
      end
    end
    {fixity_checks: fixity_checks}
  end
  map_to_public :fixity_checks do |fixity_checks|
    public_fixities = {}
    fixity_checks.each do |fc|
      public_fixities[fc.fixity_alg.name.to_sym] = fc.value
    end
    {fixities: public_fixities}
  end




  private

  @@bag_types = {
    d: "DataBag",
    r: "RightsBag",
    i: "InterpretiveBag"
  }

  def self.model_bag_type(public_type)
    if public_type.is_a? String
      return @@bag_types[public_type.downcase.to_sym]
    else
      return nil
    end
  end

end
