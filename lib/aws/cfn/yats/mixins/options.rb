module Aws
  module Cfn
    module Yats
      module Options

        def parse_options
          @opts ||= Slop.new(help: true)

          setup_options(@opts.command :decompile)

          setup_options(@opts.command :compile)

          setup_options(@opts.command :dsl)

          setup_options(@opts.command :json2yaml)

          setup_options(@opts.command :yaml2json)

          @opts.parse!

        end

        def set_config_options
          setup_config
        end

      end
    end
  end
end
