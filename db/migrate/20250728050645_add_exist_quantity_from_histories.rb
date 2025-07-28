class AddExistQuantityFromHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :histories, :exist_quantity, :integer
    add_column :histories, :num_quantity, :integer
  end
end
