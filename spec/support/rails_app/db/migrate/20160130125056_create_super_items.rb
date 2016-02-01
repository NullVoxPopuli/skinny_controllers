class CreateSuperItems < ActiveRecord::Migration
  def change
    create_table :super_items do |t|
      t.string :item_type
      t.string :name
      t.integer :reference_id
    end
  end
end
