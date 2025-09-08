class PartnershipsController < ApplicationController
  before_action :set_currentuser_partnership, only: %i[update destroy reject]

  # ログイン済みのユーザー用コントローラ

  # メールアドレスを入力して申請メールを送る
  def new
    @partnership = current_user.partnership || PartnershipsForm.new
  end

  # 申請メールを送信、レコード作成
  def create
    partnership = PartnershipsForm.new(gmail: partnerships_form_params[:gmail], current_user_email: current_user.email)

    # 自身のアドレスを入力又は空欄の場合
    if partnership.invalid?
      @partnership = partnership
      render :new, status: :unprocessable_entity
      return
    end

    if User.exists?(email: partner_gmail)
      partner = User.find_by(email: partner_gmail)
      Partnership.transaction do
        @partnership = current_user.create_partnership!(partner_id: partner.id, status: :sended)
        # after_create コールバックで反対側も作成
      end
      PartnershipMailer.send_gmail_to_recipient(@partnership, partner).deliver_later
    end
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
      PartnershipMailer.send_gmail_to_applicant(partner: current_user.partner).deliver_later
    end
    set_stocks_and_locations
    flash.now[:success] = t("defaults.flash_message.approve")
    render turbo_stream: [
      turbo_stream.replace("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
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
    flash.now[:success] = t("defaults.flash_message.reject")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end

  private

  def partnerships_form_params
    params.require(:partnerships_form).permit(:gmail)
  end

  def set_currentuser_partnership
    @partnership = current_user.partnership
  end

  def partner_gmail
    "#{partnerships_form_params[:gmail]}@gmail.com"
  end

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
