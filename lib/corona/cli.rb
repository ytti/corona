module Corona
  class CLI
    require 'corona'
    require 'slop'

    def run cidr=@cidr
      Corona.new :cidr=>cidr
    end

    private

    def initialize
      args, opts = opts_parse
      @cidr = args.shift
      CFG.debug = true if opts[:debug]
    end

    def opts_parse
      opts = Slop.parse(:help=>true) do
        banner 'Usage: corona [cidr]'
        on 'd', 'debug', 'Debugging on'
      end
      [opts.parse!, opts]
    end

  end
end
