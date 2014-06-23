require 'spec'
require 'watir'
#require 'watir\contrib\enabled_popup'
require 'net/http'
require 'uri'

#World do
#  include Spec::Matchers
#
#  Watir::Browser.default = "ie"
#  Watir.options[:speed] = :zippy #:slow
#
#  BBCWW_World.new
#end

class BBCWW_World  
  attr_reader :browser, :environment, :server
  def initialize()
    @browser = Watir::Browser.new
    @environment ||= ("uat.bbcworldwide.com")
    @server = "http://#{environment}/"
  end  
  
end

After do
  browser.close
end

