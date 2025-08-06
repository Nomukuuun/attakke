module TempletesHelper
  # indexアクションでstock_modelに応じて表示を分けるメソッド
  def displey_quantity(t)
    if t.history_exist_quantity.present?
      t.history_exist_quantity == 1 ? "ストックあり" : "ストックなし"
    else
      "残#{t.history_num_quantity}"
    end
  end
end
