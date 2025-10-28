class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  add_flash_types :success, :error

  private

  # Relationでcurrent_user又はpair_usersを返す
  def our_users
    ids = [ current_user.id ]
    ids << current_user.active_partner.id if current_user.active_partnership&.approved?
    User.where(id: ids)
  end

  def our_stocks
    Stock.where(user_id: our_users.ids)
  end

  def our_locations
    Location.where(user_id: our_users.ids)
  end

  # ログイン後に遷移する画面の指定
  def after_sign_in_path_for(resource)
    stocks_path
  end

  # ログアウト後に遷移する画面の指定
  def after_sign_out_path_for(resource)
    root_path
  end
end
