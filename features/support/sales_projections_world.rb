require 'yaml'
#require 'Win32API'
require 'spec'
#require 'win32ole'
#include Spec::Matchers
#require File.join(File.dirname(__FILE__), '../cils_step_definitions/common/multi_browser_module.rb')
#require File.join(File.dirname(__FILE__), '../cils_step_definitions/common/cils_world.rb')
require File.join(File.dirname(__FILE__), '/cils_world.rb')
class SalesProjectionsWorld < CilsWorld
  attr_reader :current_user_name,
              :default_currency,
              :default_rate

  def initialize
    smoke_flag = ENV['smoke'].nil? ? "false" : ENV['smoke']
    @is_smoke = "true".eql?(smoke_flag)
    @request_type = @is_smoke ? 'smoke' : 'site'
    #Database::SalesProjectionDatabase.set_smoke_filter(@is_smoke)

    #network=WIN32OLE.new("Wscript.Network")
    #@current_user_name = network.username

    @default_currency = 'EUR'
    @default_rate = 1.0

    directory_name = "C:\\webdriver-temp"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    $saved_path = 'C:\\webdriver-temp\\'+DateTime.now.iso8601.gsub("-","").gsub(":","").gsub("+","")
    Dir::mkdir($saved_path)
    $ic_date = '09/09/2013'
    $title = 'UNLOCKING SHERLOCK'

    environment_key = 'salesprojections_environment'
    #@environment = ENV[environment_key].nil? ? :localhost : ENV[environment_key].to_sym
    @environment = ENV[environment_key].nil? ? :systest : ENV[environment_key].to_sym

    @sales_projections = YAML.load_file( File.join(File.dirname(__FILE__), 'config.yaml'))
    ENV['cils_environment'] = settings[:cils_environment]

    establish_service_desk_connection
    super
  end

  def user_settings
    value = @sales_projections[@current_user_name.downcase.to_sym] if @environment == :localhost
    value = {} if(value.nil?)
    value
  end

  def settings
    default_settings = @sales_projections[:default]
    raise "No settings exist for the environment #{@environment}" if not @sales_projections.has_key?(@environment)
    environment_settings = @sales_projections[@environment]

    default_settings.merge(environment_settings).merge(user_settings)
	end        

  def database
    settings[:database]
  end

  def sales_projections_server
    settings[:server]
  end

  def sales_projections_qualified_server
    settings[:fqdn]
  end

  def sales_content_users_group
    settings[:content_users_group]
  end

  def sales_projections_environment_group
    settings[:active_directory_group]
  end


  def snooze_base_url
    #"http://#{settings[:server]}:#{settings[:port]}/#{@request_type}"
    "http://tvishitech.com/webdev/snooze/index.php"
    #"http://cils-ui-systest:39001/web/ui/home.html"
  end

   def establish_service_desk_connection()
    #Database::SalesProjectionDatabase.establish_connection(
    #  {:adapter=>'sqlserver'}.merge(database)
    #)
   end

  def get_lookups
     SalesProjectionsLookup.create(browser, snooze_base_url)
  end
end


 


