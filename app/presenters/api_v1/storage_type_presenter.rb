class ApiV1::StorageTypePresenter
  def initialize(storage_type)
    @storage_region = storage_type
    @hash = nil
  end

  def to_hash
    if @hash != nil
      return @hash
    end

    @hash = {
      :name => @storage_type.name
    }


  end

  def to_json
    return @hash.to_json
  end

  private
  attr_reader :storage_type, :hash
end