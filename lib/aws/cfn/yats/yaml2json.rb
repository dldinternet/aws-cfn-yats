require "aws/cfn/yats/base"
require 'yaml'

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

          @json = JSON.pretty_generate(tpl)

          puts @json
        end

      end
    end
  end
end
