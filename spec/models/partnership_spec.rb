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

  describe '双方向レコードチェック' do
    # 共通変数の定義（呼ばれたときにインスタンス作成）
    let(:user) { create(:user) }
    let(:partner) { create(:user) }

    it '作成時にexpires_atが設定されているか' do
      applicant = create(:partnership, user: user, partner: partner)
      expect(applicant.expires_at).to be > Time.current
    end

    it '作成時に双方向のレコードが作成されているか' do
      described_class.create_request_pair!(user, partner)
      applicant = described_class.find_by(user: user, partner: partner)
      recipient = described_class.find_by(user: partner, partner: user)
      expect(applicant.status).to eq('sended')
      expect(recipient.status).to eq('pending')
    end

    it '更新時に双方向のレコードが承認されているか' do
      described_class.create_request_pair!(user, partner)
      applicant = described_class.find_by(user: user, partner: partner)
      recipient = described_class.find_by(user: partner, partner: user)
      recipient.approve_pair!
      applicant.reload
      recipient.reload # リロードすることでメモリ上の古いデータを読み込むことを防ぐ
      expect(applicant.status).to eq('approved')
      expect(recipient.status).to eq('approved')
    end

    it '削除時に双方向のレコードが削除されているか' do
      described_class.create_request_pair!(user, partner)
      applicant = described_class.find_by(user: user, partner: partner)
      recipient = described_class.find_by(user: partner, partner: user)
      recipient.approve_pair!
      applicant.destroy_pair!
      expect(described_class.find_by(id: applicant.id)).to be_nil
      expect(described_class.find_by(id: recipient.id)).to be_nil
    end
  end
end
