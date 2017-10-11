module Corona
  class CLI
    MAX_DELETE = 1
    gem 'slop', "=3.6.0"
    require 'slop'
    require_relative '../corona'
    class NoConfig < CoronaError; end

    def run
      if @opts[:poll]
        Corona.new(:cidr=>@opts[:poll]).run
      elsif @opts[:remove]
        remove_records @opts[:remove]
      elsif @opts['purge-old']
        remove_old @opts['purge-old']
      else
        Corona.new.run
      end
    end

    private

    def initialize
      args, @opts = opts_parse
      @arg = args.shift
      CFG.debug = true if @opts[:debug]
      raise NoConfig, 'edit ~/.config/corona/config' if CFGS.create
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
