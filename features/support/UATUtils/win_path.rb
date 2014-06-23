module RubyUatFramework
  class WinPath
    def self.temp_for(filename)
      agent_path = "c:\\buildagent\\temp\\buildtmp"
      temp_path = "c:\\temp"
      path = "%s\\%s" % [agent_path, filename] if File.directory?(agent_path)
      path = "%s\\%s" % [temp_path, filename] if File.directory?(temp_path)
      path
    end
  end
end
