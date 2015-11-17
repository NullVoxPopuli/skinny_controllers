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

  context 'default access methods' do
    let(:object){ Example.new }
    let(:user){ TestUser.new }

    context :default? do
      it 'returns the default value' do
        policy = klass.new(user, object)
        expect(policy.default?).to eq SkinnyControllers.allow_by_default
      end

      it 'returns the default value (even if it does not make sense)' do
        SkinnyControllers.allow_by_default = 'wut'
        policy = klass.new(user, object)

        expect(policy.default?).to eq SkinnyControllers.allow_by_default
      end
    end

    context :read? do
      it 'calls the accessible method on the object' do
        policy = klass.new(user, object)
        expect(object).to receive(SkinnyControllers.accessible_to_method).once
        policy.read?
      end
    end

    context :read_all? do
      it 'calls the accessible method for each object' do
        object2 = Example.new
        policy = klass.new(user, [object, object2])

        expect(object).to receive(SkinnyControllers.accessible_to_method).once
        expect(object2).to receive(SkinnyControllers.accessible_to_method).once

        policy.read_all?
      end
    end


  end
end
