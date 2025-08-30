class RemovePartnerIdToUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users , :partner_id
  end
end
