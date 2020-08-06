# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module LazyMigrate
  class Migration < T::Struct
    prop :status, String
    const :version, Integer
    const :name, String
    prop :has_file, T::Boolean
    prop :current, T::Boolean
  end
end
