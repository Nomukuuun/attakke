require 'capybara/rspec'
require 'selenium-webdriver'

# server_hostは自身のIPアドレスを返す。
# 以下の３行でseleniumコンテナで動作しているブラウザにアクセスするための情報を指定
Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
Capybara.server_port = 4444
Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

# Capybaraに、selenium_remote_chromeという名前のdriverを登録する
Capybara.register_driver :selenium_remote_chrome do |app|
  url = ENV.fetch('SELENIUM_REMOTE_URL', 'http://selenium:4444')
  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument('--headless=new')
  opts.add_argument('--no-sandbox')
  opts.add_argument('--disable-dev-shm-usage')
  opts.add_argument('--disable-gpu')
  opts.add_argument('--window-size=1400,900')
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, options: opts)
end

# typeがsystemの各テストファイルについて、js: trueがついているならドライバーにseleniumを使う
# headless_chromeは画面表示を持たないGoogle Chrome
RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    if example.metadata[:js]
      if ENV['SELENIUM_REMOTE_URL']
        driven_by(:selenium_remote_chrome)
      else
        driven_by(:selenium, using: :headless_chrome, screen_size: [1400, 900])
      end
    else
      driven_by(:rack_test)
    end
  end
end
