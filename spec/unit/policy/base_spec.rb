require 'spec_helper'

describe SkinnyControllers::Policy::Base do
  let(:klass) { SkinnyControllers::Policy::Base }

  context :instantiation do
    it 'sets accessors' do
      b = klass.new(1, 2, authorized_via_parent: true)

      expect(b.user).to eq 1
      expect(b.object).to eq 2
      expect(b.authorized_via_parent).to eq true
    end
  end
end
