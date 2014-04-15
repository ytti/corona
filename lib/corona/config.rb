module Corona
  require 'asetus'
  require 'fileutils'

  class Config
    Root  = File.join ENV['HOME'], '.config', 'corona'
    Crash = File.join Root, 'crash'
  end

  FileUtils.mkdir_p Config::Root
  CFGS = Asetus.new :name=>'corona', :load=>'false', :key_to_s=>true

  CFGS.default.community = 'public'
  CFGS.default.db        = File.join Config::Root, 'corona.db'
  CFGS.default.poll      = %w( 10.10.10.0/24 10.10.20.0/24 )
  CFGS.default.ignore    = %w( 10.10.10.42/32 10.10.20.42/32 )
  CFGS.default.mgmt      = %w( lo0.0 loopback0 vlan2 )
  CFGS.default.threads   = 50
  CFGS.default.timeout   = 0.25
  CFGS.default.retries   = 2
  CFGS.default.log       = File.join Config::Root, 'log'
  CFGS.default.debug     = false

  CFGS.load
  CFG = CFGS.cfg

  Log.file  = CFG.log if CFG.log
  Log.level = Logger::INFO unless CFG.debug
end
