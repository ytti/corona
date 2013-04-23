module Corona
  class DB
    require 'sequel'
    require 'sqlite3'
    def initialize 
      @db = Sequel.sqlite(CFG.db, :max_connections => 1, :pool_timeout => 60)

      @db.create_table :device do
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
      end unless @db.table_exists? :device
    end

    # http://sequel.rubyforge.org/rdoc/files/doc/cheat_sheet_rdoc.html
    #

    def add record
      record[:first_seen] = record[:last_seen] = Time.now.utc
      record[:active] = true
      #Log.debug "adding: #{record}"
      @db[:device].insert record
    end

    def update record, where
      record[:last_seen] = Time.now.utc
      record[:active] = true
      #Log.debug "updating (where: #{where}): #{record}"
      @db[:device].where('? == ?', where.first, where.last).update record
    end

    def [] primary_key
      @db[:device].where('id == ?', primary_key).first
    end

    def old primary_key, oid_sysName
      ip       = self[primary_key]
      sysName  = @db[:device].where('oid_sysName == ?', oid_sysName).first
      [ip, sysName]
    end
  end
end
