require 'bundler/gem_tasks'

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
