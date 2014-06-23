
#add the cils world to all scenarios
World(){ SalesProjectionsWorld.new() }

Before do

end

After do |scenario|
  if scenario.failed?
    screenshot = "./FAILED_#{scenario.name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"
    @browser.driver.save_screenshot(screenshot)
    encoded_img = @browser.driver.screenshot_as(:base64)
    embed("data:image/png;base64,#{encoded_img}",'image/png')
  end

  close_browser
end

def at_start # not a special method like at_exit so we call it below!

end
at_start()

# At the end of everything kill all IE in case anything went wrong
at_exit do
  system("taskkill /im Firefox.exe /f /t >nul 2>&1")
end
