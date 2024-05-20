require 'byebug'
begin
  require 'capybara-playwright-driver'
rescue LoadError
end

require "capybara-lockstep"
require 'capybara'
require 'capybara/rspec'
require "rspec/wait"
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/numeric'
require 'base64'

# Load all files in spec/support
Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }



RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.before(:each) { App.reset }
  config.wait_timeout = 5
  config.wait_delay = 0.02
end

if defined?(Selenium::WebDriver)
  options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless') unless ENV['NO_HEADLESS']
    opts.add_argument('--window-size=1280,1024')
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [options])
  end

  Capybara.default_driver = :chrome
end

if defined?(Capybara::Playwright::Driver)
  Capybara.register_driver :playwright do |app|
    Capybara::Playwright::Driver.new(app, browser: :chromium, headless: !ENV['NO_HEADLESS'], viewport: { width: 1280, height: 1024 })
  end

  Capybara.default_driver = :playwright
end

Capybara.configure do |config|
  config.app = App
  config.server_host = 'localhost'
  config.default_max_wait_time = 1
end

RSpec.configure do |config|
  config.before(:each) do
    Capybara::Lockstep.wait_tasks = nil
    Capybara::Lockstep.timeout = 5
    Capybara::Lockstep.debug = false
    Capybara::Lockstep.mode = :auto
  end
end
