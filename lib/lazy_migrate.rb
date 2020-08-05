# typed: strict
# frozen_string_literal: true

require "lazy_migrate/version"
require "lazy_migrate/migrator"

module LazyMigrate
  def self.run
    Migrator.run
  end
end
