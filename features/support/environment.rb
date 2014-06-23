require('rspec')

class CilsEnvironment
  #include RSpec::Matchers
  #
  #attr_reader :name,
  #            :server, :database_server, :database_name, :database_user, :database_password,
  #            :indie_user, :investment_unit_user, :investment_unit_super_user, :bbc_ca_user,
  #            :two_e_user, :two_e_forecast_user, :user_password
  #            :treatment_export_path
  #
  #def initialize(environment_name)
  #  environment_name.should_not be_nil
  #  @name = environment_name
  #  sys_config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config.yml'))[@name]
  #
  #  @server = sys_config["server"]
  #  @database_server = sys_config["database_server"]
  #  @database_name = sys_config["database_name"]
  #  @database_user = sys_config["database_user"]
  #  @database_password = sys_config["database_password"]
  #  @indie_user = sys_config["indie_user"]
  #  @investment_unit_user = sys_config["investment_unit_user"]
  #  @investment_unit_super_user = sys_config["investment_unit_super_user"]
  #  @bbc_ca_user = sys_config["bbc_ca_user"]
  #  @two_e_user = sys_config["two_e_user"]
  #  @two_e_forecast_user = sys_config["two_e_forecast_user"]
  #  @user_password = sys_config["user_password"]
  #  @treatment_export_path = sys_config["treatment_export_path"]
  #end
end