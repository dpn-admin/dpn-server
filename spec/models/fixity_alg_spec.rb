require 'rails_helper'

describe FixityAlg do
  it 'has a valid factory' do
    expect(create(:fixity_alg)).to be_valid
  end

  it 'is invalid without a name' do
    expect {
      create(:fixity_alg, name: nil)
    }.to raise_error
  end

  it 'can find records' do
    name = "derp"
    create(:fixity_alg, name: name)

    instance = FixityAlg.where(name: name).first

    expect(instance).to be_valid
  end

  it 'should store name as lowercase' do
    name = "DsfDSFsdasdfDSF"
    create(:fixity_alg, name: name)

    instance = FixityAlg.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end
end