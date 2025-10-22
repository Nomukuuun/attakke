class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
