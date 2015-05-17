require 'bundler/gem_tasks'
require 'rake/extensiontask'

SO_NAME = 'delta_test'
default_spec = Gem::Specification.load("#{SO_NAME}.gemspec")

Rake::ExtensionTask.new 'delta_test' do |ext|
  ext.gem_spec = default_spec
  ext.name = SO_NAME
  ext.ext_dir = "ext/#{SO_NAME}"
  ext.lib_dir = "lib/#{RUBY_VERSION.sub(/\.\d$/, '')}"
  ext.cross_compile = true
  ext.cross_platform = ['x86-mswin32-60', 'x86-mingw32-60']
end

desc 'Run unit tests'
task :test do
  s = system('bundle exec rspec')
  exit $? unless s
end

namespace :rails do
  desc 'Run rails tests'
  task :test do
    s = system('cd spec/rails && DELTA_TEST_ACTIVE=true DELTA_TEST_VERBOSE=true bundle exec rspec')
    exit $? unless s
  end
end

task default: ['test', 'rails:test']
