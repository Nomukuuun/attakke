class ChangePresenceTokenToPartnerships < ActiveRecord::Migration[7.2]
  def change
    change_column :partnerships, :token, :string, null: true
  end
end
