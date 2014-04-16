require 'corona/log'
require 'corona/config'
require 'corona/snmp'
require 'corona/db/db'
require 'corona/model'
require 'ipaddr'
require 'resolv'

module Corona
  class << self
    def new opts={}
      Core.new opts
    end

    def poll opts={}
      host = opts.delete :host
      raise CoronaError, '\'host\' not given' unless host
      corona = new opts
      result = corona.poll Resolv.getaddress(host)
      corona.mkrecord result if result
    end
  end

  class Core

    def run
      cidr          = @opts.delete :cidr
      @output       = @opts.delete :output
      if not @output
        @output = Logger.new $stdout
        @output.formatter = proc { |_ ,_ ,_ , msg| msg + "\n" }
      end
      poll, ignores = resolve_networks cidr
      @mutex        = Mutex.new
      @db           = DB.new
      threads       = []
      Thread.abort_on_exception = true
      poll.each do |net|
        net.to_range.each do |ip|
          next if ignores.any? { |ignore| ignore.include? ip }
          while threads.size >= CFG.threads
            threads.delete_if { |thread| not thread.alive? }
            sleep 0.01
          end
          threads << Thread.new do
            result = poll ip
            @mutex.synchronize { process result } if result
          end
        end
      end
      threads.each { |thread| thread.join }
    end

    def poll ip
      result = nil
      snmp = SNMP.new ip.to_s, @community
      oids = snmp.dbget
      if oids
        if index = snmp.ip2index(ip.to_s)
          if int = snmp.ifdescr(index)
            result = {:oids=>oids, :int=>int.downcase, :ip=>ip}
          else
            Log.warn "no ifDescr for #{index} at #{ip}"
          end
        else
          Log.warn "no ifIndex for #{ip}"
        end
      end
      snmp.close
      result
    end

    def mkrecord opt
      {
        :ip              => opt[:ip].to_s,
        :ptr             => ip2name(opt[:ip].to_s),
        :model           => Model.map(opt[:oids][:sysDescr], opt[:oids][:sysObjectID]),
        :oid_ifDescr     => opt[:int],
        :oid_sysName     => opt[:oids][:sysName],
        :oid_sysLocation => opt[:oids][:sysLocation],
        :oid_sysDescr    => opt[:oids][:sysDescr],
        :oid_sysObjectID => opt[:oids][:sysObjectID].join('.'),
      }
    end

    private

    def initialize opts={}
      @opts = opts
      @community   = opts.delete :community
      @community ||= CFG.community
    end

    def process opt
      opt = normalize_opt opt
      record = mkrecord opt
      old_by_ip, old_by_sysname = @db.old record[:ip], record[:oid_sysName]

      # unique box having non-unique sysname
      # old_by_sysname = false if record[:oid_sysDescr].match 'Application Control Engine'

      if not old_by_sysname and not old_by_ip
        # all new device
        @output.info "ptr [%s] sysName [%s] ip [%s]" % [record[:ptr], record[:oid_sysName], record[:ip]]
        Log.info "#{record[:ip]} added"
        @db.add record

      elsif not old_by_sysname and old_by_ip
        # IP seen, name not, device got renamed?
        Log.info "#{record[:ip]} got renamed"
        @db.update record, [:ip, old_by_ip[:ip]]

      elsif old_by_sysname and not old_by_ip
        # name exists, but IP is new, figure out if we wan to use old or new IP
        decide_old_new record, old_by_sysname

      elsif old_by_sysname and old_by_ip
        both_seen record, old_by_sysname, old_by_ip
      end
    end

    def both_seen record, old_by_sysname, old_by_ip
      if old_by_sysname == old_by_ip
        # no changes, updating same record
        Log.debug "#{record[:ip]} refreshed, no channges"
        @db.update record, [:oid_sysName, old_by_sysname[:oid_sysName]]
      else
        # same name seen and same IP seen, but records were not same (device got renumbered to existing node + existing node got delete?)
        Log.warn "#{record[:ip]}, unique entries for IP and sysName in DB, updating by IP"
        @db.update record, [:ip, old_by_ip[:ip]]
      end
    end

    def decide_old_new record, old_by_sysname
      new_int_pref = (CFG.mgmt.index(record[:oid_ifDescr]) or 100)
      old_int_pref = (CFG.mgmt.index(old_by_sysname[:oid_ifDescr]) or 99)

      if new_int_pref < old_int_pref
        # new int is more preferable than old
        Log.info "#{record[:ip]} is replacing inferior #{old_by_sysname[:ip]}"
        @db.update record, [:oid_sysName, old_by_sysname[:oid_sysName]]

      elsif new_int_pref == 100 and old_int_pref == 99
        # neither old or new interface is known good MGMT interface
        if SNMP.new(old_by_sysname[:ip], @community).sysdescr
          # if old IP works, don't update
          Log.debug "#{record[:ip]} not updating, previously seen as #{old_by_sysname[:ip]}"
        else
          Log.info "#{record[:ip]} updating, old #{old_by_sysname[:ip]} is dead"
          @db.update record, [:oid_sysName, old_by_sysname[:oid_sysName]]
        end

      elsif new_int_pref >= old_int_pref
        # nothing to do, we have better entry
        Log.debug "#{record[:ip]} already seen as superior via #{old_by_sysname[:ip]}"

      else
        Log.error "not updating, new: #{record[:ip]}, old: #{old_by_sysname[:ip]}"
      end
    end

    def normalize_opt opt
      opt[:oids][:sysName].sub!(/-re[1-9]\./, '-re0.')
      opt
    end

    def ip2name ip
      Resolv.getname ip rescue ip
    end

    def resolve_networks cidr
      cidr = cidr ? [cidr].flatten : CFG.poll
      [cidr, CFG.ignore].map do |nets|
        if nets.respond_to? :each
          nets.map { |net| IPAddr.new net }
        else
          out = []
          File.read(nets).each_line do |net|
            net = net.match(/^([\d.\/]+)/)
            out.push IPAddr.new net[1] if net
          end
          out
        end
      end
    end

  end
end
