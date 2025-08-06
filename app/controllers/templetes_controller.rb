class TempletesController < ApplicationController
  def index
    @templetes = Templete.all.order(:id)
    @locations = @templetes.pluck(:location_name).uniq
    p @templetes
  end

  def create
    templetes = Templete.where(location_name: params[:location_name])
    location = current_user.locations.find_or_create_by!( name: params[:location_name] )

    templetes.each do |t|
      stock = Stock.create!(
        user_id: current_user.id,
        location_id: location.id,
        name: t.stock_name,
        model: t.stock_model
      )

      History.create!(
        stock_id: stock.id,
        exist_quantity: t.history_exist_quantity,
        num_quantity: t.history_num_quantity,
      )
    end

    redirect_to stocks_path, success: t('defaults.flash_message.created', item: t('defaults.models.stock'))
  end

  private

  def templete_params
    params.require(:location_name)
  end
end
