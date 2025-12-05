class StocksController < ApplicationController
  include SetLocationsAndStocks
  include HouseholdResources
  include Broadcast

  before_action :update_list_type_session, only: %i[index]
  before_action :set_household_locations_and_searchable_stocks, only: %i[index]
  before_action :set_household_locations_and_stocks, only: %i[create update destroy]
  before_action :set_household_stock_and_10_latest_histories, only: %i[edit update]


  # ログイン後のベース画面
  def index
    # リクエスト直後のlist_typeを取得、デフォルトはall
    latest_list_type = params[:list_type] || @list_type
    @stocks = @stocks.shopping if latest_list_type == "shopping"

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
    @stocks = household_stocks.where("name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
  end


  # ストック型のデフォルト表示がチェックボックスのため、exist_quantityに初期値を設定
  def new
    @stock = Stock.new(location_id: params[:location_id])
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
      render turbo_stream: [
        turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    @stock.build_latest_history
  end

  def update
    if @stock.update(stock_params)
      broadcast.replace_stock(@stocks.find(@stock.id))
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.stock"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    stock = household_stocks.find(params[:id])
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
      turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
      turbo_stream.update("flash", partial: "shared/flash_message"),
      turbo_stream.update("modal_frame")
    ]
  end


  # NOTE: 以下privateメソッド
  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, :purchase_target, histories_attributes: [ :exist_quantity, :num_quantity ])
  end

  # edit, updateで使用するデータセット
  def set_household_stock_and_10_latest_histories
    @stock = household_stocks.find(params[:id])
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
  end

  def update_list_type_session
    return if params[:list_type].blank?
    session[:list_type] = params[:list_type]
  end
end
