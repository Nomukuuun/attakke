class StocksController < ApplicationController
  include SetLocationsAndStocks
  include Broadcast

  before_action :set_locations_and_searchable_stocks, only: %i[index sort_mode]
  before_action :set_locations_and_stocks, only: %i[create update destroy sort rearrange]
  before_action :set_stock_locations_and_last_10_histories, only: %i[edit update]


  # ログイン後のベース画面
  def index
    # 買いものリストを選んでいるときだけ@stocksにスコープを適用
    # list_type_valueはapplication_controllerで設定
    @stocks = @stocks.shopping if @list_type_value == "shopping"

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
          turbo_stream.update("search_form", partial: "search_form", locals: { q: @q }),
          turbo_stream.update("list_type_bar", partial: "list_type_bar"),
          turbo_stream.update("main_frame", partial: "main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("footer_menu", partial: "shared/footer_menu")
        ]
      }
      format.html {
        render :index
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
        broadcast.update_location(@location, @stocks)
      else
        broadcast.prepend_stock(@location, @stocks.find(@stock.id))
      end
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      render turbo_stream: [
        turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    build_latest_history(@stock) if @stock.histories.none?(&:new_record?)
  end

  def update
    if @stock.update(stock_params)
      broadcast.update_stock(@stocks.find(@stock.id))
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
      broadcast.update_location(location, @stocks)
    else
      broadcast.remove_stock(stock)
    end
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.stock"))
    render turbo_stream: [
      turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
      turbo_stream.update("flash", partial: "shared/flash_message"),
      turbo_stream.update("modal_frame")
    ]
  end


  # 並べ替えは「買いものリスト」へ反映しないためbroadcastしない
  def sort_mode
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
          turbo_stream.update("search_form", partial: "search_form", locals: { q: @q }),
          turbo_stream.update("main_frame", partial: "main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("footer_menu", partial: "shared/footer_menu")
        ]
      }
      format.html {
        render :index
      }
    end
  end

  # ソートアイコンをドラックアンドドロップで並び替えるためのアクション
  def sort
    ids = sort_params[:stock_ids]
    location = our_locations.find(sort_params[:location_id])
    ids.each_with_index do |id, index|
      our_stocks.find(id).insert_at(index + 1)
    end

    render turbo_stream: turbo_stream.update("location_#{location.id}", partial: "location", locals: { location: location, stocks: @stocks })
  end

  # 配置換えソートを行うためのアクション
  def rearrange
    stock = our_stocks.find(params[:id])
    before_id, after_id = rearrange_params[:location_ids] # location_idsを分割代入
    stock.update!(location_id: after_id)
    stock.insert_at(rearrange_params[:new_position].to_i)

    before_location = our_locations.find(before_id)
    after_location = our_locations.find(after_id)
    flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
    render turbo_stream: [
      turbo_stream.update("location_#{before_location.id}", partial: "location", locals: { location: before_location, stocks: @stocks }),
      turbo_stream.update("location_#{after_location.id}", partial: "location", locals: { location: after_location, stocks: @stocks }),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end


  # NOTE: 以下privateメソッド
  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, :purchase_target, histories_attributes: [ :exist_quantity, :num_quantity ])
  end

  # 配列パラメータは[]が必要かつ、最後に記述する
  def sort_params
    params.permit(:location_id, stock_ids: [])
  end

  def rearrange_params
    params.permit(:new_position, location_ids: [])
  end

  # edit, updateで使用するデータセット
  def set_stock_locations_and_last_10_histories
    @stock = our_stocks.find(params[:id])
    @location = @stock.location
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
