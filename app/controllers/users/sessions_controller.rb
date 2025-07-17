class Users::SessionsController < Devise::SessionsController
  def destroy
    reset_session
    redirect_to root_path, success: "ログアウトしました"
  end
end
