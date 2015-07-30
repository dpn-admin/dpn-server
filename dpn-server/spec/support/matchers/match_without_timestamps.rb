
RSpec::Matchers.define :match_without_timestamps do |expected|
  match do |actual|
    actual.reject! { |k,v| [:updated_at, :created_at].include? k }
    expected.reject! { |k,v| [:updated_at, :created_at].include? k }
    actual == expected
  end

  diffable
end