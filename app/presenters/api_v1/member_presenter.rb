# Copyright

module ApiV1
  class MemberPresenter
    def initialize(member)
      @member = member
    end

    def to_hash
      hash = {
        :uuid => @member.uuid,
        :name => @member.name,
        :email => @member.email
      }

      return hash
    end

    def to_json(options = {})
      return self.to_hash.to_json(options)
    end
    
    private
    attr_reader :member
  end
end
