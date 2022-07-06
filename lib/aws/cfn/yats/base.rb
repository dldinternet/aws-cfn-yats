unless RUBY_VERSION >= '1.9'
  # Ruby 1.9 preserves order within Hash objects which avoid scrambling the template output.
  $stderr.puts 'This script requires ruby 1.9+.'
  $stderr.puts 'We suggest you use RVM to install ruby 1.9+: See https://rvm.io'
  exit(2)
end

require 'json/pure'
require "aws/cfn/yats/version"
require "aws/cfn/decompiler/base"

module Aws
  module Cfn
    module Yats
      attr_accessor :template
      attr_accessor :json
      attr_accessor :simple

      class Base < ::Aws::Cfn::DeCompiler::Base

        require 'aws/cfn/yats/mixins/options'
        include Aws::Cfn::Yats::Options

        def transform(template)
          @template = template
          @json     = JSON.parse(template)
          @simple   = simplify(@json)
          pprint(@simple)
        end
      end
    end
  end
end
