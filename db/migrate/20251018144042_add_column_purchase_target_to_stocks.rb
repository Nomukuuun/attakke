class AddColumnPurchaseTargetToStocks < ActiveRecord::Migration[7.2]
  def change
    add_column :stocks, :purchase_target, :boolean, default: false, null: false
  end
end
