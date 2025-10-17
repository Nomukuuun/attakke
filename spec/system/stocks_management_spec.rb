require 'rails_helper'

RSpec.describe 'ログイン後のストック操作', type: :system, js: true do
  let(:user) do
    create(
      :user,
      :google,
      uid: 'system-user',
      email: 'system@example.com',
      name: 'システムユーザー'
    )
  end

  def login_via_google
    mock_google_oauth2(uid: user.uid, email: user.email, name: user.name)
    visit root_path
    click_button 'Google でログイン'
    expect(page).to have_current_path(stocks_path, ignore_query: true)
  end

  context 'フッターメニューから新規作成する場合' do
    it '保管場所とストックを新規作成できる' do
      user
      login_via_google

      # 初期画面には「新規作成・まとめて追加」ボタンが２つあるが、リンク先は同じ
      click_on '新規作成・まとめて追加', match: :first

      # turbo-frameタグのidにmodal_frameを持つ要素のみをテスト
      within('turbo-frame#modal_frame') do
        select '【新規作成】', from: '作成方法'
      end

      within('turbo-frame#templete_form_frame') do
        expect(page).to have_field('保管場所名')
        fill_in '保管場所名', with: 'キッチン'
        find("input[name='templetes_form[stock_forms_attributes][0][name]']").set('スポンジ')
        click_button '保存'
      end

      # フラッシュメッセージの確認
      expect(page).to have_content('ストックを作成しました')

      visit stocks_path
      expect(page).to have_content('キッチン')
      expect(page).to have_content('スポンジ')
    end
  end

  context '既存ストックを編集する場合' do
    let!(:location) { create(:location, user: user, name: 'キッチン') }
    let!(:stock) { create(:stock, user: user, location: location, name: 'スポンジ', model: :existence) }
    let!(:history) { create(:history, stock: stock, exist_quantity: 1) }

    it 'ストック名、型、状態を更新できる' do
      login_via_google

      click_link 'スポンジ'

      within('turbo-frame#modal_frame') do
        fill_in 'ストック名', with: 'スポンジ（大）'
        find("input[type='radio'][value='number']").click
        fill_in 'ストックの個数', with: 5

        click_button '保存'
      end

      expect(page).to have_content('ストックを更新しました')

      visit stocks_path
      expect(page).to have_content('スポンジ（大）')
      within("turbo-frame#stock_#{stock.id}") do
        expect(page).to have_content('残5')
      end

      stock.reload
      expect(stock.model).to eq('number')
      expect(stock.histories.order(:id).last.num_quantity).to eq(5)
    end
  end

  context 'ストックを削除する場合' do
    let!(:location) { create(:location, user: user, name: 'キッチン') }
    let!(:stock) { create(:stock, user: user, location: location, name: '洗剤', model: :existence) }
    let!(:history) { create(:history, stock: stock, exist_quantity: 1) }

    it 'stock部分テンプレートのアイコンから削除できる' do
      login_via_google

      # ゴミ箱アイコンはlink_toヘルパーの中にあるため、aタグを指定してクリック
      within("turbo-frame#stock_#{stock.id}") do
        find("a[data-turbo-method='delete']").click
      end

      click_button '削除'
      expect(page).to have_content('ストックを削除しました')

      visit stocks_path
      expect(page).to have_no_content('洗剤')
      expect(Stock.exists?(stock.id)).to be_falsey
    end
  end

  context 'フィルタリングを行う場合' do
    let!(:location) { create(:location, user: user, name: 'キッチン') }
    let!(:stock_in) { create(:stock, user: user, location: location, name: 'スポンジ', model: :existence) }
    let!(:history_in) { create(:history, stock: stock_in, exist_quantity: 1) }
    let!(:stock_out) { create(:stock, user: user, location: location, name: 'タオル', model: :existence) }
    let!(:history_out) { create(:history, stock: stock_out, exist_quantity: 0, status: :consumption) }

    it '在庫あり/なし/すべてを切り替えられる' do
      login_via_google

      within('turbo-frame#main_frame') do
        expect(page).to have_content('スポンジ')
        expect(page).to have_content('タオル')
      end

      select 'あり', from: 'filter'
      within('turbo-frame#main_frame') do
        expect(page).to have_content('スポンジ')
        expect(page).to have_no_content('タオル')
      end

      select 'なし', from: 'filter'
      within('turbo-frame#main_frame') do
        expect(page).to have_content('タオル')
        expect(page).to have_no_content('スポンジ')
      end

      select 'すべて', from: 'filter'
      within('turbo-frame#main_frame') do
        expect(page).to have_content('スポンジ')
        expect(page).to have_content('タオル')
      end
    end
  end

  context 'ストックを検索する場合' do
    let!(:location) { create(:location, user: user, name: 'キッチン') }
    let!(:target_stock) { create(:stock, user: user, location: location, name: '食器用スポンジ', model: :existence) }
    let!(:target_history) { create(:history, stock: target_stock, exist_quantity: 1) }
    let!(:other_stock) { create(:stock, user: user, location: location, name: 'ラップ', model: :existence) }
    let!(:other_history) { create(:history, stock: other_stock, exist_quantity: 1) }

    it '部分一致でヒットしたストックのみ表示される' do
      login_via_google

      fill_in 'ストック名で検索', with: 'スポン'
      find("button#search_button").click

      within('turbo-frame#main_frame') do
        expect(page).to have_content('食器用スポンジ')
        expect(page).to have_no_content('ラップ')
      end
    end
  end
end
