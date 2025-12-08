class BroadcasterServices
  def initialize(user, list_type, sort_mode)
    @current_user = user
    @list_type = list_type
    @sort_mode = sort_mode
  end

  # NOTE: controllerで呼び出す動的ロジック群
  def add_stock(location, stocks, stock)
    if location.stocks.count == 1
      replace_location(location, stocks)
    else
      prepend_stock(location, stocks.find(stock.id))
    end
  end

  def remove_stock(location, stocks, stock)
    if location.stocks.count == 0
      replace_location(location, stocks)
    else
      delete_stock(stock)
    end
  end

  def add_location(locations, stocks, location)
    if locations.count == 1
      update_main_frame(locations, stocks)
    else
      prepend_location(location, stocks)
    end
  end

  def remove_location(locations, stocks, location)
    if locations.count == 0
      update_main_frame(locations, stocks)
    else
      delete_location(location)
    end
  end

  # NOTE: 具体的な配信方法の小ロジック群
  # NOTE: broadcastはwebsocket通信でありsessionを共有できないため、明示的に渡している
  def prepend_location(location, stocks)
    Turbo::StreamsChannel.broadcast_prepend_to(
      stream_key,
      target: "locations",
      partial: "stocks/location",
      locals: { location: location, stocks: stocks, list_type: @list_type, sort_mode: @sort_mode }
    )
  end

  def replace_location(location, stocks)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: "location_#{location.id}",
      partial: "stocks/location",
      locals: { location: location, stocks: stocks, list_type: @list_type, sort_mode: @sort_mode }
    )
  end

  def delete_location(location)
    Turbo::StreamsChannel.broadcast_remove_to(
      stream_key,
      target: "location_#{location.id}"
    )
  end

  def prepend_stock(location, stock)
    Turbo::StreamsChannel.broadcast_prepend_to(
      stream_key,
      target: "location_#{location.id}_stocks_list",
      partial: "stocks/stock",
      locals: { location: location, stock: stock, sort_mode: @sort_mode }
    )
  end

  def replace_stock(stock)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: "stock_#{stock.id}",
      partial: "stocks/stock",
      locals: { stock: stock, sort_mode: @sort_mode }
    )
  end

  def delete_stock(stock)
    Turbo::StreamsChannel.broadcast_remove_to(
      stream_key,
      target: "stock_#{stock.id}"
    )
  end

  def update_main_frame(locations, stocks)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "main_frame",
      partial: "stocks/main_frame",
      locals: { locations: locations, stocks: stocks, list_type: @list_type, sort_mode: @sort_mode }
    )
  end

  # NOTE: 以下privateメソッド
  private

  def stream_key
    @current_user.partnership_stream_key
  end
end
