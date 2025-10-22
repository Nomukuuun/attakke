class SubscriptionsController < ApplicationController
  protect_from_forgery except: %i[create destroy]  # JSからPOSTされるのでCSRF保護を除外
  # NOTE: パートナー申請などの通知を送るため、購買情報を記録するのはユーザー登録が済んでいるユーザーのはず = 認証はスキップしない
  # before_action :authenticate_user!

  def create
    subscription = current_user.subscriptions.find_or_initialize_by(
      endpoint: params[:endpoint]
    )

    subscription.assign_attributes(
      p256dh: params.dig(:keys, :p256dh),
      auth: params.dig(:keys, :auth)
    )

    if subscription.save
      head :ok
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(endpoint: params[:endpoint])
    subscription&.destroy
    head :ok
  end
end
