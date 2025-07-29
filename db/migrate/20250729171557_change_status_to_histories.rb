class ChangeStatusToHistories < ActiveRecord::Migration[7.2]
  def up
    change_column_null :histories, :status, true
  end
end
