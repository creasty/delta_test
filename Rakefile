require 'bundler/gem_tasks'
require 'rake/extensiontask'

GEM_NAME = 'delta_test'
SO_NAME  = 'delta_test_native'

Rake::ExtensionTask.new SO_NAME do |ext|
  ext.ext_dir = "ext/#{GEM_NAME}"
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
    Bundler.with_clean_env do
      s = system('cd spec/rails && bundle exec delta_test stats:clean')
      s &&= system('cd spec/rails && bundle exec delta_test exec --verbose rspec --color')
      s &&= system('cd spec/rails && bundle exec delta_test stats:save --no-sync')
      exit $?.exitstatus unless s
    end
  end
end

task default: ['test', 'rails:test']
