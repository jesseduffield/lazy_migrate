require "bundler/gem_tasks"
require "rspec/core/rake_task"
require './lib/lazy_migrate'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :run do
  LazyMigrate.run
end