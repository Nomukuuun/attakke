# ベース画面上でチェックボックス型の履歴を更新できるようにするためのコントローラ
# 履歴は新規作成のみでストックと同時に削除される

class HistoriesController < ApplicationController
  include Broadcast

  def create
    latest_history = History.latest
    set_stock_reflected_latest_history(latest_history)
    save_quantity = latest_history.find_by(stock_id: history_params[:stock_id]).exist_quantity.to_i == 1 ? 0 : 1

    new_history = @stock.histories.build(exist_quantity: save_quantity)
    if new_history.save
      latest_history.reload
      set_stock_reflected_latest_history(latest_history) # 更新後のlatest_historyを基に再セット

      broadcast.update_stock(@stock)
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
    params.permit(:stock_id)
  end

  def set_stock_reflected_latest_history(latest_history)
    @stock = Stock.joins_latest_history(latest_history).find(history_params[:stock_id])
  end
end
