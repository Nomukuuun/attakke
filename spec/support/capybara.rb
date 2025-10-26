require 'capybara/rspec'
require 'selenium-webdriver'
require 'socket'
require 'uri'

Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 5

def selenium_remote_available?
  return false if ENV['SELENIUM_REMOTE_URL'].blank?

  uri = URI.parse(ENV['SELENIUM_REMOTE_URL'])
  Socket.tcp(uri.host, uri.port, connect_timeout: 1) { true }
rescue StandardError
  false
end

Capybara.register_driver :selenium_remote_chrome do |app|
  url = ENV.fetch('SELENIUM_REMOTE_URL')
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,900')
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, options: options, timeout: 120)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    if example.metadata[:js]
      if selenium_remote_available?
        Capybara.server_host = '0.0.0.0'
        Capybara.server_port = Integer(ENV.fetch('CAPYBARA_SERVER_PORT', '3001'))
        Capybara.app_host = ENV['CAPYBARA_APP_HOST'] || "http://#{IPSocket.getaddress(Socket.gethostname)}:#{Capybara.server_port}"
        driven_by(:selenium_remote_chrome)
      else
        Capybara.server_host = nil
        Capybara.server_port = nil
        Capybara.app_host = nil
        driven_by(:selenium, using: :headless_chrome, screen_size: [1400, 900])
      end
    else
      driven_by(:rack_test)
    end
  end
end
