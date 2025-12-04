require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:location) { create(:location, user: user) }

    it '必須項目がそろえば有効で、purchase_targetはtrue/falseどちらでも通る' do
      stock = build(:stock, user: user, location: location, name: 'ストック', model: :existence, purchase_target: true)
      expect(stock).to be_valid
      stock.purchase_target = false
      expect(stock).to be_valid
    end

    it 'nameが空だと無効' do
      stock = build(:stock, user: user, location: location, name: nil)
      expect(stock).to be_invalid
      expect(stock.errors[:name]).to be_present
    end

    it 'nameが50文字以内なら有効' do
      stock = build(:stock, user: user, location: location, name: 'a' * 50)
      expect(stock).to be_valid
    end

    it 'nameが51文字だと無効' do
      stock = build(:stock, user: user, location: location, name: 'a' * 51)
      expect(stock).to be_invalid
      expect(stock.errors[:name]).to be_present
    end

    it 'modelがnilだと無効' do
      stock = build(:stock, user: user, location: location, model: nil)
      expect(stock).to be_invalid
      expect(stock.errors[:model]).to be_present
    end

    it 'purchase_targetがnilだと無効' do
      stock = build(:stock, user: user, location: location, purchase_target: nil)
      expect(stock).to be_invalid
      expect(stock.errors[:purchase_target]).to be_present
    end

    it 'userが紐付かないと無効' do
      stock = build(:stock, user: nil, location: location)
      expect(stock).to be_invalid
      expect(stock.errors[:user]).to be_present
    end

    it 'locationが紐付かないと無効' do
      stock = build(:stock, user: user, location: nil)
      expect(stock).to be_invalid
      expect(stock.errors[:location]).to be_present
    end
  end
end
