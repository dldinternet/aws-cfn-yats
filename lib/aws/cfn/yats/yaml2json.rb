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

        def run
          unless (ARGV & %w(-h --help -?)).empty?
            $stderr.puts <<"EOF"
usage: #{$PROGRAM_NAME} [cloudformation-template.json] ...

Converts the specified CloudFormation JSON template or template fragment to
Ruby DSL syntax.  Reads from stdin or from the specified json files.  Note
that the input must be valid JSON.

Examples:

  # Convert a JSON CloudFormation template to Ruby DSL syntax
  #{$PROGRAM_NAME} my-template.json > my-template.rb
  chmod +x my-template.rb

  # Convert the JSON fragment in the clipboard to Ruby DSL syntax
  pbpaste | #{$PROGRAM_NAME} | less

EOF
            exit(2)
          end

          y2j = Aws::Cfn::Yats::Yaml2Json.new

          if ARGV.empty?
            template = $stdin.read
            y2j.transform(template)
          else
            ARGV.each do |filename|
              template = File.read(filename)
              y2j.transform(template)
            end
          end
        end

      end
    end
  end
end
