module Corona
  class SNMP
  class InvalidResponse < StandardError; end
    DB_OID = {
      :sysDescr     => '1.3.6.1.2.1.1.1.0',
      :sysObjectID  => '1.3.6.1.2.1.1.2.0',
      :sysName      => '1.3.6.1.2.1.1.5.0',
      :sysLocation  => '1.3.6.1.2.1.1.6.0',
    }
    OID = {
       :ifDescr            => '1.3.6.1.2.1.2.2.1.2',
       :ipCidrRouteIfIndex => '1.3.6.1.2.1.4.24.4.1.5',  # addr.255.255.255.255.0.0.0.0.0
       :ipAdEntIfIndex     => '1.3.6.1.2.1.4.20.1.2',    # addr
       :ipAddressIfIndex   => '1.3.6.1.2.1.4.34.1.3',    # 1,2 (uni,any) . 4,16 (size) . addr
    }
    UNICAST = 1
    IPV4    = 4

    BULK_MAX = 30
    require 'snmp'
    def initialize host, community=CFG.community
      @snmp = ::SNMP::Manager.new :Host => host, :Community => community,
                                  :Timeout => CFG.timeout, :Retries => CFG.retries, :MibModules => []
    end
    def close
      @snmp.close
    end
    def get *oid
      oid = [oid].flatten.join('.')
      begin
        @snmp.get(oid).each_varbind { |vb| return vb }
      rescue ::SNMP::RequestTimeout, Errno::EACCES
        return false
      end
    end
    def mget oids=DB_OID
      result = {}
      begin
        res = @snmp.get(oids.map{|_,oid|oid})
        raise InvalidResponse, "#{res.error_status} from #{@snmp.config[:host]}" unless res.error_status == :noError
        res.each_varbind do |vb|
          oids.each do |name,oid|
            if vb.name.to_str == oid
              result[name] = vb.value
              next
            end
          end
        end
      rescue ::SNMP::RequestTimeout, Errno::EACCES
        return false
      rescue InvalidResponse => e
        return false
      end
      result
    end
    alias dbget mget
    def bulkwalk root
      last, oid, vbs = false, root, []
      while not last
        r = @snmp.get_bulk 0, BULK_MAX, oid
        r.varbind_list.each do |vb|
          oid = vb.name.to_str
          (last = true; break) if not oid.match(/^#{Regexp.quote root}/)
          vbs.push vb
        end
      end
      vbs
    end

    def sysdescr
      get DB_OID[:sysDescr]
    end

    def ip2index ip
      oids = mget :route => [OID[:ipCidrRouteIfIndex], ip, '255.255.255.255.0.0.0.0.0'].join('.'),
                  :new   => [OID[:ipAddressIfIndex], UNICAST, IPV4, ip].join('.'),
                  :old   => [OID[:ipAdEntIfIndex], ip].join('.')
      return false unless oids
      index = oids[:route]
      index = oids[:new] if not index.class == ::SNMP::Integer or index.to_s == '0'
      index = oids[:old] if not index.class == ::SNMP::Integer or index.to_s == '0'
      return false unless index.class == ::SNMP::Integer
      index.to_s
    end
    def ifdescr index
      descr = get OID[:ifDescr], index
      return false unless descr and descr.value.class == ::SNMP::OctetString
      descr.value.to_s
    end
  end
end
