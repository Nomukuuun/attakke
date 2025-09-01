class PartnershipsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[approve reject]
  # 以下、Ａ：ログイン済みのユーザー　Ｂ：パートナー申請を受けたユーザー

  # Ａ：メールアドレスを入力して申請メールを送る
  def new
    @partnership = current_user.partnership
  end

  # Ａ：申請メールを送信 & レコード作成
  def create
    if User.exists?(email: partner_gmail)
      partner = User.find_by(email: partner_gmail)

      Partnership.transaction do
        @partnership = current_user.create_partnership!(partner_id: partner.id, status: :pending)
        # after_create コールバックで反対側も作成
      end
      # PartnershipMailer.with(parntership: @parntership).メーラーのメソッド名.deliver_later
    end
    # ブルートフォースアタック対策でメールが送れていなくても送信したと表示
    flash.now[:success] = t("defaults.flash_message.mail_sended")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end

  # Ａ：申請を取り下げ、レコードを削除
  def destroy
    Partnership.transaction do
      current_user.partnership.destroy!
    # after_destroy コールバックで反対側も削除
    end
    flash.now[:success] = t("defaults.flash_message.withdrawal")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end

  # Ｂ：申請承認時にレコードのstatusをapprovedに更新する
  def approve
    partnership = Partnership.find_by(token: partnership_params[:token])

    if partnership&.pending?
      Partnership.transaction do
        partnership.update!(status: :approved, token: nil)
        # after_update コールバックで反対側も更新
      end
      # TODO: 申請承認画面のrender
    end
  end

  # Ｂ：申請を拒否、レコード削除
  def reject
    partnership = Partnership.find_by(token: partnership_params[:token])
    Partnership.transaction do
      partnership.destroy!
      # after_destroy コールバックで反対側も削除
    end
    # TODO: 申請拒否画面のrender
  end

  private

  def partnership_params
    params.permit(:email, :token)
  end

  def partner_gmail
    "#{partnership_params[:email]}@gmail.com"
  end
end
