class TempletesController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[create]

  def index
    @templetes = Templete.all.order(:id)
    @locations = @templetes.pluck(:location_name).uniq
  end

  def create
    location_name = templete_params[:location_name]
    templetes = Templete.where(location_name: location_name)
    location = current_user.locations.find_or_create_by!( name: location_name )

    ActiveRecord::Base.transaction do
      templetes.each do |t|
        stock = current_user.stocks.create!(
          location_id: location.id,
          name: t.stock_name,
          model: t.stock_model
        )

        stock.histories.create!(
          exist_quantity: t.history_exist_quantity,
          num_quantity: t.history_num_quantity,
          status: :templete
        )
      end
    end

    flash.now[:success] = t('defaults.flash_message.created', item: t('defaults.models.stock'))
    if current_user.locations.count == 1
      render turbo_stream: [
        turbo_stream.replace("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      render turbo_stream: [
        turbo_stream.prepend("locations", partial: "stocks/location", locals: { location: location, stocks: @stocks }),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    end
  end

  private

  def templete_params
    params.permit(:location_name)
  end

  def set_stocks_and_locations
    latest_history = History.select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc) #最新履歴を取得するためのサブクエリ用変数
    @locations = current_user.locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(current_user.stocks)
              .order_asc_model_and_name
  end
end
