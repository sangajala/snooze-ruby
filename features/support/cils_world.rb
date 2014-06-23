class CilsWorld
  attr_reader :browser,
              :a_moment, :a_short_pause, :a_longer_pause,
              :environment_name, :environment

  def initialize
    @default_environment = "uat"
    @a_moment = 0.25
    @a_short_pause = 0.5
    @a_longer_pause = 1
    @scenario_timeout = 600

    environment_key = 'system_environment'
    @environment_name = ENV[environment_key].nil? ? @default_environment : ENV[environment_key]
    #@environment = CilsEnvironment.new(@environment_name)
  end

  def browser
    if(@browser==nil)
      @browser ||= BbcFirefox.new().browser
      @browser
    else
      @browser
    end
  end

  def close_browser
   # First, try to quit the browser the normal way
   begin
     if !@browser.nil?
      # Timeout::timeout(2) { @browser.close }
       @browser.close
        #"#{  @browser = nil
        #   sleep @a_moment }"#makes tests more reliable - give browser time to shutdown
      end
   rescue Timeout::Error
     system("taskkill /im Firefox.exe /f /t >nul 2>&1")
   end
  end
end