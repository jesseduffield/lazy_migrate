# typed: strict
# frozen_string_literal: true

require 'lazy_migrate/migrator_adapter'

module ActiveRecord
  class Migrator
    module Compatibility
      class V5_1 < ActiveRecord::Migrator
      end
    end
  end
end

module LazyMigrate
  class OldMigratorAdapter < MigratorAdapter
    extend T::Sig

    sig { override.params(version: Integer).void }
    def up(version)
      ActiveRecord::Migrator::Compatibility::V5_1.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    sig { override.params(version: Integer).void }
    def down(version)
      ActiveRecord::Migrator::Compatibility::V5_1.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    sig { override.params(version: Integer).void }
    def redo(version)
      down(version)
      up(version)
    end

    sig { override.params(version: Integer).void }
    def migrate(version)
      ActiveRecord::Migrator::Compatibility::V5_1.migrate(base_paths, version)
    end

    sig { override.params(version: Integer).void }
    def rollback(version)
      previous_version = find_previous_version(version)

      if previous_version.nil?
        # rails excludes the given version when calling .migrate so we need to
        # just down this instead
        down(version)
      else
        ActiveRecord::Migrator::Compatibility::V5_1.migrate(base_paths, previous_version)
      end
    end

    protected

    # example: [['up', '20200715030339', 'Add unique index to table']]
    sig { override.returns(T::Array[[String, String, String]]) }
    def find_migration_tuples
      ActiveRecord::Migrator::Compatibility::V5_1.migrations_status(base_paths)
    end

    sig { override.params(version: Integer).returns(T.nilable(Integer)) }
    def find_previous_version(version)
      versions = ActiveRecord::Migrator::Compatibility::V5_1.get_all_versions

      return nil if version == versions.first

      previous_value(versions, version)
    end

    sig { override.params(migration: LazyMigrate::Migration).returns(T.nilable(String)) }
    def find_filename_for_migration(migration)
      migrations.find { |m| m.version == migration.version }&.filename
    end

    sig { override.returns(T.nilable(Integer)) }
    def last_version
      ActiveRecord::Migrator::Compatibility::V5_1.get_all_versions.last
    end

    private

    sig { returns(T::Array[String]) }
    def base_paths
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end

    sig { returns(T::Array[String]) }
    def migration_files
      ActiveRecord::Migrator::Compatibility::V5_1.migration_files(base_paths)
    end

    sig { returns(T::Array[ActiveRecord::MigrationProxy]) }
    def migrations
      ActiveRecord::Migrator::Compatibility::V5_1.migrations(base_paths)
    end
  end
end
