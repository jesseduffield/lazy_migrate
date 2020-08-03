# frozen_string_literal: true

class MigrationAdapter
  def initialize
    if Rails.version > '5.2.0'
      (class << self; include NewMigrationAdapter; end)
    else
      (class << self; include OldMigrationAdapater; end)
    end
  end
end