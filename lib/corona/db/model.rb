module Corona
  class DB
    class Device < Sequel::Model
      set_schema do
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
      end
      create_table unless table_exists?
    end
  end
end
