# frozen_string_literal: true
class SuperItem::OtherItem < SuperItem
  belongs_to :super_item, foreign_key: :reference_id
end
