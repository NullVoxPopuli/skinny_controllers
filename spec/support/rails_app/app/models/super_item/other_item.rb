class SuperItem::OtherItem < SuperItem
  belongs_to :super_item, foreign_key: :reference_id
end
