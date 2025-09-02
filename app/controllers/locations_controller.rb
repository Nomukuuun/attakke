class LocationsController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[create update destroy]
  before_action :set_location, only: %i[edit update destroy]

  def new
    @location = Location.new
  end

  def create
    @location = current_user.locations.build(location_params)

    if @location.save
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.location"))
      if our_locations.count == 1
        render_main_frame
      else
        render turbo_stream: [
          turbo_stream.prepend("locations", partial: "stocks/location", locals: { location: @location, stocks: nil }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
      render turbo_stream: [
        turbo_stream.replace(@location, partial: "stocks/location", locals: { location: @location, stocks: @stocks }),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy!
    @locations.reload
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.location"))
    if our_locations.count == 0
      render_main_frame
    else
      render turbo_stream: [
        turbo_stream.remove("location_#{@location.id}"),
        turbo_stream.update("flash", partial: "shared/flash_message")
      ]
    end
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end

  def set_location
    @location = our_locations.find(params[:id])
  end

  def render_main_frame
    render turbo_stream: [
      turbo_stream.replace("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
      turbo_stream.update("flash", partial: "shared/flash_message")
    ]
  end
end
