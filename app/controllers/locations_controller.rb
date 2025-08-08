class LocationsController < ApplicationController
  before_action :latest_history_and_locations, only: %i[create update destroy]
  before_action :set_stocks_base, only: %i[create update destroy]
  before_action :set_location, only: %i[edit update destroy]

  def new
    @location = Location.new
  end

  # FIXME: locationがない状態だとリレンダリングされない
  def create
    @location = current_user.locations.build(location_params)

    if @location.save
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.location"))
      render_turbo_index
    else
      flash.now[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.location"))
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
      render_turbo_index
    else
      flash.now[:error] = t("defaults.flash_message.not_updated", item: t("defaults.models.location"))
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy!
    @locations.reload
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.location"))
    render_turbo_index
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def latest_history_and_locations
    @latest_history = History.select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc) #最新履歴を取得するためのサブクエリ用変数
    @locations = current_user.locations.order(:name)
  end

  def set_stocks_base
    @stocks = Stock.joins_latest_history(@latest_history)
              .merge(current_user.stocks)
              .order_asc_model_and_name
  end

  def set_location
    @location = current_user.locations.find(params[:id])
  end

  def render_turbo_index
    render turbo_stream: [
      turbo_stream.replace("stocks_frame", partial: "stocks/location", locals: { stocks: @stocks, locations: @locations }),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end
end
