# typed: strict
# frozen_string_literal: true

require 'lazy_migrate/migrator_adapter'
require 'lazy_migrate/migration'

module LazyMigrate
  class NewMigratorAdapter < MigratorAdapter
    extend T::Sig

    sig { returns(ActiveRecord::MigrationContext) }
    attr_accessor :context

    sig { void }
    def initialize
      # TODO: consider making this a method rather than an instance variable
      # considering how cheap it is to obtain
      @context = T.let(ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate')), ActiveRecord::MigrationContext)
    end

    sig { override.params(version: Integer).void }
    def up(version)
      context.run(:up, version)
    end

    sig { override.params(version: Integer).void }
    def down(version)
      context.run(:down, version)
    end

    sig { override.params(version: Integer).void }
    def redo(version)
      down(version)
      up(version)
    end

    sig { override.params(version: Integer).void }
    def migrate(version)
      context.up(version)
    end

    sig { override.params(version: Integer).void }
    def rollback(version)
      # for some reason in https://github.com/rails/rails/blob/5-2-stable/activerecord/lib/active_record/migration.rb#L1221
      # we stop before the selected version. I have no idea why.

      previous_version = find_previous_version(version)

      if previous_version.nil?
        # rails excludes the given version when calling .down so we need to
        # just down this instead
        down(version)
      else
        context.down(previous_version)
      end
    end

    protected

    # example: [['up', '20200715030339', 'Add unique index to table']]
    sig { override.returns(T::Array[[String, String, String]]) }
    def find_migration_tuples
      context.migrations_status
    end

    sig { override.params(version: Integer).returns(T.nilable(Integer)) }
    def find_previous_version(version)
      versions = context.migrations.map(&:version)

      return nil if version == versions.first

      previous_value(versions, version)
    end

    sig { override.params(migration: LazyMigrate::Migration).returns(T.nilable(String)) }
    def find_filename_for_migration(migration)
      context.migrations.find { |m| m.version == migration.version }&.filename
    end

    sig { override.returns(T.nilable(Integer)) }
    def last_version
      context.migrations.last&.version
    end
  end
end
