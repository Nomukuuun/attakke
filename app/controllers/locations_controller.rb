class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = current_user.locations.build(location_params)

    if @location.save
      redirect_to stocks_path, success: t("defaults.flash_message.created", item: t("defaults.models.location"))
    else
      flash.now[:error] = t("defaults.flash_message.not_created", item: t("defaults.models.location"))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @location = current_user.locations.find(params[:id])
  end

  def update
    @location = current_user.locations.find(params[:id])

    if @location.update(location_params)
      redirect_to stocks_path, success: t("defaults.flash_message.updated", item: t("defaults.models.location"))
    else
      flash.now[:error] = t("defaults.flash_message.not_updated", item: t("defaults.models.location"))
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    location = current_user.locations.find(params[:id])
    location.destroy!
    redirect_to stocks_path, success: t("defaults.flash_message.deleted", item: t("defaults.models.location")), status: :see_other
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end
end
