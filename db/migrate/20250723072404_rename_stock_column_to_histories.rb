class RenameStockColumnToHistories < ActiveRecord::Migration[7.2]
  def change
    rename_column :histories, :stock, :quantity
  end
end
