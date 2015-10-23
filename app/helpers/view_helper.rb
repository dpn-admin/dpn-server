module ViewHelper
  def single_object(object)
    adapter.from_model(object).to_public_hash
  end
end