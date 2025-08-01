class HistoriesController < ApplicationController
  # existence型のストックがindex画面で使用するメソッド
  def create
    stock = Stock.find(params[:stock_id])
    stock_latest_history = History.where(stock_id: stock.id).order(id: :desc).first
    save_quantity = stock_latest_history.exist_quantity.to_i == 1 ? 0 : 1

    history = stock.histories.build(exist_quantity: save_quantity)
    if history.save
      redirect_to stocks_path, success: t("defaults.flash_message.created", item: t("defaults.models.history"))
    else
      flash[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.history"))
      redirect_to stocks_path
    end
  end

  private

  def history_params
    params.require(:stock_id)
  end
end
