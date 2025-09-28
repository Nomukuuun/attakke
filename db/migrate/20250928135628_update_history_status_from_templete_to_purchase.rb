class UpdateHistoryStatusFromTempleteToPurchase < ActiveRecord::Migration[7.2]
  def change
    History.where(status: :templete).update_all(status: :purchase)
  end
end
