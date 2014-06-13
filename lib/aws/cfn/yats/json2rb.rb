require "aws/cfn/yats/base"

module Aws
  module Cfn
    module Yats

      class Json2Rb < Base

        def initialize

        end

        protected

        def pprint_cfn_template(tpl)
           puts "#!/usr/bin/env ruby"
           puts
           puts "require 'bundler/setup'"
           puts "require 'cloudformation-ruby-dsl/cfntemplate'"
           # puts "require 'cloudformation-ruby-dsl/spotprice'"
           puts "require 'cloudformation-ruby-dsl/table'"
           puts
           puts "template do"
           puts
           tpl.each do |section, v|
             case section
               when 'Parameters'
                 v.each { |name, options| pprint_cfn_section 'parameter', name, options }
               when 'Mappings'
                 v.each { |name, options| pprint_cfn_section 'mapping', name, options }
               when 'Resources'
                 v.each { |name, options| pprint_cfn_resource name, options }
               when 'Outputs'
                 v.each { |name, options| pprint_cfn_section 'output', name, options }
               else
                 print "  value #{fmt_key(section)} => "
                 pprint_value v, '  '
                 puts
                 puts
             end
           end
           puts "end.exec!"
         end

         def pprint_cfn_section(section, name, options)
           print "  #{section} #{fmt_string(name)}"
           indent = '  ' + (' ' * section.length) + ' '
           options.each do |k, v|
             puts ","
             print indent, fmt_key(k), " => "
             pprint_value v, indent
           end
           puts
           puts
         end

         def pprint_cfn_resource(name, options)
           print "  resource #{fmt_string(name)}"
           indent = '  '
           options.each do |k, v|
             unless k == 'Properties'
               print ", #{fmt_key(k)} => #{fmt(v)}"
             end
           end
           if options.key?('Properties')
             print ", #{fmt_key('Properties')} => "
             pprint_value options['Properties'], indent
           end
           puts
           puts
         end

         def pprint_value(val, indent)
           # Prefer to print the value on a single line if it's reasonable to do so
           single_line = is_single_line(val) || is_single_line_hack(val)
           if single_line && !is_multi_line_hack(val)
             s = fmt(val)
             if s.length < 120 || is_single_line_hack(val)
               print s
               return
             end
           end

           # Print the value across multiple lines
           if val.is_a?(Hash)
             puts "{"
             val.each do |k, v|
               print "#{indent}    #{fmt_key(k)} => "
               pprint_value v, indent + '    '
               puts ","
             end
             print "#{indent}}"

           elsif val.is_a?(Array)
             puts "["
             val.each do |v|
               print "#{indent}    "
               pprint_value v, indent + '    '
               puts ","
             end
             print "#{indent}]"

           elsif val.is_a?(FnCall) && val.multiline
             print val.name, "("
             args = val.arguments
             sep = ''
             sub_indent = indent + '    '
             if val.name == 'join' && args.length > 1
               pprint_value args[0], indent + '  '
               args = args[1..-1]
               sep = ','
               sub_indent = indent + '     '
             end
             unless args.empty?
               args.each do |v|
                 puts sep
                 print sub_indent
                 pprint_value v, sub_indent
                 sep = ','
               end
               if val.name == 'join' && args.length > 1
                 print ","
               end
               puts
               print indent
             end
             print ")"

           else
             print fmt(val)
           end
         end

         def is_single_line(val)
           if val.is_a?(Hash)
             is_single_line(val.values)
           elsif val.is_a?(Array)
             val.empty? ||
                 (val.length == 1 && is_single_line(val[0]) && !val[0].is_a?(Hash)) ||
                 val.all? { |v| v.is_a?(String) }
           else
             true
           end
         end

         # Emo-specific hacks to force the desired output formatting
         def is_single_line_hack(val)
           is_array_of_strings_hack(val)
         end

         # Emo-specific hacks to force the desired output formatting
         def is_multi_line_hack(val)
           val.is_a?(Hash) && val['email']
         end

         # Emo-specific hacks to force the desired output formatting
         def is_array_of_strings_hack(val)
           val.is_a?(Array) && val.all? { |v| v.is_a?(String) } && val.grep(/\s/).empty? && (
           val.include?('autoscaling:EC2_INSTANCE_LAUNCH') ||
               val.include?('m1.small')
           )
         end

         def fmt(val)
           if val == {}
             '{}'
           elsif val == []
             '[]'
           elsif val.is_a?(Hash)
             '{ ' + (val.map { |k,v| fmt_key(k) + ' => ' + fmt(v) }).join(', ') + ' }'
           elsif val.is_a?(Array) && is_array_of_strings_hack(val)
             '%w(' + val.join(' ') + ')'
           elsif val.is_a?(Array)
             '[ ' + (val.map { |v| fmt(v) }).join(', ') + ' ]'
           elsif val.is_a?(FnCall) && val.arguments.empty?
             val.name
           elsif val.is_a?(FnCall)
             val.name + '(' + (val.arguments.map { |v| fmt(v) }).join(', ') + ')'
           elsif val.is_a?(String)
             fmt_string(val)
           elsif val == nil
             'null'
           else
             val.to_s  # number, boolean
           end
         end

         def fmt_key(s)
           ':' + (/^[a-zA-Z_]\w+$/ =~ s ? s : fmt_string(s))  # returns a symbol like :Foo or :'us-east-1'
         end

         def fmt_string(s)
           if /[^ -~]/ =~ s
             s.dump  # contains, non-ascii or control char, return double-quoted string
           else
             '\'' + s.gsub(/([\\'])/, '\\\\\1') + '\''  # return single-quoted string, escape \ and '
           end
         end

       end
    end
  end
end
