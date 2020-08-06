# typed: strict
# frozen_string_literal: true

require "lazy_migrate/version"
require "lazy_migrate/client"

module LazyMigrate
  def self.run
    Client.run
  end
end
