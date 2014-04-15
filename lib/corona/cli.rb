module Corona
  class CLI
    MAX_DELETE = 1
    require 'corona'
    require 'slop'
    class NoConfig < CoronaError; end

    def run
      if @opts[:poll]
        Corona.new :cidr=>@opts[:poll]
      elsif @opts[:remove]
        remove_records @opts[:remove]
      elsif @opts['purge-old']
        remove_old @opts['purge-old']
      else
        Corona.new
      end
    end

    private

    def initialize
      args, @opts = opts_parse
      @arg = args.shift
      CFG.debug = true if @opts[:debug]
      if CFGS.system.empty? and CFGS.user.empty?
        CFGS.user = CFGS.default
        CFGS.save :user
        raise NoConfig, 'edit ~/.config/corona/config'
      end
    end

    def opts_parse
      opts = Slop.parse(:help=>true) do
        banner 'Usage: corona [options] [argument]'
        on 'd',  'debug',      'Debugging on'
        on 'p=', 'poll',       'Poll CIDR [argument]'
        on 'r=', 'remove',     'Remove [argument] from DB'
        on 'm=', 'max-delete', "Maximum number to delete, default #{MAX_DELETE}"
        on 'o=', 'purge-old',  'Remove records order than [argument] days'
        on 's',  'simulate',   'Simulate, do not change DB'
      end
      [opts.parse!, opts]
    end

    def remove_records name
      DB.new
      delete_records DB::Device.filter(Sequel.like(:ptr, "%#{name}%")).all
    end

    def remove_old days
      old = (Time.now.utc - days.to_i * 24 * 60 * 60)
      DB.new
      delete_records DB::Device.filter{last_seen < old}.all
    end

    def delete_records devs
      max_del = @opts['max-delete'] ? @opts['max-delete'] : MAX_DELETE
      if devs.size > max_del.to_i
        puts 'Too many matching devices:'
        devs.each do |dev|
          puts '  %s (%s)' % [dev.ptr, dev.ip]
        end
        puts 'Be more specific'
      else
        puts 'Deleting records:'
        devs.each do |dev|
          puts '  %s (%s)' % [dev.ptr, dev.ip]
          dev.delete unless @opts[:simulate]
        end
      end
    end
  end
end
