require 'rails_helper'

RSpec.describe History, type: :model do
  describe '正しいstatusとquantityが設定されているか' do
    it 'existence型はexist_quantityを数量として扱い、num_quantityはnilでセットされているか' do
      stock = create(:stock, model: :existence)
      history = build(:history, stock: stock, exist_quantity: 1, num_quantity: 5)
      expect(history).to be_valid # この時点では保存してないためエラーは発生しない
      history.save!
      expect(history.quantity).to eq(1) # 使う型の数量のみが取得できるか
      expect(history.num_quantity).to be_nil
    end

    it 'number型はnum_quantityを数量として扱い、exist_quantityはnilでセットされているか' do
      stock = create(:stock, model: :number)
      history = build(:history, stock: stock, exist_quantity: 1, num_quantity: 3)
      expect(history).to be_valid
      history.save!
      expect(history.quantity).to eq(3)
      expect(history.exist_quantity).to be_nil
    end
  end
end
