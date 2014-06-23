require 'watir'
require 'selenium-webdriver'

class BbcFirefox
  attr_reader :browser

  def initialize
    @browser = create_firefox()
    @browser.driver.manage.timeouts.page_load = 120
    @browser.driver.manage.timeouts.implicit_wait = 120
  end


  private

  def create_firefox
    profile = Selenium::WebDriver::Firefox::Profile.new

    # disable autoupdate
    profile['app.update.auto'] = false
    profile['app.update.enabled'] = false

    #enable ntlm
    profile['network.automatic-ntlm-auth.allow-non-fqdn'] = true
    profile['network.negotiate-auth.allow-non-fqdn']  = true
   # profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = $saved_path
    profile['browser.download.folderList'] = 2
    profile['browser.download.manager.showWhenStarting'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/x-msdownload"
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['services.sync.prefs.sync.browser.download.manager.showWhenStarting'] = false
   # profile['browser.helperApps.neverAsk.saveToDisk'] = "text/comma-separated-values"
        #get proxy from environment variable
    proxy = Selenium::WebDriver::Proxy.new(:http => ENV['HTTP_PROXY'] || ENV['http_proxy'])
    ENV['HTTP_PROXY'] = ENV['http_proxy'] = nil

    #create a new firefox instance
    Watir::Browser.new :firefox, :proxy => proxy, :profile => profile
  end
end