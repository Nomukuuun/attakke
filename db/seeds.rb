# レコードひな形　{ tag: , l_name: , s_name: , model: , exist_quantity: , num_quantity: },
# stock_model(enum) { existence: 0, number: 1 }

presets = [
  { tag: 1, l_name: "キッチン収納（調味料）", s_name: "醤油", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "キッチン収納（調味料）", s_name: "みりん", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "キッチン収納（調味料）", s_name: "料理酒", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "キッチン収納（調味料）", s_name: "酢", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "キッチン収納（調味料）", s_name: "サラダ油", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 2, l_name: "キッチン収納（消耗品）", s_name: "クッキングシート", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "キッチン収納（消耗品）", s_name: "ラップ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "キッチン収納（消耗品）", s_name: "キッチンペーパー", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "キッチン収納（消耗品）", s_name: "アルミホイル", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "キッチン収納（消耗品）", s_name: "ゴミ袋", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 3, l_name: "冷蔵庫", s_name: "マヨネーズ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫", s_name: "ケチャップ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫", s_name: "卵", model: 1, exist_quantity: nil, num_quantity: 10 },
  { tag: 3, l_name: "冷蔵庫", s_name: "めんつゆ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫", s_name: "ドレッシング", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 4, l_name: "トイレ収納棚", s_name: "トイレットペーパー", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 4, l_name: "トイレ収納棚", s_name: "トイレ用洗剤", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 4, l_name: "トイレ収納棚", s_name: "除菌スプレー", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 4, l_name: "トイレ収納棚", s_name: "生理用品", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 4, l_name: "トイレ収納棚", s_name: "消臭剤", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 5, l_name: "脱衣所", s_name: "シャンプー詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 5, l_name: "脱衣所", s_name: "トリートメント詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 5, l_name: "脱衣所", s_name: "ボディソープ詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 5, l_name: "脱衣所", s_name: "衣類用洗剤詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 5, l_name: "脱衣所", s_name: "柔軟剤詰替", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 6, l_name: "洗面台下収納", s_name: "歯ブラシ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 6, l_name: "洗面台下収納", s_name: "歯磨き粉", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 6, l_name: "洗面台下収納", s_name: "ハンドソープ詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 6, l_name: "洗面台下収納", s_name: "洗顔料", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 6, l_name: "洗面台下収納", s_name: "コットン", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 7, l_name: "リビング収納", s_name: "ティッシュ", model: 1, exist_quantity: nil, num_quantity: 5 },
  { tag: 7, l_name: "リビング収納", s_name: "電池", model: 1, exist_quantity: nil, num_quantity: 4 },
  { tag: 7, l_name: "リビング収納", s_name: "かぜ薬", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 7, l_name: "リビング収納", s_name: "綿棒", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 7, l_name: "リビング収納", s_name: "マスク", model: 0, exist_quantity: 1, num_quantity: nil },
]

presets.each do |p|
  Templete.create!(
    tag: p[:tag],
    location_name: p[:l_name],
    stock_name: p[:s_name],
    stock_model: p[:model],
    history_exist_quantity: p[:exist_quantity],
    history_num_quantity: p[:num_quantity]
  )
end
