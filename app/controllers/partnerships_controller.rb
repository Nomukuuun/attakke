class PartnershipsController < ApplicationController
  include SetLocationsAndStocks

  before_action :set_currentuser_active_partnership, only: %i[new edit update destroy reject]

  # NOTE: パートナー申請送信者側の操作
  def new
    # 申請が来ているが画面更新をかけていない状況などは、editへリダイレクトする
    if @partnership.present?
      redirect_to action: :edit, status: :see_other
    else
      @new_partnership = PartnershipsForm.new
    end
  end

  def create
    form_partnership = PartnershipsForm.new(email: partnerships_form_params[:email], current_user_email: current_user.email)

    # 自身のアドレスを入力又は空欄の場合は返してエラーを表示
    if form_partnership.invalid?
      @new_partnership = form_partnership
      render :new, status: :unprocessable_entity
      return
    end

    partner = User.find_by(email: form_partnership.email)

    # パートナーがいなければレコード作成＆プッシュ通知送信
    if partner.present? && partner.active_partnership.blank?
      Partnership.create_request_pair!(current_user, partner)
      message = { title: "【Attakke?】より", body: "パートナー申請が届いています！\nアプリを開いて確認してください！" }
      partner.send_push_notification(message: message)
    end

    # メールアドレス特定防止のため、申請を送信できていなくても送信成功メッセージを表示する
    flash.now[:success] = t("defaults.flash_message.sended")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end


  # 申請取り下げ
  def destroy
    @partnership.destroy_pair! if @partnership&.sended?
    flash.now[:success] = t("defaults.flash_message.withdrawal")
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end


  # NOTE: パートナー申請受信者側の操作
  # 申請承認
  def update
    if @partnership&.pending?
      @partnership.approve_pair!
      message = { title: "【Attakke?】より", body: "パートナー申請が承認されました！\nアプリを開いて確認してください！" }
      current_user.active_partner&.send_push_notification(message: message)
    end

    current_user.reload                 # current_userを更新することで紐づく情報を更新する
    set_household_locations_and_stocks  # main_frame更新のローカル変数をセット
    flash.now[:success] = t("defaults.flash_message.approve")
    render turbo_stream: [
      turbo_stream.update("main_frame", partial: "stocks/main_frame", locals: { locations: @locations, stocks: @stocks }),
      turbo_stream.update("bell_icon", partial: "shared/bell_icon"),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end


  # 申請を拒否、レコード削除
  def reject
    @partnership.destroy_pair! if @partnership&.pending?
    current_user.reload
    flash.now[:success] = t("defaults.flash_message.reject")
    render turbo_stream: [
      turbo_stream.update("bell_icon", partial: "shared/bell_icon"),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end

  # NOTE: お互いに使えるアクション
  def edit
    # 有効期限が切れていて画面更新をかけていない状況などは、 newへリダイレクトする
    redirect_to action: :new, status: :see_other if @partnership.blank?
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
