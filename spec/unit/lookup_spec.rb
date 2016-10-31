# frozen_string_literal: true
require 'rails_helper'

describe SkinnyControllers::Lookup do
  let(:klass) { SkinnyControllers::Lookup }

  context 'the operation namespace matches the controller namespace' do
    context 'the operation class is defined' do
      let(:posts_create) { klass.new(controller_class: Api::V2::PostsController, verb: 'Create') }
      it { expect(posts_create.namespace).to eq 'Api::V2' }
      it { expect(posts_create.resource_parts).to eq %w(Api V2 Posts) }
      it { expect(posts_create.operation_namespace).to eq 'Api::V2::PostOperations' }
      it { expect(posts_create.operation_name).to eq 'PostOperations' }
      it { expect(posts_create.operation_class).to eq Api::V2::PostOperations::Create }
      it { expect(posts_create.policy_class).to eq Api::V2::PostPolicy }
      it { expect(posts_create.model_name).to eq 'Post' }
      it { expect(posts_create.model_class).to eq nil }
      it { expect(posts_create.policy_method_name).to eq 'create?' }
    end

    context 'the operation class is not defined' do
      let(:posts_update) { klass.new(controller_class: Api::V2::PostsController, verb: 'Update') }
      it { expect(posts_update.operation_class).to eq Api::V2::PostOperations::Update }
    end
  end

  context 'the controller has a namespace, but the operations do not' do
    let(:comments_create) { klass.new(controller_class: Api::V2::CommentsController, verb: 'Create') }

    it { expect(comments_create.operation_name).to eq 'CommentOperations' }
    it { expect(comments_create.operation_class).to eq CommentOperations::Create }
    it { expect(comments_create.model_name).to eq 'Comment' }
  end

  context 'the model/resource has a namespace' do
    let(:other_item_show) { klass.new(controller_cass: OtherItemsController, verb: 'Read', model_class: SuperItem::OtherItem) }

    xit { expect(other_item_show.operation_class).to eq SuperItem::OtherItemOperations }
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
