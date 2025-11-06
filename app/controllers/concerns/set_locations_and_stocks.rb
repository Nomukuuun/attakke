# 一覧画面で表示する保管場所とストック情報の一覧をセットするモジュール

module SetLocationsAndStocks
  extend ActiveSupport::Concern

  private

  # index画面では検索可能なストック一覧をセットする
  def set_locations_and_searchable_stocks
    @locations = our_locations.order(:name)
    @q = Stock.joins_latest_history(History.latest).ransack(params[:q])
    @stocks = @q.result(distinct: true).merge(our_stocks).order_position
  end

  def set_locations_and_stocks
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(History.latest)
              .merge(our_stocks)
              .order_position
  end
end
