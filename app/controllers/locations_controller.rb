class LocationsController < ApplicationController
  include SetLocationsAndStocks
  include HouseholdResources
  include Broadcast

  before_action :set_household_locations_and_stocks, only: %i[update destroy]
  before_action :set_location, only: %i[edit update destroy]


  # newとcreateはtempletes_controllerが担っている
  def index
    @locations = household_locations.order(:name)
  end


  def edit; end

  def update
    if @location.update(location_params)
      broadcast.replace_location(@location, @stocks)
      flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @location.destroy!

    # 保管場所が1つも存在しなくなった場合、ベース画面に新規作成を促すメッセージを表示する
    if household_locations.count == 0
      broadcast.update_main_frame(@locations, @stocks)
    else
      broadcast.remove_location(@location)
    end
    flash.now[:success] = t("defaults.flash_message.deleted", item: t("defaults.models.location"))
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash_message"),
      turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
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
