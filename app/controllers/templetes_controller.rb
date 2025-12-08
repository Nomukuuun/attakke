class TempletesController < ApplicationController
  include SetLocationsAndStocks
  include HouseholdResources
  include Broadcaster

  before_action :set_household_locations_and_stocks, only: %i[create]

  def index
    build_how_to_create_options
  end


  # セレクトボックスの選択に応じてstimulusでフォーム切替
  def form
    session[:how_to_create] = select_tag_params[:how_to_create] || ""

    build_initial_forms

    render turbo_stream: turbo_stream.replace(
      "templete_form_frame",
      partial: "templetes/form",
      locals: { forms: @forms, locations_name: @locations_name }
    )
  end


  def create
    @forms = TempletesForm.new(templetes_form_params, user: current_user)

    if @forms.save

      broadcaster.add_location(@locations, @stocks, @forms.location)
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")

    else
      set_locations_name if session[:how_to_create] == "【まとめて追加】"
      render turbo_stream: turbo_stream.replace("templete_form_frame", partial: "templetes/form", locals: { forms: @forms, locations_name: @locations_name }), status: :unprocessable_entity
    end
  end

  # NOTE: 以下privateメソッド
  private

  # セレクトボックスで選択した作成方法を受け取る
  def select_tag_params
    params.permit(:how_to_create)
  end

  # フォームからの入力値を受け取る
  def templetes_form_params
    params.require(:templetes_form)
          .permit(:location_name, stock_forms_attributes: [ :name, :model, :exist_quantity, :num_quantity ])
  end

  def build_how_to_create_options
    @how_to_create = [ "【新規作成】" ]
    @how_to_create << "【まとめて追加】" if household_locations.present?
    @how_to_create.concat(Templete.prefixed_location_names_array)
  end

  def build_initial_forms
    case select_tag_params[:how_to_create]
    when "【新規作成】"
      build_new_forms
    when "【まとめて追加】"
      build_new_forms
      set_locations_name
    else # テンプレートの呼び出し
      location_name = select_tag_params[:how_to_create].delete_prefix("<テンプレ> ").strip
      @forms = TempletesForm.new({ location_name: location_name })

      @forms.stock_forms.concat(
        Templete.with_location_name(location_name).map do |t|
          TempletesStockForm.new(
            name: t.stock_name,
            model: t.stock_model,
            exist_quantity: t.history_exist_quantity,
            num_quantity: t.history_num_quantity,
          )
        end
      )
    end
  end

  def build_new_forms
    @forms = TempletesForm.new({ location_name: nil })
    @forms.stock_forms << TempletesStockForm.new(model: 0, exist_quantity: 1)
  end

  def set_locations_name
    @locations_name = household_locations.order(:name).pluck(:name)
  end
end
