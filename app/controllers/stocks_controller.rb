class StocksController < ApplicationController
  def index
    # 最新履歴を取得するためのサブクエリ用変数
    latest_histories = History.select("DISTINCT ON (stock_id) *").order("stock_id, id DESC, recording_date DESC")

    @stocks = current_user.stocks
              .joins("LEFT JOIN (#{latest_histories.to_sql}) AS latest_histories ON latest_histories.stock_id = stocks.id")
              .select("stocks.*, latest_histories.recording_date AS latest_recording_date, latest_histories.exist_quantity AS latest_exist_quantity, latest_histories.num_quantity AS latest_num_quantity")
              .order(:model ,:name)
    @locations = current_user.locations.order(:name)
  end

  def new
    @stock = Stock.new
    @location = Location.find(params[:location])
    @stock.histories.build(exist_quantity: 1)
  end

  # DONE: histories.statusは一覧にないというエラーが発生 <= historyのvalidatesを無効にした
  def create
    @stock = current_user.stocks.build(stock_params)
    @location = @stock.location

    if @stock.save
      redirect_to stocks_path, success: t("defaults.flash_message.created", item: t("defaults.models.stock"))
    else
      # NOTE:以下１行最終的に削除
      p @stock.errors.full_messages if !@stock.errors.nil?
      flash.now[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.stock"))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @stock = current_user.stocks.find(params[:id])
    @location = @stock.location
    @locations = current_user.locations.order(:name)
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
    build_latest_history(@stock) if @stock.histories.none?(&:new_record?)
    p build_latest_history(@stock)
  end
  
  def update
    @stock = current_user.stocks.find(params[:id])

    if @stock.update(stock_params)
      redirect_to stocks_path, success: t("defaults.flash_message.updated", item: t("defaults.models.stock"))
    else
      p @stock.errors.full_messages if !@stock.errors.nil?
      @location = @stock.location
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
  # TODO: 直近の履歴の数量を入れてビルドする
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
end
