class Stocks::SortsController < ApplicationController
  include SetLocationsAndStocks
  include Broadcast

  before_action :set_locations_and_searchable_stocks, only: %i[sort_mode]
  before_action :set_locations_and_stocks, only: %i[sort rearrange]

  # 並べ替えは「買いものリスト」へ反映しないためbroadcastしない
  def sort_mode
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update("sort_mode", partial: "shared/sort_mode"),
          turbo_stream.update("search_form", partial: "stocks/search_form", locals: { q: @q }),
          turbo_stream.update("main_frame", partial: "stocks/main_frame", locals: { stocks: @stocks, locations: @locations }),
          turbo_stream.update("footer_menu", partial: "shared/footer_menu")
        ]
      }
      format.html {
        render :index
      }
    end
  end

  # ソートアイコンをドラックアンドドロップで並び替えるためのアクション
  def sort
    ids = sort_params[:stock_ids]
    location = our_locations.find(sort_params[:location_id])
    ids.each_with_index do |id, index|
      our_stocks.find(id).insert_at(index + 1)
    end

    render turbo_stream: turbo_stream.replace("location_#{location.id}", partial: "stocks/location", locals: { location: location, stocks: @stocks })
  end

  # 配置換えソートを行うためのアクション
  def rearrange
    stock = our_stocks.find(params[:id])
    before_id, after_id = rearrange_params[:location_ids] # location_idsを分割代入
    stock.update!(location_id: after_id)
    stock.insert_at(rearrange_params[:new_position].to_i)

    before_location = our_locations.find(before_id)
    after_location = our_locations.find(after_id)
    flash.now[:success] = t("defaults.flash_message.updated", item: t("defaults.models.location"))
    render turbo_stream: [
      turbo_stream.replace("location_#{before_location.id}", partial: "stocks/location", locals: { location: before_location, stocks: @stocks }),
      turbo_stream.replace("location_#{after_location.id}", partial: "stocks/location", locals: { location: after_location, stocks: @stocks })
    ]
  end

  private

  # 配列パラメータは[]が必要かつ、最後に記述する
  def sort_params
    params.permit(:location_id, stock_ids: [])
  end

  def rearrange_params
    params.permit(:new_position, location_ids: [])
  end
end
