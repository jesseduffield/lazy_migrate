# frozen_string_literal: true

class NewMigrationAdapter
  attr_accessor :context

  def initialize
    @context = ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate'))
  end

  def find_migrations
    migration_tuples = context.migrations_status
    migration_tuples
      .reverse
      .map { |status, version, name|
        # This depends on how rails reports a file is missing.
        # This is no doubt subject to change so be wary.
        has_file = name != '********** NO FILE **********'

        { status: status, version: version.to_i, name: name, has_file: has_file }
      }
  end

  def up(migration)
    context.run(:up, migration[:version])
  end

  def down(migration)
    context.run(:down, migration[:version])
  end

  def redo(migration)
    down(migration)
    up(migration)
  end

  def migrate(migration)
    context.up(migration[:version])
  end

  def rollback(migration)
    # for some reason in https://github.com/rails/rails/blob/5-2-stable/activerecord/lib/active_record/migration.rb#L1221
    # we stop before the selected version. I have no idea why.
    # I could override the logic here but it wouldn't
    # work when trying to rollback the final migration.
    context.down(migration[:version])
  end

  def find_filename_for_migration(migration)
    context.migrations.find { |m| m.version == migration[:version] }&.filename
  end

  def last_version
    context.migrations.last&.version
  end
end
