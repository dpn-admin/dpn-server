class StorageRegionPresenter
  def initialize(storage_region)
    @storage_region = storage_region
    @hash = nil
  end

  def to_hash
    if @hash != nil
      return @hash
    end

    @hash = {
      :name => @storage_region.name
    }


  end

  def to_json
    return @hash.to_json
  end

  private
  attr_reader :storage_region, :hash
end