# frozen_string_literal: true

require "lazy_migrate/old_migration_adapter"
require "lazy_migrate/new_migration_adapter"

module LazyMigrate
  class MigrationAdapterFactory
    class << self
      # unfortunately the code is a little different from 5.2 onwards compared to previous
      # versions, and we want to do more than just invoke the db:migrate rake
      # commands so we're returning a different adapter depending on the rails
      # version
      def create_migration_adapter
        if Rails.version > '5.2.0'
          LazyMigrate::NewMigrationAdapter.new
        else
          LazyMigrate::OldMigrationAdapater.new
        end
      end
    end
  end
end

