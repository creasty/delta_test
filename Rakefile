require "bundler/gem_tasks"

desc "Run unit tests"
task :spec do
  exit system("bundle exec rspec --pattern spec/lib/**/*_spec.rb")
end

namespace :rails do
  desc "Run rails tests"
  task :spec do
    exit system("cd spec/rails && bundle exec rspec")
  end
end

task default: [:spec, "rails:spec"]
