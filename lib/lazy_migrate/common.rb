# frozen_string_literal: true

module LazyMigrate
  module Common
    def previous_value(arr, value)
      arr.sort.select { |v| v < value }.last
    end
  end
end
