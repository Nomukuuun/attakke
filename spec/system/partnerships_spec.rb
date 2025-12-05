require 'rails_helper'

RSpec.describe 'パートナー申請', type: :system, js: true do
  let!(:user_a) do
    create(
      :user,
      :google,
      uid: 'system-user-a',
      email: 'partner_a@example.com',
      name: 'ユーザーA'
    )
  end

  let!(:user_b) do
    create(
      :user,
      :google,
      uid: 'system-user-b',
      email: 'partner_b@example.com',
      name: 'ユーザーB'
    )
  end

  def login_via_google(user)
    mock_google_oauth2(uid: user.uid, email: user.email, name: user.name)
    visit root_path
    click_button 'Google でログイン', match: :first
    expect(page).to have_current_path(stocks_path, ignore_query: true)
  end

  def logout
    click_button "menu-button"
    click_button "ログアウト"
    # ログアウト後にトップページへ遷移してログインボタンが表示されるまで最大10秒待つ
    expect(page).to have_button("Google でログイン", wait: 10)
  end

  def open_new_partnership_modal
    visit new_partnerships_path
    expect(page).to have_selector('turbo-frame#modal_frame', wait: 10)
  end

  def open_edit_partnership_modal
    visit edit_partnerships_path
    expect(page).to have_selector('turbo-frame#modal_frame', wait: 10)
  end

  def confirm_modal
    find("button[data-confirm-target='confirmButton']", visible: :all, wait: 5).click
    expect(page).to have_no_selector("button[data-confirm-target='confirmButton']", visible: true, wait: 5)
  end

  def expect_flash_message(text)
    expect(page).to have_selector('div#flash', text: text, wait: 5)
  end

  def send_request_from_a_to_b
    login_via_google(user_a)
    open_new_partnership_modal
    within('turbo-frame#modal_frame') do
      fill_in 'メールアドレス', with: user_b.email
      click_button '申請する'
    end
    expect_flash_message('申請を送信しました')
  end

  it 'AがBに申請するとAの画面には申請中と表示される' do
    send_request_from_a_to_b

    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('パートナー申請中')
      expect(page).to have_button('申請を取り下げる')
    end
  end

  it 'BはAからの申請を受けたとき申請通知を確認できる' do
    send_request_from_a_to_b
    logout

    login_via_google(user_b)
    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('パートナー申請保留中')
      expect(page).to have_content('ユーザーA')
      expect(page).to have_button('承諾する')
      expect(page).to have_button('拒否する')
    end
  end

  it 'Aが申請を取り下げると申請フォームに戻る' do
    send_request_from_a_to_b

    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      click_button '申請を取り下げる'
    end
    confirm_modal
    expect_flash_message('申請を取り下げました')

    open_new_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('パートナー申請')
      expect(page).to have_button('申請する')
    end
  end

  it 'Bが申請を拒否するとB側にも申請フォームが表示される' do
    send_request_from_a_to_b
    logout

    login_via_google(user_b)
    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      click_button '拒否する'
    end
    confirm_modal
    expect_flash_message('申請を拒否しました')

    open_new_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('パートナー申請')
      expect(page).to have_button('申請する')
    end
  end

  it 'Bが申請を承諾すると互いの画面に相手の名前が表示される' do
    send_request_from_a_to_b
    logout

    login_via_google(user_b)
    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      click_button '承諾する'
    end
    confirm_modal
    expect_flash_message('申請を承諾しました')

    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('ユーザーA さん')
    end
    visit stocks_path
    logout

    login_via_google(user_a)
    open_edit_partnership_modal
    within('turbo-frame#modal_frame') do
      expect(page).to have_content('ユーザーB さん')
    end
  end
end
