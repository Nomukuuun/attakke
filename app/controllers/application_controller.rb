class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_list_type_value
  before_action :set_sort_mode_value

  # ビューで現在のlist_typeを参照する
  helper_method :current_list_type_value
  helper_method :current_sort_mode_value

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  add_flash_types :success, :error

  # NOTE: 以下privateメソッド
  private

  # リストタイプボタンの選択によりmainタグだけでなくfooterも表示分けするためここに記述
  def set_list_type_value
    # stocks#index から来たときだけ更新、それ以外の画面では前回選択を維持
    if controller_name == "stocks" && action_name == "index" && params[:list_type].present?
      session[:list_type_value] = params[:list_type]
    end
    @list_type_value = session[:list_type_value].presence || "all"
  end

  def current_list_type_value
    @list_type_value
  end

  # ヘッダーのボタン選択をheaderだけでなくmainにも共有するためにここに記述
  def set_sort_mode_value
    # ソートモードはデフォルトがオフになるようにする
    if controller_name == "stocks" && action_name == "sort_mode" && params[:sort_mode].present?
      session[:sort_mode] = params[:sort_mode]
    else
      session[:sort_mode] = "off"
    end
    @sort_mode_value = session[:sort_mode].presence || "off"
  end

  def current_sort_mode_value
    @sort_mode_value
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
