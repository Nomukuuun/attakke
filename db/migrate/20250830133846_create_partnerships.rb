class CreatePartnerships < ActiveRecord::Migration[7.2]
  def change
    create_table :partnerships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0  # 0: pending, 1: approved
      t.datetime :expires_at, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :partnerships, :token, unique: true
    add_index :partnerships, [:user_id, :partner_id], unique: true
  end
end
