# frozen_string_literal: true
require 'spec_helper'

describe SkinnyControllers::Lookup::Namespace do
  let(:klass) { SkinnyControllers::Lookup::Namespace }

  context :create_namespace do
    after(:each) do
      # just in case of race conditions
      if defined? Hi
        # this is a scary command o.o
        Object.send(:remove_const, :Hi)
      end
    end

    it 'creates a namespace' do
      expect(defined? Hi).to be_falsey
      klass.create_namespace('Hi')
      expect(defined? Hi).to be_truthy
    end

    it 'creates a nested namespace' do
      expect(defined? Hi::There).to be_falsey
      klass.create_namespace('Hi::There')
      expect(defined? Hi::There).to be_truthy
    end

    it 'each name space retains individuality' do
      klass.create_namespace('Hi::There')
      expect(Hi).to_not eq Hi::There
    end
  end
end
