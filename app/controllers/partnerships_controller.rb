class PartnershipsController < ApplicationController
  include SetLocationsAndStocks
  include Broadcast

  before_action :set_currentuser_active_partnership, only: %i[update destroy reject]

  # NOTE: パートナー申請送信者側の操作
  # パートナー設定画面の表示を分岐するため、partnershipを持っているかで変数に格納する値を設定
  def new
    @partnership = current_user.active_partnership || PartnershipsForm.new
  end

  # 申請メールを送信、レコード作成
  def create
    new_partnership = PartnershipsForm.new(email: partnerships_form_params[:email], current_user_email: current_user.email)

    # 自身のアドレスを入力又は空欄の場合はエラーを表示して返す
    if new_partnership.invalid?
      @partnership = new_partnership
      render :new, status: :unprocessable_entity
      return
    end

    partner = User.find_by(email: new_partnership.email)

    # 入力されたemailを持つユーザーがactiveなpartnershipを持っていないならレコード作成＆プッシュ通知送信
    if partner.present? && partner&.active_partnership.blank?
      Partnership.transaction do
        @partnership = current_user.partnerships.create!(partner_id: partner.id, status: :sended)
        # after_create コールバックで反対側も作成
      end
      # パートナー申請受信者に向けてプッシュ通知を送信
      message = { title: "【Attakke?】より", body: "パートナー申請が届いています！アプリを開いて確認してください！" }
      partner.send_push_notification(message: message)
    end

    # メールアドレス特定防止のため、申請を送信できていなくても送信成功メッセージを表示する
    flash.now[:success] = t("defaults.flash_message.sended")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
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


  # NOTE: パートナー申請受信者側の操作
  # 申請承認、レコード更新
  def update
    if @partnership&.pending?
      Partnership.transaction do
        @partnership.update!(status: :approved)
        # after_update コールバックで反対側も更新
      end
      # パートナー申請送信者に向けてプッシュ通知を送信
      message = { title: "【Attakke?】より", body: "パートナー申請が承認されました！アプリを開いて確認してください！" }
      current_user.active_partner&.send_push_notification(message: message)
    end

    # current_userを更新することで紐づく情報を更新する
    current_user.reload
    set_locations_and_stocks
    broadcast.replace_main_frame(@locations, @stocks)
    flash.now[:success] = t("defaults.flash_message.approve")
    render turbo_stream: [
      turbo_stream.update("bell_icon", partial: "shared/bell_icon"),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
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

  def set_currentuser_active_partnership
    @partnership = current_user.active_partnership
  end
end
