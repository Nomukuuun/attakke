class LocationsController < ApplicationController
  include SetLocationsAndStocks
  include HouseholdResources
  include Broadcaster

  before_action :set_household_locations_and_stocks, only: %i[update destroy]
  before_action :set_location, only: %i[edit update destroy]


  # newとcreateはtempletes_controllerが担っている
  def index
    @locations = household_locations.order(:name)
  end


  def edit; end

  def update
    if @location.update(location_params)
      broadcaster.replace_location(@location, @stocks)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @location.destroy!

    broadcaster.remove_location(@locations, @stocks, @location)
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.location"))
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash_message"),
      turbo_stream.update("modal_frame")
    ]
  end

  # NOTE: 以下privateメソッド
  private

  def location_params
    params.require(:location).permit(:name)
  end

  def set_location
    @location = household_locations.find(params[:id])
  end
end
