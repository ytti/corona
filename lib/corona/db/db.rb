module Corona
  class DB
    require 'sequel'
    require 'sqlite3'
    def initialize
      Sequel::Model.plugin :schema
      @db = Sequel.sqlite(CFG.db, :max_connections => 1, :pool_timeout => 60)
      require_relative 'model'
    end

    def add record
      record[:first_seen] = record[:last_seen] = Time.now.utc
      record[:active] = true
      Log.debug "adding: #{record}"
      Device.new(record).save
    end

    def update record, where
      record[:last_seen] = Time.now.utc
      record[:active] = true
      Log.debug "updating (where: #{where}): #{record}"
      Device[where.first.to_sym => where.last].update record
    end

    def old ip, oid_sysName
      ip       = Device[:ip => ip]
      sysName  = Device[:oid_sysName => oid_sysName]
      [ip, sysName]
    end
  end
end
