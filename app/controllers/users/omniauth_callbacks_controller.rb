class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash[:success] = t('devise.omniauth_callbacks.success')
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url, alert: t('devise.omniauth_callbacks.failure')
    end
  end

  def failure
    redirect_to root_path, alert: t('devise.omniauth_callbacks.unauthenticated')
  end
end
