require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザーバリデーションチェック' do
    it 'ユーザー名、メールアドレスありで正常登録' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'ユーザー名なしエラー' do
      user = build(:user, name: nil)
      expect(user).to be_invalid
      expect(user.errors[:name]).to be_present
    end

    it 'メールアドレスなしエラー' do
      user = build(:user, email: nil)
      expect(user).to be_invalid
      expect(user.errors[:email]).to be_present
    end

    it 'メールアドレス重複エラー' do
      create(:user, email: 'dup@example.com')
      dup = build(:user, email: 'dup@example.com')
      expect(dup).to be_invalid
      expect(dup.errors[:email]).to be_present
    end

    it 'uidとproviderの複合キーが一意でないエラー' do
      create(:user, :google, uid: 'same-uid', provider: 'google_oauth2')
      user = build(:user, :google, uid: 'same-uid', provider: 'google_oauth2')
      expect(user).to be_invalid
      expect(user.errors[:uid]).to be_present
    end

    it 'uidがnilなら複合キーエラーにならない' do
      create(:user, provider: 'google_oauth2', uid: nil)
      another = build(:user, provider: 'google_oauth2', uid: nil)
      expect(another).to be_valid
    end
  end

  describe 'パートナーシップチェック' do
    it '単身者ストリームキーチェック' do
      user = create(:user)
      expect(user.partnership_stream_key).to eq(user.id.to_s)
    end

    it 'パートナーストリームキーチェック' do
      user = create(:user)
      partner = create(:user)
      # 双方向パートナーを作る（approvedにして明示的にパートナーを紐付け）
      p = create(:partnership, user: user, partner: partner, status: :approved)
      # 逆側もapprovedになる
      expect(user.reload.partnership_stream_key).to eq([ user.id, partner.id ].compact.sort.join("_"))
    end
  end

  describe 'Google認証チェック' do
    it '新規ユーザーを作成する' do
      auth = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'new-uid',
        info: { email: 'new@example.com', name: 'New User' }
      )

      user = described_class.from_omniauth(auth)

      expect(user).to be_persisted # userが保存されていることを期待
      expect(user.email).to eq('new@example.com')
      expect(user.name).to eq('New User')
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('new-uid')
    end

    it '既存ユーザーを返す' do
      existing = create(:user, :google, uid: 'exists', email: 'exists@example.com', name: 'Exists')
      auth = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'exists',
        info: { email: 'exists@example.com', name: 'Exists' }
      )

      user = described_class.from_omniauth(auth)
      expect(user.id).to eq(existing.id)
    end
  end
end
