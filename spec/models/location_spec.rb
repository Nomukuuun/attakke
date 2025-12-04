require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }

    it '必須項目がそろえば有効' do
      location = build(:location, user: user, name: '倉庫A')
      expect(location).to be_valid
    end

    it 'nameが空だと無効' do
      location = build(:location, user: user, name: nil)
      expect(location).to be_invalid
      expect(location.errors[:name]).to be_present
    end

    it 'nameが50文字以内なら有効' do
      location = build(:location, user: user, name: 'a' * 50)
      expect(location).to be_valid
    end

    it 'nameが51文字だと無効' do
      location = build(:location, user: user, name: 'a' * 51)
      expect(location).to be_invalid
      expect(location.errors[:name]).to be_present
    end

    it '同じユーザーでnameが重複すると無効' do
      create(:location, user: user, name: '同じ名前')
      dup = build(:location, user: user, name: '同じ名前')
      expect(dup).to be_invalid
      expect(dup.errors[:name]).to be_present
    end

    it '別ユーザーで同じnameなら有効' do
      create(:location, user: user, name: '同じ名前')
      other_user = create(:user)
      another = build(:location, user: other_user, name: '同じ名前')
      expect(another).to be_valid
    end

    it 'userが紐付かないと無効' do
      location = build(:location, user: nil)
      expect(location).to be_invalid
      expect(location.errors[:user]).to be_present
    end
  end
end
