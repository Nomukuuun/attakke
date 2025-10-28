class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # deviseのupdateアクションをモーダル対応にオーバーライド
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.update_without_password(account_update_params)
      flash.now[:success] = t("defaults.flash_message.updated", item: "ユーザー情報")
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      # バリデーションエラー時の処理
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  # 編集時に許可する項目
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email])
  end
end
