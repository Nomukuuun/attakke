# ログインしているユーザーについて、プッシュ通知を受け取るためのブラウザ情報を管理する

class SubscriptionsController < ApplicationController
  protect_from_forgery except: %i[create destroy]  # JSからPOSTされるのでCSRF保護を除外

  def create
    subscription = current_user.subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    subscription.assign_attributes(
      p256dh: subscription_params[:keys][:p256dh],
      auth: subscription_params[:keys][:auth]
    )

    if subscription.save
      head :ok
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(endpoint: subscription_params[:endpoint])
    subscription&.destroy
    head :ok
  end

  private

  def subscription_params
    params.permit(:endpoint, keys: [ :p256dh, :auth ])
  end
end
