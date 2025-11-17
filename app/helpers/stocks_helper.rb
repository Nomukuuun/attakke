module StocksHelper
  # NOTE: リストラベルに関するヘルパー
  def set_button_design(list_type)
    defaults = "bg-white hover:bg-dull-green/70 hover:text-f-head/70 shadow-sm mx-[3px] mb-[3px] p-[6.5px]"
    active = "bg-dull-green text-white p-2"
    button_design = { all: defaults, shopping: defaults }

    list_type == "all" ? button_design[:all] = active : button_design[:shopping] = active
    button_design
  end

  # NOTE: 以下、ストックカードに関するヘルパー
  # どのアクションから来たのか判定するメソッド
  def set_action_type
    if action_name.in?(%w[new create])
      "新規"
    elsif action_name.in?(%w[edit update])
      "更新"
    else
      "その他" # どれにも当てはまらない場合のフォールバック
    end
  end

  # ストック数０または購入対象チェックに応じてストックカードカラーを変更するメソッド
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
