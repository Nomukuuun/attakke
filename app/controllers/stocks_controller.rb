class StocksController < ApplicationController
  include SetStocksAndLocations

  before_action :set_stocks_and_locations, only: %i[index in_stocks out_of_stocks create update destroy]
  before_action :set_stock_locations_and_last_10_histories, only: %i[edit update]

  # ログイン後のベース画面
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

  # ストック型のデフォルト表示がチェックボックスのため、exist_quantityに初期値を設定
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

      # 保管場所にストックが存在しない場合、ストック追加を促すメッセージが表示されている
      # 当該メッセージを非表示にするために更新範囲を変更する
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

      # 保管場所が変更されているかどうかで更新範囲を変更する
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

    # 保管場所にストックが存在しなくなった場合、ストック追加を促すメッセージを表示する
    # 当該メッセージを表示するために更新範囲を変更する
    if location.stocks.count == 0
      render turbo_stream: [
        turbo_stream.replace(location, partial: "location", locals: { location: location, stocks: @stocks }),
        turbo_stream.update("flash", partial: "shared/flash_message"),
        turbo_stream.update("modal_frame")
      ]
    else
      render turbo_stream: [
        turbo_stream.remove("stock_#{stock.id}"),
        turbo_stream.update("flash", partial: "shared/flash_message"),
        turbo_stream.update("modal_frame")
      ]
    end
  end

  # NOTE: 以下privateメソッド
  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, histories_attributes: [ :exist_quantity, :num_quantity ])
  end

  # edit, updateアクションで使用するデータセット
  def set_stock_locations_and_last_10_histories
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
