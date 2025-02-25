require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  browser_mode = (ENV["BROWSER"] == "true") ? :chrome : :headless_chrome
  driven_by :selenium, using: browser_mode, screen_size: [1400, 1400]
end
