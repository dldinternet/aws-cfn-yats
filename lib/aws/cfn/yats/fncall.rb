module Aws
  module Cfn
    module Yats

      class FnCall
        attr_reader :name, :arguments, :multiline

        def initialize(name, arguments, multiline = false)
          @name = name
          @arguments = arguments
          @multiline = multiline
        end

      end
    end
  end
end
