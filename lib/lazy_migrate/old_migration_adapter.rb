# frozen_string_literal: true

require 'lazy_migrate/common'

module LazyMigrate
  class OldMigrationAdapater < MigrationAdapter
    # example: ['up', 20200715030339, 'Add unique index to table']
    def find_migration_tuples
      ActiveRecord::Migrator.migrations_status(base_paths)
    end

    def up(version)
      ActiveRecord::Migrator.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    def down(version)
      ActiveRecord::Migrator.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version)
    end

    def redo(version)
      down(version)
      up(version)
    end

    def migrate(version)
      ActiveRecord::Migrator.migrate(base_paths, version)
    end

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

    def find_filename_for_migration(migration)
      migrations.find { |m| m.version == migration[:version] }&.filename
    end

    def last_version
      ActiveRecord::Migrator.get_all_versions.last
    end

    private

    def find_previous_version(version)
      versions = ActiveRecord::Migrator.get_all_versions

      return nil if version == versions.first

      previous_value(versions, version)
    end

    def base_paths
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end

    def migration_files
      ActiveRecord::Migrator.migration_files(base_paths)
    end

    def migrations
      ActiveRecord::Migrator.migrations(base_paths)
    end
  end
end
