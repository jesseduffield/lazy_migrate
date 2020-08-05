# typed: false
# frozen_string_literal: true

module LazyMigrate
  Migration = Struct.new(:status, :version, :name, :has_file, :current)
end
