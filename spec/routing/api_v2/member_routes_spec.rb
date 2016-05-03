require "rails_helper"

describe "MemberRouting" do
  describe "api_v2" do
    let(:uuid) { SecureRandom.uuid }
    it "routes /api-v2/member/:uuid/bags to /bags/?member=:uuid" do
      expect(get: "/api-v2/member/#{uuid}/bags/").to route_to(
          controller: "api_v2/bags",
          member: uuid,
          action: "index"
        )
    end
  end

end