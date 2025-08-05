class RenameGroupColumnToTempletes < ActiveRecord::Migration[7.2]
  def change
    rename_column :templetes, :group, :tag
  end
end
