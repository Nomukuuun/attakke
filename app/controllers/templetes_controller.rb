class TempletesController < ApplicationController
  before_action :set_stocks_and_locations, only: %i[create]

  def index
    @locations_name = [ "【新規作成】" ]
    @locations_name << "【既存保管場所にまとめて追加】" if our_locations.present?
    @locations_name.concat(Templete.select(:location_name, :id)
                              .group_by(&:location_name)
                              .values
                              .map { |records| "<テンプレ> " + records.min_by(&:id).location_name })
  end

  # selectタグの選択に応じてstimulusでフォーム切替
  def form
    @location_name = templete_params[:location_name]

    case @location_name
    when "【新規作成】"
      @forms = TempletesForm.new({ location_name: nil, select_tag_value: @location_name })
      set_new_stock_forms(@forms)
    when "【既存保管場所にまとめて追加】"
      set_locations_name
      @forms = TempletesForm.new({ location_name: @location_name, select_tag_value: @location_name })
      set_new_stock_forms(@forms)
    else # テンプレートの呼び出し
      @location_name = @location_name.delete_prefix("<テンプレ> ").strip
      templetes = Templete.by_location_name(@location_name)
      @forms = TempletesForm.new({ location_name: @location_name, select_tag_value: @location_name })

      @forms.stock_forms.concat(
        templetes.map do |t|
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
      locals: { forms: @forms, locations_name: @locations_name }
    )
  end

  def create
    @forms = TempletesForm.new(templetes_form_params, our_locations: our_locations, current_user: current_user)

    if @forms.save
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      if our_locations.count == 1
        render turbo_stream: [
          turbo_stream.replace("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      else
        render turbo_stream: [
          turbo_stream.prepend("locations", partial: "stocks/location", locals: { location: @forms.location, stocks: @stocks }),
          turbo_stream.update("flash", partial: "shared/flash_message")
        ]
      end
    else
      select_tag_value = templetes_form_params[:select_tag_value]
      if select_tag_value == "【既存保管場所にまとめて追加】"
        set_locations_name
        prioritize_location_name(@forms, @locations_name)
        @forms.location_name = select_tag_value
      end
      render turbo_stream: turbo_stream.update("templete_form_frame", partial: "templetes/form", locals: { forms: @forms, locations_name: @locations_name }), status: :unprocessable_entity
    end
  end

  private

  def templete_params
    params.permit(:location_name)
  end

  def templetes_form_params
    params.require(:templetes_form)
          .permit(:select_tag_value, :location_name,
                  stock_forms_attributes: [ :name, :model, :exist_quantity, :num_quantity ])
  end

  def set_locations_name
    @locations_name = our_locations.pluck(:name)
  end

  def set_new_stock_forms(forms)
    forms.stock_forms << TempletesStockForm.new(model: 0, exist_quantity: 1)
  end

  def prioritize_location_name(forms, locations_name)
    selected_location = forms.location_name
    locations_name.delete(selected_location)
    locations_name.unshift(selected_location)
  end

  def set_stocks_and_locations
    latest_history = History.latest
    @locations = our_locations.order(:name)
    @stocks = Stock.joins_latest_history(latest_history)
              .merge(our_stocks)
              .order_asc_model_and_name
  end
end
