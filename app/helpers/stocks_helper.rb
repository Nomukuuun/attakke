module StocksHelper
  # turbo、broadcastどちらでもセッション値を扱えるようにするメソッド
  def fetch_list_type_session_value(list_type)
    current_list_type_value || list_type
  end

  def fetch_sort_mode_session_value(sort_mode)
    current_sort_mode_value || sort_mode
  end


  # ストック数０または購入対象チェックに応じてストックカラーを変更するメソッド
  def set_stock_card_design(stock)
    if quantity(stock) == 0 || stock.purchase_target
      "bg-dull-pink"
    else
      "bg-dull-sand"
    end
  end

  def quantity(stock)
    stock.latest_exist_quantity == nil ? stock.latest_num_quantity.to_i : stock.latest_exist_quantity.to_i
  end


  # フィルタリングボタンのデザインを決定するメソッド
  def set_button_design(list_type)
    defaults = "bg-white hover:bg-dull-green/70 hover:text-f-head/70"
    active = "bg-dull-green text-white"
    button_design = { all: defaults, shopping: defaults }

    list_type == "all" ? button_design[:all] = active : button_design[:shopping] = active
    button_design
  end


  # ストックのアイコン、残数をどのように表示するか返す判定ロジック
  def set_icon_info(stock, sort_mode)
    model = stock.model
    status = if model == "existence"
      stock.latest_exist_quantity == 1 ? "on" : "off"
    else
      "number"
    end
    info = [ model, status, sort_mode]

    case info
    when [ "existence", "on"    , "on"  ]
      "disable_check"
    when [ "existence", "on"    , "off" ]
      "check"
    when [ "existence", "off"   , "on"  ]
      "disable_none"
    when [ "existence", "off"   , "off" ]
      "none"
    when [ "number"   , "number", "on"  ]
      "disable_number"
    when [ "number"   , "number", "off" ]
      "number"
    else
      "unknown" # どれにも当てはまらない場合のフォールバック
    end
  end


  # index画面で〇日前と表示するためのメソッド
  def number_of_days_elapsed(stock)
    return "履歴なし" unless stock.latest_recording_date

    elapsed_days = Date.today - stock.latest_recording_date.to_date
    elapsed_days.to_i == 0 ? "今日" : "#{elapsed_days.to_i}日前"
  end
end
