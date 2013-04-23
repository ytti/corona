module Corona
  require 'ostruct'
  require 'yaml'
  class Config < OpenStruct
    Root      = File.join ENV['HOME'], '.config', 'corona'
    Crash     = File.join Root, 'crash'
    def initialize file=File.join(Config::Root, 'config')
      super()
      @file = file.to_s
    end
    def load
      if File.exists? @file
        marshal_load YAML.load_file @file 
      else
        require 'corona/config/bootstrap'
      end
    end
    def save
      File.write @file, YAML.dump(marshal_dump)
    end
  end
  CFG = Config.new
  CFG.load
  Log.file = CFG.log if CFG.log
  Log.level = Logger::INFO unless CFG.debug
end
