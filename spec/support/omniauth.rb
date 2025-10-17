require 'omniauth'

# 外部通信せずにmockデータで認証をテストするための設定
OmniAuth.config.test_mode = true

def mock_google_oauth2(uid: '1234567890', email: 'test@example.com', name: 'Test User')
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: uid,
    info: {
      email: email,
      name: name
    }
  )
end

RSpec.configure do |config|
  config.before do
    # 既定は正常系のモック
    mock_google_oauth2
  end

  config.after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end

