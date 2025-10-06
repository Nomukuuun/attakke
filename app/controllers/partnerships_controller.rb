class PartnershipsController < ApplicationController
  include SetStocksAndLocations
  include Broadcast

  before_action :set_currentuser_partnership, only: %i[update destroy reject]


  # パートナー設定画面の表示を分岐するため、partnershipを持っているかで変数に格納する値を設定
  def new
    @partnership = current_user.partnership || PartnershipsForm.new
  end

  # 申請メールを送信、レコード作成
  def create
    partnership = PartnershipsForm.new(email: partnerships_form_params[:email], current_user_email: current_user.email)

    # 自身のアドレスを入力又は空欄の場合はエラーを表示して返す
    if partnership.invalid?
      @partnership = partnership
      render :new, status: :unprocessable_entity
      return
    end

    # 入力されたemailが登録されていれば、メール送信＆レコード作成
    if User.exists?(email: partnership.email)
      partner = User.find_by(email: partnership.email)
      Partnership.transaction do
        @partnership = current_user.create_partnership!(partner_id: partner.id, status: :sended)
        # after_create コールバックで反対側も作成
      end
      PartnershipMailer.send_email_to_recipient(@partnership, partner).deliver_later
      DestroyExpiredPartnershipJob.set(wait_until: @partnership.expires_at).perform_later(@partnership.id)
    end

    # メールアドレス特定防止のため、メール送信できていなくても送信成功メッセージを表示する
    flash.now[:success] = t("defaults.flash_message.mail_sended")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end


  # 申請承認、レコード更新
  def update
    if @partnership&.pending?
      Partnership.transaction do
        @partnership.update!(status: :approved, token: nil)
        # after_update コールバックで反対側も更新
      end
      PartnershipMailer.send_email_to_applicant(current_user.partner).deliver_later
    end

    # current_userを更新することで紐づく情報を更新する
    current_user.reload
    set_stocks_and_locations
    broadcast.replace_main_frame(@locations, @stocks)
    flash.now[:success] = t("defaults.flash_message.approve")
    render turbo_stream: [
      turbo_stream.update("bell_icon", partial: "shared/bell_icon"),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end


  # 申請を取り下げ、レコードを削除
  def destroy
    if @partnership&.sended?
      Partnership.transaction do
        @partnership.destroy!
        # after_destroy コールバックで反対側も削除
      end
    end
    flash.now[:success] = t("defaults.flash_message.withdrawal")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end


  # 申請を拒否、レコード削除
  def reject
    if @partnership&.pending?
      Partnership.transaction do
        @partnership.destroy!
        # after_destroy コールバックで反対側も削除
      end
    end
    current_user.reload
    flash.now[:success] = t("defaults.flash_message.reject")
    render turbo_stream: [
      turbo_stream.update("bell_icon", partial: "shared/bell_icon"),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end

  # NOTE: 以下privateメソッド
  private

  def partnerships_form_params
    params.require(:partnerships_form).permit(:email)
  end

  def set_currentuser_partnership
    @partnership = current_user.partnership
  end
end
