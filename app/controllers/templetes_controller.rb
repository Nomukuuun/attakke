class TempletesController < ApplicationController
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
          num_quantity: t.history_num_quantity
        )
      end
    end

    redirect_to stocks_path, success: t('defaults.flash_message.created', item: t('defaults.models.stock'))
  end

  private

  def templete_params
    params.permit(:location_name)
  end
end
