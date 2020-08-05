# typed: true
# frozen_string_literal: true

require "lazy_migrate/old_migrator_adapter"
require "lazy_migrate/new_migrator_adapter"

module LazyMigrate
  class MigratorAdapterFactory
    class << self
      # unfortunately the code is a little different from 5.2 onwards compared to previous
      # versions, and we want to do more than just invoke the db:migrate rake
      # commands so we're returning a different adapter depending on the rails
      # version
      def create_migrator_adapter
        if Rails.version > '5.2.0'
          LazyMigrate::NewMigratorAdapter.new
        else
          LazyMigrate::OldMigratorAdapter.new
        end
      end
    end
  end
end

