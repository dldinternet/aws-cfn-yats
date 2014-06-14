require "aws/cfn/yats/base"
require 'yaml'
require 'json/pure'

module Aws
  module Cfn
    module Yats

      class Yaml2Json < Base
        attr_accessor :yaml

        def transform(template)
          @template = template
          @yaml     = YAML.load(template)
          @simple   = simplify(@yaml)
          pprint(@simple)
        end

        def pprint_cfn_template(tpl)
          pprint_value(tpl)
        end

        def pprint_cfn_section(section, name, options)
          pprint_value(section)
        end

        def pprint_cfn_resource(name, options)
          pprint_value({ name => options })
        end

        def pprint_value(val, indent="\t")
          @json = JSON.pretty_generate(val, {
              :indent         => indent,
              :space          => ' ',
              :object_nl      => "\n",
              :array_nl       => "\n"
          } )

          puts @json
        end

      end
    end
  end
end
