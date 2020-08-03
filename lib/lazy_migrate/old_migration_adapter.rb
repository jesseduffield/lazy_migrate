# frozen_string_literal: true

class OldMigrationAdapater
  def find_migrations
    migrations_tuples = ActiveRecord::Migrator.migrations_status(base_paths)
    migrations_tuples
      .reverse
      .map { |status, version, name| # TODO: consider factoring this out
        # This depends on how rails reports a file is missing.
        # This is no doubt subject to change so be wary.
        has_file = name != '********** NO FILE **********'

        { status: status, version: version.to_i, name: name, has_file: has_file }
      }
  end

  def up(migration)
    ActiveRecord::Migrator.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, migration[:version])
  end

  def down(migration)
    ActiveRecord::Migrator.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, migration[:version])
  end

  def redo(migration)
    down(migration)
    up(migration)
  end

  def migrate(migration)
    # unimplemented
  end

  def rollback(migration)
    # unimplemented
  end

  def find_filename_for_migration(migration)
    migrations.find { |m| m.version == migration[:version] }&.filename
  end

  def last_version
    ActiveRecord::Migrator.get_all_versions.last
  end

  private

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
