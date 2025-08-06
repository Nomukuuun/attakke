class ChangeRecordingDateToHistories < ActiveRecord::Migration[7.2]
  def change
    change_column_null :histories, :status, false
    change_column_null :histories, :recording_date, false
  end
end
