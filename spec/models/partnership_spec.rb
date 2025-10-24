require 'rails_helper'

RSpec.describe Partnership, type: :model do
  describe 'パートナーシップバリデーションチェック' do
    it '同一ペアかつ有効期限も等しいレコードは作成できない' do
      user = create(:user)
      partner = create(:user)
      original = create(:partnership, user: user, partner: partner)
      dup = build(:partnership, user: user, partner: partner, expires_at: original.expires_at)
      expect(dup).to be_invalid
      expect(dup.errors[:user_id]).to be_present
    end
  end

  describe 'コールバック' do
    # 共通変数の定義（呼ばれたときにインスタンス作成）
    let(:user) { create(:user) }
    let(:partner) { create(:user) }

    it '作成時にexpires_atが設定されているか' do
      p = create(:partnership, user: user, partner: partner)
      expect(p.expires_at).to be > Time.current
    end

    it '作成時、反対向きのレコードを作成されているか（statusはpending）' do
      p = create(:partnership, user: user, partner: partner)
      inverse = described_class.find_by(user: partner, partner: user)
      expect(inverse).to be_present
      expect(inverse.status).to eq('pending')
    end

    it '更新時、反対向きもapprovedになっているか' do
      p = create(:partnership, user: user, partner: partner)
      p.update!(status: :approved)
      inverse = described_class.find_by(user: partner, partner: user)
      expect(inverse.status).to eq('approved')
    end

    it '削除時、反対向きも削除されているか' do
      p = create(:partnership, user: user, partner: partner)
      p.destroy
      expect(described_class.find_by(user: partner, partner: user)).to be_nil
    end
  end
end
