class StocksController < ApplicationController
  def index
    # 最新履歴を取得するためのサブクエリ用変数
    latest_histories = History.select("DISTINCT ON (stock_id) *").order("stock_id, recording_date DESC")

    @stocks = current_user.stocks
              .joins("LEFT JOIN (#{latest_histories.to_sql}) AS latest_histories ON latest_histories.stock_id = stocks.id")
              .select("stocks.*, latest_histories.recording_date AS latest_recording_date, latest_histories.exist_quantity AS latest_exist_quantity, latest_histories.num_quantity AS latest_num_quantity")
              .order(:model ,:name)
    @locations = current_user.locations.order(:name)
  end

  def new
    @stock = Stock.new
    @location = Location.find(params[:location])
    @stock.histories.build
  end

  def create
    @stock = current_user.stocks.build(stock_params)
    @location = @stock.location
    history, quantity_type = find_and_create_new_history(@stock)
    histories_substitute(history, quantity_type)

    p "history: ex:#{history.exist_quantity} num:#{history.num_quantity} #{history.status} #{history.recording_date}"

    if @stock.save
      redirect_to stocks_path, success: t("defaults.flash_message.created", item: t("defaults.models.stock"))
    else
      p @stocks.errors.full_messages
      flash.now[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.stock"))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @stock = current_user.stocks.find(params[:id])
    @location = @stock.location
    @locations = current_user.locations.order(:name)
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
    find_and_create_new_history(@stock, permit_action: true)
  end
  
  def update
    @stock = current_user.stocks.find(params[:id])
    @location = @stock.location
    @histories = @stock.histories.where.not(id: nil).order(id: :desc).limit(10)
    history, quantity_type, old_quantity = find_and_create_new_history(@stock)
    histories_substitute(history, quantity_type, old_quantity)
    
    if @stock.update(stock_params)
      redirect_to stocks_path, success: t("defaults.flash_message.updated", item: t("defaults.models.stock"))
    else
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

  # 未保存状態の履歴を持っているか確認して取得
  # TODO: edit or updateのときはbuildに最新のquantityを渡してあげないとストック数の表示が初期化される
  def find_and_create_new_history(stock, permit_action: false)
    latest_history = stock.histories.order(id: :desc).first
    quantity_type = stock.existence? ? "exist_quantity" : "num_quantity"

    old_quantity = nil

    if stock.histories.none?(&:new_record?)
      old_quantity = latest_history.send(quantity_type) if permit_action && latest_history
      stock.histories.build(quantity_type => old_quantity)
    else
      history = stock.histories.find(&:new_record?)
      if permit_action && latest_history
        old_quantity = latest_history.send(quantity_type)
        history.send("#{quantity_type}=", old_quantity) if history.send(quantity_type).nil?
      end
    end

    history ||= stock.histories.find(&:new_record?)
    return history, quantity_type, old_quantity
  end

  # ユーザーからの入力が必要ないhistoryのカラムを補完するメソッド
  # FIXME: quantityを0で登録してもpurchaseになってしまう
  def histories_substitute(history, quantity_type, old_quantity = nil)
    new_quantity = history.send(quantity_type).to_i
    model_change = history.stock.model.to_s != params[:stock][:model]

    if action_name == "update" && !model_change
      difference = old_quantity - new_quantity
      case
      when difference > 0
        history.status ||= :purchase
      when difference == 0
        history.status ||= :purchase # 本来は履歴更新をするか確認する
      when difference < 0
        history.status ||= :consumption
      end
    else # create 又は updateだけどストック型を変更した場合
      history.status ||= new_quantity == 0 ? :consumption : :purchase
    end
    history.recording_date ||= Date.today
  end
end
