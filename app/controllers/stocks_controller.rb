class StocksController < ApplicationController
  def index
    # 最新履歴を取得するためのサブクエリ用変数
    latest_histories = History.select("DISTINCT ON (stock_id) *").order("stock_id, recording_date DESC")

    @stocks = current_user.stocks
              .joins("LEFT JOIN (#{latest_histories.to_sql}) AS latest_histories ON latest_histories.stock_id = stocks.id")
              .select("stocks.*, latest_histories.recording_date AS latest_recording_date, latest_histories.quantity AS latest_quantity")
              .order(:model ,:name)
    @locations = current_user.locations.order(:name)
  end

  def new
    @stock = Stock.new
    @location = Location.find_by(name: params[:location])
    @stock.histories.build
  end

  def create
    @stock = current_user.stocks.build(stock_params)
    if @stock.save
      redirect_to stocks_path, success: "ストックを作成しました"
    else
      @location = Location.find(params[:stock][:location_id])
      flash.now[:error] = "ストックを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @stock = current_user.stocks.find(params[:id])
    @location_name = @stock.location.name
    @locations = current_user.locations.order(:name)
  end

  def update
    @stock = current_user.stocks.find(params[:id])
    if @stock.update(stock_params)
      redirect_to stocks_path, success: "ストックを更新しました"
    else
      flash.now[:error] = "ストックを更新できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    stock = current_user.stocks.find(params[:id])
    stock.destroy!
    redirect_to stocks_path, success: "ストックを削除しました", status: :see_other
  end

  private

  def stock_params
    params.require(:stock).permit(:location_id, :name, :model, histories_attributes: [:id, :quantity, :status, :recording_date])
  end
end
