class CreateNoOperations < ActiveRecord::Migration
  def change
    create_table :no_operations do |t|
      t.timestamps
    end
  end
end
