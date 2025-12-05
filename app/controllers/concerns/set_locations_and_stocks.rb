# 一覧画面で表示する保管場所とストック情報の一覧をセットするモジュール

module SetLocationsAndStocks
  extend ActiveSupport::Concern

  include HouseholdResources

  private

  # 検索可能なストック一覧をセットする(stocks/indexとsortsコントローラで使用)
  def set_household_locations_and_searchable_stocks
    @locations = household_locations.order(:name)
    @q = Stock.joins_latest_history(History.latest).ransack(params[:q])
    @stocks = @q.result(distinct: true).merge(household_stocks).order_position
  end

  # 上記以外のコントローラで使用
  def set_household_locations_and_stocks
    @locations = household_locations.order(:name)
    @stocks = Stock.joins_latest_history(History.latest)
              .merge(household_stocks)
              .order_position
  end
end
