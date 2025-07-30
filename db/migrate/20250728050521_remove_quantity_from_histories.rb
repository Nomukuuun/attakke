class RemoveQuantityFromHistories < ActiveRecord::Migration[7.2]
  def change
    remove_column :histories, :quantity, :integer
  end
end
