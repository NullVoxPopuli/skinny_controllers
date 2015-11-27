require 'spec_helper'

describe SkinnyControllers::Policy::DenyAll do
  let(:klass) { SkinnyControllers::Policy::DenyAll }
  let(:policy){ klass.new(nil, nil) }

  it { expect(policy.read?).to eq false }
  it { expect(policy.read_all?).to eq false }
  it { expect(policy.update?).to eq false }
  it { expect(policy.create?).to eq false }
  it { expect(policy.destroy?).to eq false }
  it { expect(policy.delete?).to eq false }
end

describe SkinnyControllers::Policy::AllowAll do
  let(:klass) { SkinnyControllers::Policy::AllowAll }
  let(:policy){ klass.new(nil, nil) }

  it { expect(policy.read?).to eq true }
  it { expect(policy.read_all?).to eq true }
  it { expect(policy.update?).to eq true }
  it { expect(policy.create?).to eq true }
  it { expect(policy.destroy?).to eq true }
  it { expect(policy.delete?).to eq true }
end
