module Corona
  class CLI
    MAX_DELETE = 1
    require 'corona'
    require 'slop'

    def run
      if @opts[:poll]
        Corona.new :cidr=>@opts[:poll]
      elsif @opts[:remove]
        remove_from_db @opts[:remove]
      else
        Corona.new
      end
    end

    private

    def initialize
      args, @opts = opts_parse
      @arg = args.shift
      CFG.debug = true if @opts[:debug]
    end

    def opts_parse
      opts = Slop.parse(:help=>true) do
        banner 'Usage: corona [options] [argument]'
        on 'd',  'debug',      'Debugging on'
        on 'p=', 'poll',       'Poll CIDR [argument]'
        on 'r=', 'remove',     'Remove [argument] from DB'
        on 'm=', 'max-delete', "Maximum number to delete, default #{MAX_DELETE}"
        on 's',  'simulate',   'Simulate, do not change DB'
      end
      [opts.parse!, opts]
    end

    def remove_from_db name
      max_del = @opts['max-delete'] ? @opts['max-delete'] : MAX_DELETE
      DB.new
      devs = DB::Device.filter(Sequel.like(:ptr, "%#{name}%")).all
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
