class StocksController < ApplicationController
  before_action :latest_history_and_locations, only: %i[index in_stocks out_of_stocks]
  before_action :set_stocks_base, only: %i[index in_stocks out_of_stocks]

  def index; end

  def in_stocks
    @stocks = @stocks.in_stocks
    render :index
  end

  def out_of_stocks
    @stocks = @stocks.out_of_stocks
    render :index
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
      redirect_to stocks_path, success: t("defaults.flash_message.created", item: t("defaults.models.stock"))
    else
      flash.now[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.stock"))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @stock = current_user.stocks.find(params[:id])
    @locations = current_user.locations.order(:name)
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
    build_latest_history(@stock) if @stock.histories.none?(&:new_record?)
  end
  
  def update
    @stock = current_user.stocks.find(params[:id])

    if @stock.update(stock_params)
      redirect_to stocks_path, success: t("defaults.flash_message.updated", item: t("defaults.models.stock"))
    else
      @locations = current_user.locations.order(:name)
      @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
      flash.now[:error] = t("defaults.flash_message.not_updated", item: t("defaults.models.stock"))
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    stock = current_user.stocks.find(params[:id])
    stock.destroy!
    redirect_to stocks_path, success: t("defaults.flash_message.deleted", item: t("defaults.models.stock")), status: :see_other
  end

  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, histories_attributes: [:exist_quantity, :num_quantity])
  end

  # editアクション時に直近の履歴から数量を取得したhistoryインスタンスを作成するメソッド
  def build_latest_history(stock)
    latest_history = stock.histories.order(id: :desc).first
    quantity_type = stock.existence? ? :exist_quantity : :num_quantity
    old_quantity = latest_history.send(quantity_type).to_i

    if quantity_type == :exist_quantity
      history = stock.histories.build(quantity_type => old_quantity)
    elsif quantity_type == :num_quantity
      history = stock.histories.build(exist_quantity: 1, quantity_type => old_quantity)
    end
    history
  end

  # indexアクションで使用する共通メソッド
  def latest_history_and_locations
    # 最新履歴を取得するためのサブクエリ用変数
    @latest_history = History.select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc)
    @locations = current_user.locations.order(:name)
  end

  def set_stocks_base
    @stocks = Stock.joins_latest_history(@latest_history)
              .merge(current_user.stocks)
              .order_asc_model_and_name
  end
end
