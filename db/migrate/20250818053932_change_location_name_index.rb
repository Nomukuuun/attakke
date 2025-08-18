class ChangeLocationNameIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :locations, :name

    add_index :locations, [:user_id, :name], unique: true
  end
end
