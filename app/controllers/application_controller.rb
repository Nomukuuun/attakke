class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :current_list_type
  before_action :current_sort_mode

  # 各ビューでsession値を参照する
  helper_method :current_list_type
  helper_method :current_sort_mode
  helper_method :our_stocks

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  add_flash_types :success, :error

  # NOTE: 以下privateメソッド
  private

  # リストタイプのセッション値をどこでも参照できるようにする
  def current_list_type
    @list_type = session[:list_type].presence || "all"
  end

  # ソートモードのパラメータ値をどこでも参照できるようにする
  def current_sort_mode
    @sort_mode = params[:sort_mode] || "off"
  end

  # ActiveRecord::Relationでcurrent_user又はpair_usersを返す
  def pair_users
    ids = [ current_user.id ]
    ids << current_user.active_partner.id if current_user.active_partnership&.approved?
    User.where(id: ids)
  end

  def our_stocks
    Stock.where(user_id: pair_users.ids)
  end

  def our_locations
    Location.where(user_id: pair_users.ids)
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
