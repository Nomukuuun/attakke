module StocksHelper
  # ストック数０または購入対象チェックに応じてストックカラーを変更するメソッド
  def set_bg_and_border_color(stock)
    if quantity(stock) == 0 || stock.purchase_target
      "bg-dull-pink border-red-100"
    else
      "bg-dull-sand border-yellow-50"
    end
  end

  def quantity(stock)
    stock.latest_exist_quantity == nil ? stock.latest_num_quantity.to_i : stock.latest_exist_quantity.to_i
  end


  # index画面で〇日前と表示するためのメソッド
  def number_of_days_elapsed(stock)
    return "履歴なし" unless stock.latest_recording_date

    elapsed_days = Date.today - stock.latest_recording_date.to_date
    elapsed_days.to_i == 0 ? "今日" : "#{elapsed_days.to_i}日前"
  end
end
