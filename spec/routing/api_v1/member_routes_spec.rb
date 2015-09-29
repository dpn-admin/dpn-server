require "rails_helper"

describe "MemberRouting" do
  describe "api_v1" do
    let(:uuid) { SecureRandom.uuid }
    it "routes /api-v1/member/:uuid/bags to /bags/?member=:uuid" do
      expect(get: "/api-v1/member/#{uuid}/bags/").to route_to(
          controller: "api_v1/bags",
          member: uuid,
          action: "index"
        )
    end
  end

end