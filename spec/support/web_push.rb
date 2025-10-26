RSpec.configure do |config|
  config.before(:each) do
    allow(WebPush).to receive(:payload_send).and_return(true)
  end
end
