module ViewHelper
  def single_object(object)
    adapter.from_model(object).to_public_hash
  end

  def paged_collection(collection, page_size)
    {
      count:    collection.total_count,
      next:     next_page(collection.current_page, collection.total_pages, page_size),
      previous: previous_page(collection.current_page, page_size),
      results:  collection.map{|item| single_object(item)}
    }
  end
end