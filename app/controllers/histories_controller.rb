class HistoriesController < ApplicationController
  # existence型のストックがindex画面で使用するメソッド
  def create
    latest_history = History.select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc)
    set_latest_history_stock(latest_history)
    save_quantity = latest_history.find_by( stock_id: history_params[:stock_id] ).exist_quantity.to_i == 1 ? 0 : 1

    history = @stock.histories.build(exist_quantity: save_quantity)
    if history.save
      latest_history.reload
      set_latest_history_stock(latest_history) # 更新後のlatest_historyを基に再セット
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.history"))
      render turbo_stream: [
        turbo_stream.update(@stock, partial: "stocks/stock", locals: { stock: @stock }),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      flash[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.history"))
      redirect_to stocks_path
    end
  end

  private

  def history_params
    params.permit(:stock_id)
  end

  def set_latest_history_stock(latest_history)
    @stock = Stock.joins_latest_history(latest_history).find( history_params[:stock_id] )
  end
end
