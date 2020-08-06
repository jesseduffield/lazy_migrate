# typed: false
# frozen_string_literal: true

require 'tty-prompt'
require 'active_record'
require 'rails'
require 'lazy_migrate/migrator_adapter_factory'

module LazyMigrate
  class Client
    class << self
      MIGRATE = 'migrate'
      ROLLBACK = 'rollback'
      UP = 'up'
      DOWN = 'down'
      REDO = 'redo'
      BRING_TO_TOP = 'bring to top'

      def run
        migrator_adapter = MigratorAdapterFactory.create_migrator_adapter

        loop do
          catch(:done) do
            on_done = -> { throw :done }

            prompt.ok("\nDatabase: #{ActiveRecord::Base.connection_config[:database]}\n")

            select_migration_prompt(on_done: on_done, migrator_adapter: migrator_adapter)
          end
        end
      rescue TTY::Reader::InputInterrupt
        puts
      end

      private

      def prompt
        TTY::Prompt.new(active_color: :bright_green)
      end

      def select_migration_prompt(on_done:, migrator_adapter:)
        prompt.select('Pick a migration') do |menu|
          migrator_adapter.find_migrations.each { |migration|
            name = render_migration_option(migration)

            menu.choice(
              name,
              -> {
                select_action_prompt(
                  on_done: on_done,
                  migrator_adapter: migrator_adapter,
                  migration: migration,
                )
              }
            )
          }
        end
      end

      def select_action_prompt(on_done:, migrator_adapter:, migration:)
        if !migration.has_file
          prompt.select("\nFile not found for migration version.") do |menu|
            menu.choice('remove version from version table', -> { migrator_adapter.remove_version_from_table(migration.version) })
            menu.choice('cancel', -> {})
          end
          on_done.()
        end

        option_map = obtain_option_map(migrator_adapter: migrator_adapter, on_done: on_done)

        prompt.select("\nWhat would you like to do for #{migration.version} #{name}?") do |menu|
          option_map.each do |label, on_press|
            menu.choice(label, -> {
              with_unsafe_error_capture { on_press.(migration) }
              migrator_adapter.dump_schema
              on_done.()
            })
          end

          menu.choice('cancel', on_done)
        end
      end

      def obtain_option_map(migrator_adapter:, on_done:)
        {
          MIGRATE => ->(migration) { migrator_adapter.migrate(migration.version) },
          ROLLBACK => ->(migration) { migrator_adapter.rollback(migration.version) },
          UP => ->(migration) { migrator_adapter.up(migration.version) },
          DOWN => ->(migration) { migrator_adapter.down(migration.version) },
          REDO => ->(migration) { migrator_adapter.redo(migration.version) },
          BRING_TO_TOP => ->(migration) { migrator_adapter.bring_to_top(migration: migration, ask_for_rerun: -> { ask_for_rerun(on_done) }) },
        }
      end

      def ask_for_rerun(on_done)
        prompt.select("\nMigration has been run. Would you like to `down` the migration before moving it, and then run it again after?") do |menu|
          menu.choice('yes, down and re-run the migration', -> { true })
          menu.choice('no, just bump the version without migrating anything', -> { false })
          menu.choice('cancel', -> { on_done.() })
        end
      end

      def render_migration_option(migration)
        "#{
          migration.status.ljust(6)
        }#{
          migration.version.to_s.ljust(16)
        }#{
          (migration.current ? 'current' : '').ljust(9)
        }#{
          migration.name
        }"
      end

      def with_unsafe_error_capture
        yield
      rescue Exception => e # rubocop:disable Lint/RescueException
        # I am aware you should not rescue 'Exception' exceptions but I think this is is an 'exceptional' use case
        prompt.error("\n#{e.class}: #{e.message}\n#{e.backtrace.take(5).join("\n")}")
      end
    end
  end
end
