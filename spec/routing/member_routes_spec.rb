require "rails_helper"

describe "MemberRouting" do
  api_stanza = "api-v#{VERSION}"
  describe api_stanza do
    let(:uuid) { SecureRandom.uuid }
    it "routes /#{api_stanza}/member/:uuid/bags to /bags/?member=:uuid" do
      expect(get: "/#{api_stanza}/member/#{uuid}/bags/").to route_to(
        controller: "bags", # this fails if we use a symbol
        member: uuid,
        action: "index"
      )
    end
  end

end

