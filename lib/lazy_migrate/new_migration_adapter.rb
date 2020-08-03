# frozen_string_literal: true

require 'lazy_migrate/common'

module LazyMigrate
  class NewMigrationAdapter
    include LazyMigrate::Common

    attr_accessor :context

    def initialize
      # TODO: consider making this a method rather than an instance variable
      # considering how cheap it is to obtain
      @context = ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate'))
    end

    # example: ['up', 20200715030339, 'Add unique index to table']
    def find_migration_tuples
      context.migrations_status
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

      previous_version = find_previous_version(migration[:version])

      if previous_version.nil?
        # rails excludes the given version when calling .down so we need to
        # just down this instead
        down(migration)
      else
        context.down(previous_version)
      end
    end

    def find_previous_version(version)
      versions = context.migrations.map(&:version)

      return nil if version == versions.first

      previous_value(versions, version)
    end

    def find_filename_for_migration(migration)
      context.migrations.find { |m| m.version == migration[:version] }&.filename
    end

    def last_version
      context.migrations.last&.version
    end
  end
end
