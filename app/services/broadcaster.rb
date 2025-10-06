class Broadcaster

  def initialize(user)
    @current_user = user
  end

  def prepend_location(location, stocks)
    Turbo::StreamsChannel.broadcast_prepend_to(
      stream_key,
      target: "locations",
      partial: "stocks/location",
      locals: { location: location, stocks: stocks }
    )
  end

  def replace_location(location, stocks)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: "location_#{location.id}",
      partial: "stocks/location",
      locals: { location: location, stocks: stocks }
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
      locals: { location: location, stock: stock }
    )
  end

  def replace_stock(stock)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: "stock_#{stock.id}",
      partial: "stocks/stock",
      locals: { stock: stock }
      )
    end

  def remove_stock(stock)
    Turbo::StreamsChannel.broadcast_remove_to(
      stream_key,
      target: "stock_#{stock.id}"
      )
  end

  def replace_main_frame(locations, stocks)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: "main_frame",
      partial: "stocks/main_frame",
      locals: { locations: locations, stocks: stocks }
    )
  end

  # NOTE: 以下privateメソッド
  private

  def stream_key
    @current_user.partnership_stream_key
  end
end
