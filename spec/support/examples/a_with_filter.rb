# @param field_name [Symbol] field name to test, without "with_"
# @param field_factory [Symbol] factory of the class the scope pertains to
shared_examples "a 'with' filter" do
  factory = described_class.to_s.underscore.to_sym
  let!(:record) { Fabricate(factory) }
  let!(:other_record) { Fabricate(factory) }
  let(:scope_name) { :"with_#{field_name}" }
  it "includes matching only" do
    expect(described_class.public_send(scope_name, record.public_send(field_name)))
      .to match_array [record]
  end
  it "does not filter given anew record" do
    expect(described_class.public_send(scope_name, Fabricate.build(field_factory)))
      .to contain_exactly(record, other_record)
  end
end