class UpdatePartnershipsConstraints < ActiveRecord::Migration[7.2]
  def change
    # 既存ユニークインデックスを削除
    remove_index :partnerships, [:user_id, :partner_id]
    # 不要なカラムを削除
    remove_column :partnerships, :token, :string

    # expires_at を含む新しいインデックス（期限別管理に備える）
    add_index :partnerships, [:user_id, :partner_id, :expires_at]
  end
end
