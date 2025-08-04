module StocksHelper
  # indexアクションで有効なフィルタボタンを活性化するメソッド
  def active_filter_button?(action)
    action_name == action ? "text-white border-dull-green bg-dull-green" : "text-f-head border-black bg-white"
  end
end
