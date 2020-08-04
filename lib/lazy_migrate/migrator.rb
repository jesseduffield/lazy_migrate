# frozen_string_literal: true

require 'tty-prompt'
require 'active_record'
require 'rails'
require 'lazy_migrate/migration_adapter_factory'

module LazyMigrate
  class Migrator
    class << self
      MIGRATE = 'migrate'
      ROLLBACK = 'rollback'
      UP = 'up'
      DOWN = 'down'
      REDO = 'redo'
      BRING_TO_TOP = 'bring to top'

      def run
        migration_adapter = MigrationAdapterFactory.create_migration_adapter

        loop do
          catch(:done) do
            on_done = -> { throw :done }

            prompt.ok("\nDatabase: #{ActiveRecord::Base.connection_config[:database]}\n")

            select_migration_prompt(on_done: on_done, migration_adapter: migration_adapter)
          end
        end
      rescue TTY::Reader::InputInterrupt
        puts
      end

      private

      def prompt
        TTY::Prompt.new(active_color: :bright_green)
      end

      def select_migration_prompt(on_done:, migration_adapter:)
        prompt.select('Pick a migration') do |menu|
          migration_adapter.find_migrations.each { |migration|
            name = render_migration_option(migration)

            menu.choice(
              name,
              -> {
                select_action_prompt(
                  on_done: on_done,
                  migration_adapter: migration_adapter,
                  migration: migration,
                )
              }
            )
          }
        end
      end

      def select_action_prompt(on_done:, migration_adapter:, migration:)
        if !migration[:has_file]
          prompt.error("\nMigration file not found for migration #{migration[:version]}")
          on_done.()
        end

        option_map = obtain_option_map(migration_adapter: migration_adapter)

        prompt.select("\nWhat would you like to do for #{migration[:version]} #{name}?") do |inner_menu|
          options_for_migration(status: migration[:status]).each do |option|
            inner_menu.choice(option, -> {
              with_unsafe_error_capture do
                option_map[option].(migration)
              end
              migration_adapter.dump_schema
              on_done.()
            })
          end

          inner_menu.choice('cancel', on_done)
        end
      end

      def options_for_migration(status:)
        common_options = [MIGRATE, ROLLBACK, BRING_TO_TOP]
        specific_options = if status == 'up'
          [DOWN, REDO]
        else
          [UP]
        end
        specific_options + common_options
      end

      def obtain_option_map(migration_adapter:)
        {
          UP => ->(migration) { migration_adapter.up(migration[:version]) },
          DOWN => ->(migration) { migration_adapter.down(migration[:version]) },
          REDO => ->(migration) { migration_adapter.redo(migration[:version]) },
          MIGRATE => ->(migration) { migration_adapter.migrate(migration[:version]) },
          ROLLBACK => ->(migration) { migration_adapter.rollback(migration[:version]) },
          BRING_TO_TOP => ->(migration) { migration_adapter.bring_to_top(migration: migration, ask_for_rerun: -> { ask_for_rerun }) },
        }
      end

      def ask_for_rerun
        prompt.yes?('Migration has been run. Would you like to `down` the migration before moving it, and then run it again after?')
      end

      def render_migration_option(migration)
        "#{
          migration[:status].ljust(6)
        }#{
          migration[:version].to_s.ljust(16)
        }#{
          (migration[:current] ? 'current' : '').ljust(9)
        }#{
          migration[:name].ljust(50)
        }"
      end

      def with_unsafe_error_capture
        yield
      rescue Exception => e # rubocop:disable Lint/RescueException
        # I am aware you should not rescue 'Exception' exceptions but I think this is is an 'exceptional' use case
        puts "\n#{e.class}: #{e.message}\n#{e.backtrace.take(5).join("\n")}"
      end
    end
  end

  def self.run
    Migrator.run
  end
end
