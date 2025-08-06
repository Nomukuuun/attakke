class AddIndexNameToLocations < ActiveRecord::Migration[7.2]
  def change
    add_index :locations, :name, unique: true
  end
end
