# frozen_string_literal: true

require 'rails/all'
# require 'rspec/rails'
require 'support/rails_app/config/environment'

ActiveRecord::Migration.maintain_test_schema!

ActiveRecord::Schema.verbose = false
load 'support/rails_app/db/schema.rb'

require 'spec_helper'