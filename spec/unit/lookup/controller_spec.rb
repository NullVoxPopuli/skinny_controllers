# frozen_string_literal: true
require 'spec_helper'

describe SkinnyControllers::Lookup::Controller do
  let(:klass) { SkinnyControllers::Lookup::Controller }

  context :resource_name do
    it 'removes controller' do
      result = klass.resource_name('FakeObjectsController')
      expect(result).to eq 'FakeObjects'
    end

    it 'ignores the namespace' do
      SkinnyControllers.controller_namespace = 'API'
      result = klass.resource_name('API::FakeObjectsController')
      expect(result).to eq 'FakeObjects'
      SkinnyControllers.controller_namespace = ''
    end
  end

  context :model_name do
    it 'resembles a class' do
      name = klass.model_name('FakeObjectsController')
      expect(name).to eq 'FakeObject'
    end

    it 'removes the prefix when there is none' do
      allow(klass).to receive(:namespace) { 'API::' }
      name = klass.model_name('FakeObjectsController')
      expect(name).to eq 'FakeObject'
    end

    it 'removes the prefix when there actually is a prefix to remove' do
      allow(klass).to receive(:namespace) { 'API::' }
      name = klass.model_name('API::SomeObjectsController')
      expect(name).to eq 'SomeObject'
    end
  end
end
