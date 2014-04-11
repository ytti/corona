Gem::Specification.new do |s|
  s.name              = 'corona'
  s.version           = '0.0.7'
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Saku Ytti' ]
  s.email             = %w( saku@ytti.fi )
  s.homepage          = 'http://github.com/ytti/corona'
  s.summary           = 'device discovery via snmp polls'
  s.description       = 'Threaded SNMP poll based network discovery. Devices are stored in SQL'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( corona )
  s.require_path      = 'lib'

  s.add_dependency 'sequel'
  s.add_dependency 'sqlite3'
  s.add_dependency 'snmp'
  s.add_dependency 'slop'
end
