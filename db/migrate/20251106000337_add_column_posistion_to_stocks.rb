class AddColumnPosistionToStocks < ActiveRecord::Migration[7.2]
  # update_columnやchange_column_nullは非可逆のため、up/downで明示的に処理を記述
  def up
    add_column :stocks, :position, :integer

    # 既存レコードに初期値を設定（say_with_timeで実行時間を出力する）
    say_with_time "Setting initial positions for stocks" do
      # 保管場所ごとにpositionをリセット
      Location.find_each do |location|
        # 現在のデフォルトの並び順を崩さないようstocksを取得
        stocks = location.stocks.order(:model, :name)
        # positionに1から連番を振る
        stocks.each.with_index(1) do |stock, index|
          stock.update_column(:position, index)
        end
      end
    end

    # 新規レコードはpositionにnull:falseを指定
    change_column_null :stocks, :position, false
    # 並び替え高速化のため複合インデックスを付与
    add_index :stocks, [:location_id, :position]
  end

  def down
    remove_index :stocks, [:location_id, :position]
    remove_column :stocks, :position
  end
end
