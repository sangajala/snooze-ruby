module RubyUatFramework
  class Psexec
    attr_accessor :server,
                  :user,
                  :password,
                  :debug,
                  :retry

    def initialize( server_name, user_name, password)
      @server = server_name
      @user = user_name
      @password = password
      @debug = false
      @retry = false
    end

    def execute(command)
      result = try_to_execute(command)
      remaining_tries = 6
      while ( @retry && !result && remaining_tries > 0) do
        remaining_tries -= 1
        sleep 10
        result = try_to_execute(command)
      end
      result.should == true
    end

    def try_to_execute(command)
      test_js = File.join(File.dirname(__FILE__), "test.js")
      executable = File.join(File.dirname(__FILE__), "psexec.exe")
      executable = executable.gsub(/\//, '\\')

      complete_command = "c:\\windows\\system32\\cmd.exe /C c:\\windows\\system32\\CScript.exe #{test_js} #{executable}"
      complete_command = "#{complete_command} \\\\#{@server}"
      complete_command = "#{complete_command} -u #{@user} -p #{@password}" if ( @user != nil)
      complete_command = "#{complete_command} -accepteula"
      complete_command = "#{complete_command} #{command}"
      puts complete_command if @debug
      ret = system(complete_command)
      ret
    end

  end
end