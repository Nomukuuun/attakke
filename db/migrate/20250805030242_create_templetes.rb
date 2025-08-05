class CreateTempletes < ActiveRecord::Migration[7.2]
  def change
    create_table :templetes do |t|
      t.integer :group,                  null: false
      t.string :location_name,           null: false
      t.string :stock_name,              null: false
      t.integer :stock_model,            null: false, default: 0
      t.integer :history_exist_quantity
      t.integer :history_num_quantity

      t.timestamps
    end
  end
end
