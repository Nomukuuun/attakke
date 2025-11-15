module ApplicationHelper
  # パートナー設定画面へのパスを設定
  def set_partnerships_path
    current_user.reload
    if current_user.active_partnership
      edit_partnerships_path
    else
      new_partnerships_path
    end
  end
end
