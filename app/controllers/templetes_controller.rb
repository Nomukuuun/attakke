class TempletesController < ApplicationController
  include SetStocksAndLocations
  include Broadcast

  before_action :set_locations_and_stocks, only: %i[create]


  # 「新規作成・まとめて追加」で初期表示するセレクトボックスをセット
  def index
    @locations_name = [ "【新規作成】" ]
    @locations_name << "【既存保管場所にまとめて追加】" if our_locations.present?
    @locations_name.concat(Templete.select(:location_name, :id)
                              .group_by(&:location_name)
                              .values
                              .map { |records| "<テンプレ> " + records.min_by(&:id).location_name })
  end


  # セレクトボックスの選択に応じてstimulusでフォーム切替
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
      # 保管場所が1つも存在しない場合、ベース画面に新規作成を促すメッセージが表示されている
      # 当該メッセージを非表示にするために更新範囲を変更する
      if our_locations.count == 1
        broadcast.replace_main_frame(@locations, @stocks)
      else
        broadcast.prepend_location(@forms.location, @stocks)
      end
      flash.now[:success] = t("defaults.flash_message.created", item: t("defaults.models.stock"))
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
    else
      # まとめて追加を選択している場合、保管場所名のセレクトボックスを保存失敗状態で再表示できるように配列をセット
      select_tag_value = templetes_form_params[:select_tag_value]
      if select_tag_value == "【既存保管場所にまとめて追加】"
        set_locations_name
        prioritize_selected_location(@forms, @locations_name)
        @forms.location_name = select_tag_value
      end
      render turbo_stream: turbo_stream.update("templete_form_frame", partial: "templetes/form", locals: { forms: @forms, locations_name: @locations_name }), status: :unprocessable_entity
    end
  end

  # NOTE: 以下privateメソッド
  private

  # 初期画面のセレクトボックスで選択した作成方法を受け取る
  def templete_params
    params.permit(:location_name)
  end

  # フォームからの入力値を受け取る
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

  # まとめて追加で保存に失敗したときに、選択値を先頭に持ってきて再表示するためのメソッド
  def prioritize_selected_location(forms, array)
    selected_location = forms.location_name
    array.delete(selected_location)
    array.unshift(selected_location)
  end
end
