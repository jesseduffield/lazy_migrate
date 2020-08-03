# frozen_string_literal: true

require 'lazy_migrate'

namespace :lazy_migrate do
  desc 'runs lazy_migrate'
  task run: :environment do
    LazyMigrate.run
  end
end
