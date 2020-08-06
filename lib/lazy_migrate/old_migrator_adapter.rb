# typed: true
# frozen_string_literal: true

require 'lazy_migrate/migrator_adapter'

module LazyMigrate
  class OldMigratorAdapter < MigratorAdapter
    extend T::Sig

    sig { override.void }
    def initialize
      # no-op but preventing parent initialize from being called
    end

    sig { override.params(version: Integer).void }
    def up(version)
      ActiveRecord::Migrator.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    sig { override.params(version: Integer).void }
    def down(version)
      ActiveRecord::Migrator.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    sig { override.params(version: Integer).void }
    def redo(version)
      down(version)
      up(version)
    end

    sig { override.params(version: Integer).void }
    def migrate(version)
      ActiveRecord::Migrator.migrate(base_paths, version)
    end

    sig { override.params(version: Integer).void }
    def rollback(version)
      previous_version = find_previous_version(version)

      if previous_version.nil?
        # rails excludes the given version when calling .migrate so we need to
        # just down this instead
        down(version)
      else
        ActiveRecord::Migrator.migrate(base_paths, previous_version)
      end
    end

    protected

    # example: [['up', '20200715030339', 'Add unique index to table']]
    sig { override.returns(T::Array[[String, String, String]]) }
    def find_migration_tuples
      ActiveRecord::Migrator.migrations_status(base_paths)
    end

    sig { override.params(version: Integer).returns(T.nilable(Integer)) }
    def find_previous_version(version)
      versions = ActiveRecord::Migrator.get_all_versions

      return nil if version == versions.first

      previous_value(versions, version)
    end

    sig { override.params(migration: LazyMigrate::Migration).returns(T.nilable(String)) }
    def find_filename_for_migration(migration)
      migrations.find { |m| m.version == migration.version }&.filename
    end

    sig { override.returns(T.nilable(Integer)) }
    def last_version
      ActiveRecord::Migrator.get_all_versions.last
    end

    private

    sig { returns(T::Array[String]) }
    def base_paths
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end

    sig { returns(T::Array[String]) }
    def migration_files
      ActiveRecord::Migrator.migration_files(base_paths)
    end

    sig { returns(T::Array[ActiveRecord::MigrationProxy]) }
    def migrations
      ActiveRecord::Migrator.migrations(base_paths)
    end
  end
end
