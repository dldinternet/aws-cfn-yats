# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/cfn/yats/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws-cfn-yats'
  spec.version       = Aws::Cfn::Yats::VERSION
  spec.authors       = ['Christo De Lange']
  spec.email         = ["rubygems@dldinternet.com"]
  spec.summary       = %q{CloudFormation - Yet Another Template System}
  spec.description   = %q{AWS Cloudformation templates expressed with a Ruby DSL, YAML or JSON in a modular fashion}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-cfn-decompiler', '>= 0.2.1', '~> 0.2'
  spec.add_dependency 'aws-cfn-compiler', '>= 0.2.1', '~> 0.2'

  spec.add_development_dependency 'json_pure', '> 0'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
