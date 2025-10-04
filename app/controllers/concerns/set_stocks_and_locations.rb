# 一覧画面で表示する保管場所とストック情報の一覧をセットするモジュール

module SetStocksAndLocations
  extend ActiveSupport::Concern

  private

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
