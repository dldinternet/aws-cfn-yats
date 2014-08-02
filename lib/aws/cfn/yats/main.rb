require 'aws/cfn/yats/version'
require 'aws/cfn/yats/base'
require 'aws/cfn/yats/main'


module Aws
  module Cfn
    module Yats
      class Main < Base

        def run

          parse_options

          set_config_options

        end

      end
    end
  end
end
