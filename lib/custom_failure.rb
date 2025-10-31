# ログインセッションを持たない状態でログインを試みた場合にトップページへリダイレクトする（デフォルトではdeviseのsign_in_pathになっている）
class CustomFailure < Devise::FailureApp
  def redirect_url
    root_path
  end
end
