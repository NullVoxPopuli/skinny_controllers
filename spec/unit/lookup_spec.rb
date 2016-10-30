# frozen_string_literal: true
require 'rails_helper'

describe SkinnyControllers::Lookup do
  let(:klass) { SkinnyControllers::Lookup }

  context 'the operation namespace matches the controller namespace' do
    let(:posts_create) { klass.new(controller_class: Api::V2::PostsController, verb: 'Create') }
    let(:posts_update) { klass.new(controller_class: Api::V2::PostsController, verb: 'Update') }

    context 'the operation class is defined' do
      it { expect(posts_create.namespace).to eq 'Api::V2' }
      it { expect(posts_create.resource_parts).to eq %w(Api V2 Posts) }
      it { expect(posts_create.operation_namespace).to eq 'Api::V2::PostOperations' }
      it { expect(posts_create.operation_class).to eq Api::V2::PostOperations::Create }
      it { expect(posts_create.policy_class).to eq Api::V2::PostPolicy }
      it { expect(posts_create.policy_method_name).to eq 'create?' }
    end

    context 'the operation class is not defined' do
      it { expect(posts_update.operation_class).to eq Api::V2::PostOperations::Update }
    end
  end

  context 'the controller has a namespace, but the operations do not' do
  end

  context 'the controller overrides the resource/model name' do
    let(:discount_create) do
      klass.new(
        controller_class: RequiresParentController,
        verb: 'Create',
        model_class: Discount
      )
    end

    it { expect(discount_create.model_name).to eq 'Discount' }
  end

  context 'controller has no namespace' do
    let(:discounts_create) { klass.new(controller_class: DiscountsController, verb: 'Create') }
    let(:users_destroy) { klass.new(controller_class: UsersController, verb: 'Delete') }

    it { expect(discounts_create.operation_class).to eq DiscountOperations::Create }
    it { expect(users_destroy.policy_method_name).to eq 'delete?' }
  end
end
