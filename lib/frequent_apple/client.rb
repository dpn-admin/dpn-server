require "httpclient"

module FrequentApple


  class Client
    def initialize(api_root, auth_cred)
      base_header = {
          "Content-Type" => "application/json",
          "Authorization" => "Token #{auth_cred}"
      }
      @client = HTTPClient.new( agent_name: FrequentApple.name,  # the module's name
                               base_url: File.join(api_root, FrequentApple.api_version),
                               default_header: base_header,
                               force_basic_auth: true)
    end

    def get(url)
      @client.get(fix_url(url), follow_redirect: true)
    end

    def post(url, body)
      @client.post(fix_url(url), body, follow_redirect: true)
    end

    def put(url, body)
      # By default, HTTPClient doesn't let us tell it to
      # follow redirects for puts.  The following is a hack
      # to ensure that the follow_redirect option sticks around
      # past the @client.put call.
      args = {
          query: nil,
          body: body,
          header: nil,
          follow_redirect: true
      }
      @client.put(fix_url(url), args)
    end

    def delete(url)
      # Same issue as put.
      args = {
          query: nil,
          body: nil,
          header: nil,
          follow_redirect: true
      }
      @client.delete(fix_url(url), args)
    end

    private
    def fix_url(url)
      array_url = url.split("?", 2)
      array_url[0] = File.join(array_url[0], "/")
      return array_url.join("?")
    end
  end


end