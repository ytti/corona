module Corona
  class DB
    require 'sequel'
    require 'sqlite3'
    def initialize
      @db = Sequel.sqlite(CFG.db, :max_connections => 1, :pool_timeout => 60)
      create_table #unless @db.table_exists?(:devices)
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

    private
    
    def create_table
      @db.create_table? :devices do
        primary_key :id
        String      :ip
        String      :ptr
        String      :model
        String      :oid_ifDescr
        Boolean     :active
        Time        :first_seen
        Time        :last_seen
        String      :oid_sysName
        String      :oid_sysLocation
        String      :oid_sysDescr
        String      :oid_sysObjectID
      end
    end

  end
end
