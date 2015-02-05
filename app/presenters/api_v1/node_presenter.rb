class ApiV1::NodePresenter
  def initialize(node)
    @node = node
    @hash = nil
  end

  def to_hash
    if @hash != nil
      return @hash
    end

    @hash = {
      :namespace  => @node.namespace,
      :name       => @node.name,
      :ssh_pubkey => @node.ssh_pubkey,
      :storage => {
        :region => StorageRegionPresenter.new(@node.storage_region).to_hash,
        :type   => StorageTypePresenter.new(@node.storage_type).to_hash
      },
      :created_at => @node.created_at,
      :updated_at => @node.updated_at
    }


  end

  def to_json
    return @hash.to_json
  end

  private
  attr_reader :node, :hash

end