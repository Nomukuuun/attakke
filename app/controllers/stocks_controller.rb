class StocksController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[index in_stocks out_of_stocks create update destroy]
  before_action :set_stock_locations_histories, only: %i[edit update]

  def index
    render_stocks_and_locations
  end

  # inとout_ofはフィルタリングアクション
  def in_stocks
    @stocks = @stocks.in_stocks
    render_stocks_and_locations
  end

  def out_of_stocks
    @stocks = @stocks.out_of_stocks
    render_stocks_and_locations
  end

  def new
    @stock = Stock.new
    @location = Location.find(params[:location_id])
    @stock.histories.build(exist_quantity: 1)
  end

  def create
    @stock = current_user.stocks.build(stock_params)
    @location = @stock.location

    if @stock.save
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      if @location.stocks.count == 1
        render turbo_stream: [
          turbo_stream.replace(@location, partial: "location", locals: { location: @location, stocks: @stocks }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      else
        render turbo_stream: [
          turbo_stream.prepend("#{@location.name}_stock_list", partial: "stock", locals: { stock: @stocks.find(@stock.id) }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_latest_history(@stock) if @stock.histories.none?(&:new_record?)
  end

  def update
    if @stock.update(stock_params)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.stock"))
      if @stock.previous_changes.has_key?(:location_id)
        render turbo_stream: [
          turbo_stream.replace("main_frame", partial: "main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      else
        render turbo_stream: [
          turbo_stream.replace(@stock, partial: "stock", locals: { stock: @stocks.find(@stock.id) }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    stock = our_stocks.find(params[:id])
    location = stock.location

    stock.destroy!
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.stock"))
    if location.stocks.count == 0
      render turbo_stream: [
        turbo_stream.replace(location, partial: "location", locals: { location: location, stocks: @stocks }),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      render turbo_stream: [
        turbo_stream.remove("stock_#{stock.id}"),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    end
  end

  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, histories_attributes: [:exist_quantity, :num_quantity])
  end

  # new, edit以外でアクション実行前にセットするメソッド
  # NOTE: location, templetes_controllerと重複記述
  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end

  # edit, updateアクションで使用する共通メソッド
  def set_stock_locations_histories
    @stock = our_stocks.find(params[:id])
    @locations = our_locations.order(:name)
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
  end

  # editで直近の履歴を反映したhistoryインスタンスを作成するメソッド
  def build_latest_history(stock)
    latest_history = stock.histories.order(id: :desc).first
    quantity_type = stock.existence? ? :exist_quantity : :num_quantity
    old_quantity = latest_history.send(quantity_type).to_i

    if quantity_type == :exist_quantity
      history = stock.histories.build(quantity_type => old_quantity)
    elsif quantity_type == :num_quantity
      history = stock.histories.build(exist_quantity: 1, quantity_type => old_quantity)
    end
  end

  # フィルタリングアクションのレンダリングメソッド
  def render_stocks_and_locations
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("main_frame", partial: "main_frame", locals: { stocks: @stocks, locations: @locations })
      }
      format.html {
        render :index
      }
    end
  end
end
