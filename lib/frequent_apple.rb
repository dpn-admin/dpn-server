Dir[File.dirname(__FILE__) + '/frequent_apple/**/*.rb'].each {|file| require file }

# An encapsulation of "client" functionality
module FrequentApple

  # Build and configure a client with appropriate headers.
  # The client will be configured to use the provided api_root when
  # supplied with relative urls.  When given full urls, it will follow
  # those.
  # @param api_root [String] A url of the target api_root.
  # @param auth_cred [String] Local node's auth credential for the given
  # api_root.
  # @return [HTTPClient]
  def self.client(api_root, auth_cred)
    base_header = {
        "Content-Type" => "application/json",
        "Authorization" => "Token #{auth_cred}"
    }
    client = HTTPClient.new( agent_name: self.name,  # the module's name
                             base_url: File.join(api_root, self.api_version),
                             default_header: base_header,
                             force_basic_auth: true)
    return client
  end


  # Given a list of records, find the most recent update time; examines
  # the :updated_at field.
  # @param records [Array<Hash>] The records
  # @param format [String] String of the format the dates are expected to be
  #   in.
  # @return [DateTime] A DateTime in the specified format.
  def self.last_update(records, format = Time::DATE_FORMATS[:dpn])
    newest = nil
    records.each do |record|
      record_time = DateTime.strptime(record[:updated_at], format)
      newest ||= record_time
      if record_time > newest
        newest = record_time
      end
    end
    return newest
  end


  def self.api_version
    return "api_v1"
  end


  # Construct an array that is not paged.  Uses a minimal set
  # of GET requests.
  # @param client [HTTPClient] The active HTTPClient client
  # @param url [String] The complete url to GET.
  # @param page_size [Fixnum] Size of pages to request.
  # @yield [results] A block to process the results on a page.
  # @yieldparam [Array<Hash>] records The records found on the page.
  def self.get_and_depaginate(client, url, page_size = Rails.configuration.default_per_page, &block)
    if url.include?("?")
      unless url.include?("page_size=")
        url += "&page_size=#{page_size}"
      end
      unless url.include?("page=")
        url += "&page=1"
      end
    else
      url += "?page_size=#{page_size}&page=1"
    end

    self.get_and_depaginate_helper(client, url, &block)
  end


  # Get the known nodes.
  # @param client [HTTPClient] The active HTTPClient client
  # @return [Array<Hash>] The array of nodes.
  def self.get_nodes(client)
    all_nodes = []
    self.get_and_depaginate(client, "/node") do |nodes|
      all_nodes += nodes
    end
    return all_nodes
  end


  protected
  # Construct an array that is not paged.  Uses a minimal set
  # of GET requests.
  # @param client [HTTPClient] The active HTTPClient client
  # @param page_url [String] The complete url to GET.
  # @yield [results] A block to process the results on a page.
  # @yieldparam [Array<Hash>] records The records found on the page.
  def self.get_and_depaginate_helper(client, page_url, &block)
    page = JSON.parse(client.get(page_url, follow_redirect: true).body, symbolize_names: true)
    yield page[:results] || []
    if page[:next] && page[:results].empty? == false
      next_page_url = page[:next]
      self.get_and_depaginate_helper(client, next_page_url, &block)
    end
  end

end