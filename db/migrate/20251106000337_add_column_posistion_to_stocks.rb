class AddColumnPosistionToStocks < ActiveRecord::Migration[7.2]
  # update_columnやchange_column_nullは非可逆のため、up/downで明示的に処理を記述
  def up
    add_column :stocks, :position, :integer

    # モデルを使ったループ処理だと更新作業が失敗しやすいためSQL文に変更
    say_with_time "Setting initial positions for stocks" do
      execute <<~SQL
        UPDATE stocks
        SET position = sub.rn
        FROM (
          SELECT id, ROW_NUMBER() OVER (PARTITION BY location_id ORDER BY model, name) AS rn
          FROM stocks
        ) AS sub
        WHERE stocks.id = sub.id;
      SQL

      # 空のpositionが発生しないように救済処置
      execute "UPDATE stocks SET position = id WHERE position IS NULL;"
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
