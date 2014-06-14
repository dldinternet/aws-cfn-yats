require "aws/cfn/yats/base"
require 'yaml'

module Aws
  module Cfn
    module Yats

      class Json2Yaml < Base

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
          yml = YAML::dump(val)

          puts yml
        end

      end
    end
  end
end
