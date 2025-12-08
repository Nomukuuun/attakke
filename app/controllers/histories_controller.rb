# ベース画面上でチェックボックス型の履歴を更新できるようにするためのコントローラ

class HistoriesController < ApplicationController
  include Broadcaster

  def create
    save_quantity = history_params[:quantity].to_i == 1 ? 0 : 1
    new_history = History.build(stock_id: history_params[:stock_id], exist_quantity: save_quantity)

    if new_history.save
      set_stock_reflected_latest(History.latest)
      broadcaster.replace_stock(@stock)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.history"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      flash[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.history"))
      redirect_to stocks_path
    end
  end

  # NOTE: 以下privateメソッド
  private

  def history_params
    params.permit(:stock_id, :quantity)
  end

  def set_stock_reflected_latest(latest_history)
    @stock = Stock.joins_latest_history(latest_history).find(history_params[:stock_id])
  end
end
