# 一覧画面で表示する保管場所とストック情報の一覧をセットするモジュール

module SetStocksAndLocations
  extend ActiveSupport::Concern

  private

  def set_locations_and_searchable_stocks
    @locations = our_locations.order(:name)
    @q = Stock.joins_latest_history(History.latest).ransack(params[:q])
    @stocks = @q.result(distinct: true).merge(our_stocks).order_asc_model_and_name
  end

  def set_locations_and_stocks
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(History.latest)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
