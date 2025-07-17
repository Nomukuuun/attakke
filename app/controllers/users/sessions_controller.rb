class Users::SessionsController < Devise::SessionsController
  def destroy
    reset_session
    redirect_to root_path, success: t('devise.sessions.success')
  end
end
