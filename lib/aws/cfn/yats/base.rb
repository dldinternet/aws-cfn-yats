unless RUBY_VERSION >= '1.9'
  # Ruby 1.9 preserves order within Hash objects which avoid scrambling the template output.
  $stderr.puts "This script requires ruby 1.9+."
  $stderr.puts "We suggest you use RVM to install ruby 1.9+: See https://rvm.io"
  exit(2)
end

require "aws/cfn/yats/version"

module Aws
  module Cfn
    module Yats
      attr_accessor :template
      attr_accessor :json
      attr_accessor :simple

      class Base

        def self.abstract_methods(*args)
          args.each do |name|
            class_eval(<<-END, __FILE__, __LINE__)
            def #{name}(*args)
              raise NotImplementedError.new("You must implement #{name}.")
            end
            END
          end
        end

        def initialize
        end


        def transform(template)
          @template = template
          @json     = JSON.parse(template)
          @simple   = simplify(@json)
          pprint(@simple)
        end

        def simplify(val)
          if val.is_a?(Hash)
            val = Hash[val.map { |k,v| [k, simplify(v)] }]
            # if val.length != 1
            #   val
            # else
            #   k, v = val.entries[0]
            #   # CloudFormation functions
            #   case
            #     when k == 'Fn::Base64'
            #       FnCall.new 'base64', [v], true
            #     when k == 'Fn::FindInMap'
            #       FnCall.new 'find_in_map', v
            #     when k == 'Fn::GetAtt'
            #       FnCall.new 'get_att', v
            #     when k == 'Fn::GetAZs'
            #       FnCall.new 'get_azs', v != '' ? [v] : []
            #     when k == 'Fn::Join'
            #       FnCall.new 'join', [v[0]] + v[1], true
            #     when k == 'Fn::Select'
            #       FnCall.new 'select', v
            #     # when k == 'Ref' && v == 'AWS::Region'
            #     #   FnCall.new 'aws_region', []
            #     # when k == 'Ref' && v == 'AWS::StackName'
            #     #   FnCall.new 'aws_stack_name', []
            #     when k == 'Ref'
            #       FnCall.new 'ref', [v]
            #     else
            #       val
            #   end
            # end
          elsif val.is_a?(Array)
            val.map { |v| simplify(v) }
          else
            val
          end
        end

        def pprint(val)
          case detect_type(val)
            when :template
              pprint_cfn_template(val)
            when :parameter
              pprint_cfn_section 'parameter', 'TODO', val
            when :resource
              pprint_cfn_resource 'TODO', val
            when :parameters
              val.each { |k, v| pprint_cfn_section 'parameter', k, v }
            when :resources
              val.each { |k, v| pprint_cfn_resource k, v }
            else
              pprint_value(val, '')
          end
        end

        protected

        # Attempt to figure out what fragment of the template we have.  This is imprecise and can't
        # detect Mappings and Outputs sections reliably, so it doesn't attempt to.
        def detect_type(val)
          if val.is_a?(Hash) && val['AWSTemplateFormatVersion']
            :template
          elsif val.is_a?(Hash) && /^(String|Number)$/ =~ val['Type']
            :parameter
          elsif val.is_a?(Hash) && val['Type']
            :resource
          elsif val.is_a?(Hash) && val.values.all? { |v| detect_type(v) == :parameter }
            :parameters
          elsif val.is_a?(Hash) && val.values.all? { |v| detect_type(v) == :resource }
            :resources
          end
        end

        # def method_missing(name, *args)
        #   raise "Abstract base class call to missing method #{name}"
        # end


        private


      end

      Base::abstract_methods :pprint_cfn_template, :pprint_cfn_section, :pprint_cfn_resource, :pprint_value

    end
  end
end
