require 'rails_helper'

RSpec.describe 'Googleログイン', type: :system do
  it '新規ユーザーとしてGoogle認証でログインできる' do
    mock_google_oauth2(uid: 'sys-new-uid', email: 'sys-new@example.com', name: 'System New')

    expect {
      visit root_path
      click_button 'Google でログイン'
    }.to change(User, :count).by(1) # userが１件増えているか確認

    # クエリを無視したパスがstocks_pathと等しいか確認
    expect(page).to have_current_path(stocks_path, ignore_query: true)
  end

  it '既存ユーザーは作成されずにログインできる' do
    create(:user, :google, uid: 'sys-exists', email: 'exists@example.com', name: 'Exists User')
    mock_google_oauth2(uid: 'sys-exists', email: 'exists@example.com', name: 'Exists User')

    expect {
      visit root_path
      click_button 'Google でログイン'
    }.not_to change(User, :count)

    expect(page).to have_current_path(stocks_path, ignore_query: true)
  end
end
