# frozen_string_literal: true
class SuperItem < ActiveRecord::Base
  self.inheritance_column = 'item_type'

  has_many :other_items,
    class_name: SuperItem::OtherItem.name,
    foreign_key: 'reference_id'
end
