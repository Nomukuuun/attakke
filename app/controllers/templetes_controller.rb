class TempletesController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[create]
  before_action :set_location_name, only: %i[form]

  def index
    @templetes = Templete.all.order(:id)
    @locations = @templetes.pluck(:location_name).uniq
  end

  # 選択された location_name のテンプレートからフォームを返す
  def form
    @templetes = Templete.filter_location(@location_name)
    @forms = TempletesForm.new({ location_name: @location_name })

    @forms.stock_forms.concat(@templetes.map do |t|
      TempletesStockForm.new(
        name: t.stock_name,
        model: t.stock_model,
        exist_quantity: t.history_exist_quantity,
        num_quantity: t.history_num_quantity,
      )
    end
    )

    render turbo_stream: turbo_stream.update(
      "templete_form_frame",
      partial: "templetes/form",
      locals: { forms: @forms }
    )
  end

  def create
    @templetes = TempletesForm.new(templetes_form_params, our_locations: our_locations, current_user: current_user)

    if @templetes.save
      flash.now[:success] = t('defaults.flash_message.created', item: t('defaults.models.stock'))
      if our_locations.count == 1
        render turbo_stream: [
          turbo_stream.replace("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      else
        render turbo_stream: [
          turbo_stream.prepend("locations", partial: "stocks/location", locals: { location: @templetes.location, stocks: @stocks }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

#   パラメータ例
#   {"authenticity_token"=>"[FILTERED]",
#  "templetes_form"=>
#   {"location_name"=>"トイレ収納棚",
#    "0"=>{"name"=>"トイレットペーパー", "exist_quantity"=>"", "num_quantity"=>"8", "model"=>"1"},
#    "1"=>{"name"=>"トイレ用洗剤", "exist_quantity"=>"1", "num_quantity"=>"", "model"=>"0"},
#    "2"=>{"name"=>"除菌スプレー", "exist_quantity"=>"1", "num_quantity"=>"", "model"=>"0"},
#    "3"=>{"name"=>"便座除菌シート", "exist_quantity"=>"1", "num_quantity"=>"", "model"=>"0"},
#    "4"=>{"name"=>"消臭剤", "exist_quantity"=>"1", "num_quantity"=>"", "model"=>"0"}},
#  "commit"=>"保存"}

  def templete_params
    params.permit(:location_name)
  end

  def templetes_form_params
    params.require(:templetes_form)
          .permit(:location_name,
                  stock_forms_attributes: [:name, :model, :exist_quantity, :num_quantity])
  end

  def set_location_name
    @location_name = templete_params[:location_name]
  end

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
