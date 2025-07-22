class StocksController < ApplicationController
  def index
    @stocks = current_user.stocks.includes(:histories).order(:name)
    @locations = current_user.locations.order(:name)
  end

  def new
    @stock = Stock.new
    @location_name = params[:location]
  end

  def create
    @stock = current_user.stocks.build(stock_params)
    if @stock.save
      redirect_to stocks_path, success: "ストックを作成しました"
    else
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
    params.require(:stock).permit(:name, :model)
  end
end
