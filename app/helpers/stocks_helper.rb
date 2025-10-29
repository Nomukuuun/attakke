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

  # フィルタリングボタンのデザインを決定するメソッド
  def set_button_design(filtering)
    defaults = "bg-white hover:bg-dull-green/70 hover:text-f-head/70"
    active = "bg-dull-green text-white"
    button_design = { all: defaults, out: defaults, in: defaults }

    case filtering
    when "all"
      button_design[:all] = active
    when "out"
      button_design[:out] = active
    when "in"
      button_design[:in] = active
    end

    button_design
  end

  # index画面で〇日前と表示するためのメソッド
  def number_of_days_elapsed(stock)
    return "履歴なし" unless stock.latest_recording_date

    elapsed_days = Date.today - stock.latest_recording_date.to_date
    elapsed_days.to_i == 0 ? "今日" : "#{elapsed_days.to_i}日前"
  end
end
