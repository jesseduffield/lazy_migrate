# typed: false
# frozen_string_literal: true

require 'rails_helper'
require 'lazy_migrate/migration'

RSpec.describe LazyMigrate::Client do
  let(:rails_root) { Rails.root }

  let(:create_books_migration_status) {
    LazyMigrate::Migration.new(status: "up", version: 20200804231712, name: "Create books", has_file: true, current: false)
  }

  let(:add_author_migration_status_status) { 'up' }
  let(:add_author_migration_status) {
    LazyMigrate::Migration.new(status: add_author_migration_status_status, version: 20200804234040, name: "Add book author", has_file: true, current: false)
  }

  let(:add_page_count_migration_status) {
    LazyMigrate::Migration.new(status: "down", version: 20200804234057, name: "Add book page count", has_file: true, current: false)
  }

  let(:add_rating_migration_status) {
    LazyMigrate::Migration.new(status: "up", version: 20200804234111, name: "Add book rating", has_file: true, current: true)
  }

  let(:migrations) {
    [
      add_rating_migration_status,
      add_page_count_migration_status,
      add_author_migration_status,
      create_books_migration_status,
    ]
  }

  let(:migrator_adapter) { LazyMigrate::MigratorAdapterFactory.create_migrator_adapter }

  let(:new_version) { 30900804234040 }

  def find_support_folder
    File.join(File.dirname(File.dirname(__FILE__)), 'support')
  end

  before do
    # prepare the db directory
    support_folder = find_support_folder
    db_dir = ActiveRecord::Tasks::DatabaseTasks.db_dir

    schema_filename = File.join(db_dir, 'schema.rb')
    FileUtils.cp(File.join(support_folder, 'mock_schema.rb'), schema_filename)

    migrate_dir = File.join(db_dir, 'migrate')
    FileUtils.rm_rf(migrate_dir)
    FileUtils.cp_r(File.join(support_folder, 'mock_migrations/default/.'), migrate_dir)

    ActiveRecord::Migration.drop_table(:books) if ActiveRecord::Base.connection.table_exists?(:books)
    ActiveRecord::Migration.create_table "books", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    ActiveRecord::SchemaMigration.delete_all

    migrations.sort { |m| m.version }.each do |migration|
      if migration.status == 'up'
        ActiveRecord::SchemaMigration.create(version: migration.version)
      end
    end
  end

  after do
    db_dir = ActiveRecord::Tasks::DatabaseTasks.db_dir

    FileUtils.rm(File.join(db_dir, 'schema.rb'))
    FileUtils.rm_rf(File.join(db_dir, 'migrate'))
  end

  describe '.database_name' do
    it "returns without error" do
      expect { described_class.send(:database_name) }.not_to raise_error
    end
  end
end
