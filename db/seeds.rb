# レコードひな形　{ tag: , l_name: , s_name: , model: , exist_quantity: , num_quantity: },
# stock_model(enum) { existence: 0, number: 1 }

presets = [
  { tag: 1, l_name: "IH/ガスコンロ下収納", s_name: "醤油", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "IH/ガスコンロ下収納", s_name: "みりん", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "IH/ガスコンロ下収納", s_name: "料理酒", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "IH/ガスコンロ下収納", s_name: "酢", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 1, l_name: "IH/ガスコンロ下収納", s_name: "サラダ油", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 2, l_name: "脱衣所", s_name: "シャンプー詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "脱衣所", s_name: "トリートメント詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "脱衣所", s_name: "ボディソープ詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "脱衣所", s_name: "衣類用洗剤詰替", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 2, l_name: "脱衣所", s_name: "柔軟剤詰替", model: 0, exist_quantity: 1, num_quantity: nil },

  { tag: 3, l_name: "冷蔵庫内", s_name: "マヨネーズ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫内", s_name: "ケチャップ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫内", s_name: "卵", model: 1, exist_quantity: nil, num_quantity: 10 },
  { tag: 3, l_name: "冷蔵庫内", s_name: "めんつゆ", model: 0, exist_quantity: 1, num_quantity: nil },
  { tag: 3, l_name: "冷蔵庫内", s_name: "ドレッシング", model: 0, exist_quantity: 1, num_quantity: nil },
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
