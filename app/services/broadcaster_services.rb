class BroadcasterServices
  def initialize(user, list_type, sort_mode)
    @current_user = user
    @list_type = list_type
    @sort_mode = sort_mode
  end

  # NOTE: broadcastはwebsocket通信のため、sessionを共有できない
  # NOTE: session値で表示分けをしているビューのために、明示的に渡してあげる
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

  def remove_location(location)
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

  def remove_stock(stock)
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
