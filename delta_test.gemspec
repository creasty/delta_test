# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'delta_test/version'

Gem::Specification.new do |spec|
  spec.name          = 'delta_test'
  spec.version       = DeltaTest::VERSION
  spec.authors       = ['Yuki Iwanaga']
  spec.email         = ['yuki@creasty.com']
  spec.summary       = %q{delta_test analyzes your tests and runs only related tests for your file changes}
  spec.description   = %q{delta_test analyzes your tests and runs only related tests for your file changes}
  spec.homepage      = 'http://github.com/creasty/delta_test'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'ruby-prof'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
end
