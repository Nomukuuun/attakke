class Public::PartnershipsController < ApplicationController
  layout "public"
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[approve reject]
  before_action :set_partnership, only: %i[show approve approved reject]

  # パートナー申請の受信者がログインせずにメールから確認するためのコントローラ

  # 確認用画面の分岐ビュー、partnerは申請者を返す
  def show
    @partner = set_partner(@partnership) if @partnership.present?
  end

  # 申請承認、statusをapprovedに更新
  def approve
    if @partnership
      Partnership.transaction do
        @partnership.update!(status: :approved, token: nil)
        # after_update コールバックで反対側も更新
      end
      PartnershipMailer.send_gmail_to_applicant(set_partner(@partnership)).deliver_later
      redirect_to approved_public_partnerships_path, status: :see_other
    else
      render partial: "expired", status: :unauthorized
    end
  end

  def approved
    @partner = set_partner(@partnership)
  end

  # 申請拒否、レコード削除
  def reject
    if @partnership
      Partnership.transaction do
        @partnership.destroy!
        # after_destroy コールバックで反対側も削除
      end
      redirect_to rejected_public_partnerships_path, status: :see_other
    else
      render partial: "expired", status: :unauthorized
    end
  end

  def rejected; end

  private

  def partnerships_receiver_params
    params.permit(:token)
  end

  def set_partnership
    @partnership = Partnership.find_by(token: partnerships_receiver_params[:token])
  end

  def set_partner(partnership)
    User.find(partnership.user_id)
  end
end
