module Corona
  require 'fileutils'
  FileUtils.mkdir_p Config::Root
  CFG.community = 'public'
  CFG.db        = File.join Config::Root, 'corona.db'
  CFG.poll      = %w( 10.10.10.0/24 10.10.20.0/24 )
  CFG.ignore    = %w( 10.10.10.42/32 10.10.20.42/32 )
  CFG.mgmt      = %w( lo0.0 loopback0 vlan2 )
  CFG.threads   = 50
  CFG.log       = File.join Config::Root, 'log'
  CFG.debug     = false
  CFG.save
end
