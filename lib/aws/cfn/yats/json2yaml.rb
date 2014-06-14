require "aws/cfn/yats/base"
require 'yaml'

module Aws
  module Cfn
    module Yats

      class Json2Yaml < Base

        def pprint_cfn_template(tpl)

          yml = YAML::dump(tpl)

          puts yml
        end

      end
    end
  end
end
