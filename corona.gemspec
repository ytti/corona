Gem::Specification.new do |s|
  s.name              = 'corona'
  s.version           = '0.2.0'
  s.licenses          = %w( 'Apache-2.0' )
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

  s.add_runtime_dependency 'sequel',  '~> 5.10'
  s.add_runtime_dependency 'sqlite3', '~> 1.4'
  s.add_runtime_dependency 'snmp',    '~> 1.2'
  s.add_runtime_dependency 'slop',    '~> 3.6'
  s.add_runtime_dependency 'asetus',  '~> 0.3'
end
