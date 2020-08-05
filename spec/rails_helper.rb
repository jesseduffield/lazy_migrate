# frozen_string_literal: true

require 'rails/all'
# require 'rspec/rails'
version_underlined = Rails.version.gsub('.', '_')
require "support/rails_app_#{version_underlined}/config/environment"

support_folder = File.join(File.dirname(__FILE__), 'support')
db_dir = ActiveRecord::Tasks::DatabaseTasks.db_dir
schema_filename = File.join(db_dir, 'schema.rb')
FileUtils.cp(File.join(support_folder, 'mock_schema.rb'), schema_filename)

ActiveRecord::Migration.maintain_test_schema!

ActiveRecord::Schema.verbose = false
load "support/rails_app_#{version_underlined}/db/schema.rb"

require 'spec_helper'