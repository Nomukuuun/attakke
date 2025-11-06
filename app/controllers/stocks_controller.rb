class StocksController < ApplicationController
  include SetLocationsAndStocks
  include Broadcast

  before_action :set_locations_and_searchable_stocks, only: %i[index]
  before_action :set_locations_and_stocks, only: %i[create update destroy sort]
  before_action :set_stock_locations_and_last_10_histories, only: %i[edit update]


  # ログイン後のベース画面
  def index
    # フィルタリングの選択によって返す@stocksを変更
    @filtering_value = filter_params[:filter] || "all"
    case @filtering_value
    when "all"
      @stocks
    when "out"
      @stocks = @stocks.out_of_stocks
    when "in"
      @stocks = @stocks.in_stocks
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("filter_bar", partial: "filter_bar", locals: { filtering: @filtering_value }),
          turbo_stream.replace("main_frame", partial: "main_frame", locals: { stocks: @stocks, locations: @locations })
        ]
      }
      format.html {
        render :index, locals: { stocks: @stocks, locations: @locations }
      }
    end
  end

  def search
    @stocks = our_stocks.where("name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
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
      # 保管場所にストックが存在しない場合、ストック追加を促すメッセージが表示されている
      # 当該メッセージを非表示にするために更新範囲を変更する
      if @location.stocks.count == 1
        broadcast.replace_location(@location, @stocks)
      else
        broadcast.prepend_stock(@location, @stocks.find(@stock.id))
      end
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    build_latest_history(@stock) if @stock.histories.none?(&:new_record?)
  end

  def update
    if @stock.update(stock_params)
      # 保管場所が変更されているかどうかで更新範囲を変更する
      if @stock.previous_changes.has_key?(:location_id)
        before_id, after_id = @stock.previous_changes[:location_id]
        broadcast.replace_location(Location.find(before_id), @stocks)
        broadcast.replace_location(Location.find(after_id), @stocks)
      else
        broadcast.replace_stock(@stocks.find(@stock.id))
      end
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.stock"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    stock = our_stocks.find(params[:id])
    location = stock.location
    stock.destroy!

    # 保管場所にストックが存在しなくなった場合、ストック追加を促すメッセージを表示する
    # 当該メッセージを表示するために更新範囲を変更する
    if location.stocks.count == 0
      broadcast.replace_location(location, @stocks)
    else
      broadcast.remove_stock(stock)
    end
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.stock"))
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash_message"),
      turbo_stream.update("modal_frame")
    ]
  end


  # ソートアイコンをドラックアンドドロップで並び替えるためのアクション
  def sort
    location = Stock.find(sort_params[:stock_ids].first).location
    sort_params[:stock_ids].each_with_index do |id, index|
      Stock.find(id).insert_at(index + 1)
    end

    @stocks.reload
    broadcast.replace_location(location, @stocks)
  end


  # NOTE: 以下privateメソッド
  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, :purchase_target, histories_attributes: [ :exist_quantity, :num_quantity ])
  end

  def filter_params
    params.permit(:filter)
  end

  def sort_params
    params.permit(:stocks_ids)
  end

  # edit, updateで使用するデータセット
  def set_stock_locations_and_last_10_histories
    @stock = our_stocks.find(params[:id])
    @locations = our_locations.order(:name)
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
  end

  # editで最新履歴の数量を反映したhistoryインスタンスを作成するメソッド
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
end
