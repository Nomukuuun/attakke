class TempletesController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[create]

  def index
    @locations = ["【新規作成】"]
    @locations << "【まとめて追加】" if our_locations.present?
    @locations.concat(Templete.select(:location_name, :id)
                              .group_by(&:location_name)
                              .values
                              .map { |records| records.min_by(&:id).location_name })
  end

  # select_fieldの選択に応じてstimulusでフォーム切替
  def form
    @location_name = templete_params[:location_name]

    case @location_name
    when "【新規作成】"
      @forms = TempletesForm.new
      @forms.stock_forms << TempletesStockForm.new(model: 0, exist_quantity: 1)
    when "【まとめて追加】"
      @locations = our_locations.pluck(:name)
      @forms = TempletesForm.new({ location_name: @location_name })
      @forms.stock_forms << TempletesStockForm.new(model: 0, exist_quantity: 1)
    else # テンプレートの呼び出し
      @templetes = Templete.by_location_name(@location_name)
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
    end

    render turbo_stream: turbo_stream.update(
      "templete_form_frame",
      partial: "templetes/form",
      locals: { forms: @forms, locations: @locations }
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
      render turbo_stream: turbo_stream.update("templete_form_frame", partial: "templetes/form", locals: { forms: @templetes }), status: :unprocessable_entity
    end
  end

  private

  def templete_params
    params.permit(:location_name)
  end

  def templetes_form_params
    params.require(:templetes_form)
          .permit(:location_name,
                  stock_forms_attributes: [:name, :model, :exist_quantity, :num_quantity])
  end

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
