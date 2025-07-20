class CreateHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :histories do |t|
      t.integer :stock, null: false
      t.integer :status, null: false, default: 0
      t.date :recording_date
      t.references :stock, foreign_key: true

      t.timestamps
    end
  end
end
