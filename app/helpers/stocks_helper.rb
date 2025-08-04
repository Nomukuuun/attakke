module StocksHelper
  # indexアクションで有効なフィルタボタンを活性化するメソッド
  def active_filter_button?(action)
    action_name == action ? "text-white border-dull-green bg-dull-green hover:brightness-70" : "text-f-head border-black bg-white hover:text-white hover:bg-dull-green hover:border-dull-green"
  end
end
