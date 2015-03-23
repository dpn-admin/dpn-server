
module ApiV1
  class BagPresenter
    def initialize(bag)
      @bag = bag
    end

    def to_hash
      hash = {
        :uuid => @bag.uuid,
        :local_id => @bag.local_id,
        :size => @bag.size,
        :first_version_uuid => @bag.version_family.uuid,
        :version => @bag.version,
        :ingest_node => @bag.ingest_node.namespace,
        :admin_node => @bag.admin_node.namespace,
        :replicating_nodes => @bag.replicating_nodes.pluck(:namespace),
        :fixities => {},
        :created_at => @bag.created_at.to_formatted_s(:dpn),
        :updated_at => @bag.updated_at.to_formatted_s(:dpn)
      }

      @bag.fixity_checks.each do |check|
        hash[:fixities][check.fixity_alg.name.to_sym] = check.value
      end

      case @bag.type
      when "DataBag"
        hash[:bag_type] = "D"
        hash[:rights] = @bag.rights_bags.pluck(:uuid)
        hash[:interpretive] = @bag.interpretive_bags.pluck(:uuid)
      when "RightsBag"
        hash[:bag_type] = "R"
        hash[:rights] = nil
        hash[:interpretive] = nil
      when "InterpretiveBag"
        hash[:bag_type] = "I"
        hash[:rights] = nil
        hash[:interpretive] = nil
      else
        throw TypeError, "illegal bag type #{@bag.type}"
      end

      return hash
    end

    def to_json(options = {})
      return self.to_hash.to_json
    end

    private
    attr_reader :bag
  end
end
