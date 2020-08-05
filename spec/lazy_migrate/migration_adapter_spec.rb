# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LazyMigrate::MigrationAdapter do
  let(:rails_root) { Rails.root }

  let(:create_books_migration_status) {
    { status: "up", version: 20200804231712, name: "Create books", has_file: true, current: false }
  }

  let(:add_author_migration_status_status) { 'up' }
  let(:add_author_migration_status) {
    { status: add_author_migration_status_status, version: 20200804234040, name: "Add book author", has_file: true, current: false }
  }

  let(:add_page_count_migration_status) {
    { status: "down", version: 20200804234057, name: "Add book page count", has_file: true, current: false }
  }

  let(:add_rating_migration_status) {
    { status: "up", version: 20200804234111, name: "Add book rating", has_file: true, current: true }
  }

  let(:migrations) {
    [
      add_rating_migration_status,
      add_page_count_migration_status,
      add_author_migration_status,
      create_books_migration_status,
    ]
  }

  let(:migration_adapter) { LazyMigrate::NewMigrationAdapter.new }

  let(:new_version) { 30900804234040 }

  before do
    # prepare the db directory

    support_folder = File.join(File.dirname(File.dirname(__FILE__)), 'support')
    db_dir = rails_root.join('db')
    FileUtils.cp(File.join(support_folder, 'mock_schema.rb'), File.join(db_dir, 'schema.rb'))

    migrate_dir = File.join(db_dir, 'migrate')
    FileUtils.rm_rf(migrate_dir)
    FileUtils.cp_r(File.join(support_folder, 'mock_migrations/.'), migrate_dir)

    ActiveRecord::SchemaMigration.delete_all

    migrations.sort { |m| m[:version] }.each do |migration|
      if migration[:status] == 'up'
        ActiveRecord::SchemaMigration.create(version: migration[:version])
      end
    end
  end

  describe '.find_migrations' do
    it "finds migrations" do
      expect(migration_adapter.find_migrations).to eq(migrations)
    end
  end

  describe '.replace_version_in_filename' do
    let(:filename) { '20200804231712_create_books.rb' }

    subject { migration_adapter.replace_version_in_filename(filename, new_version) }

    it { is_expected.to eq "./#{new_version}_create_books.rb" }
  end

  describe '.bring_to_top' do
    let(:migration) { add_author_migration_status }
    let(:rerun) { false }

    subject { migration_adapter.bring_to_top(migration: migration, ask_for_rerun: -> { rerun }) }

    before do
      expect(ActiveRecord::Migration).to receive(:next_migration_number).with(add_rating_migration_status[:version] + 1).and_return(new_version.to_s)
    end

    shared_examples 'renames file' do
      it 'renames file to have new version' do
        subject

        new_file_exists = File.exist?(
          rails_root.join('db', 'migrate', "#{new_version}_add_book_author.rb")
        )

        old_file_exists = File.exist?(
          rails_root.join('db', 'migrate', '20200804234040_add_book_author.rb')
        )

        expect(new_file_exists).to be true
        expect(old_file_exists).to be false
      end
    end

    shared_examples 'does not run migrations' do
      it 'does not run migrations' do
        expect(Rails.logger).to receive(:info).with("Migrating to AddBookAuthor (20200804234040)").never
        expect(Rails.logger).to receive(:info).with("Migrating to AddBookAuthor (#{new_version})").never

        subject
      end
    end

    context 'when migration is down' do
      let(:add_author_migration_status_status) { 'down' }

      include_examples 'renames file'
      include_examples 'does not run migrations'

      it 'does not change schema migration table' do
        expect { subject }.not_to(change { ActiveRecord::SchemaMigration.all.map(&:version) }.from([
          create_books_migration_status[:version],
          add_rating_migration_status[:version],
        ]))
      end
    end

    context 'when migration is up' do
      let(:migration) { add_author_migration_status }

      shared_examples 'swaps version in schema_versions' do
        it 'swaps version in schema_versions' do
          expect { subject }
            .to change { ActiveRecord::SchemaMigration.all.map(&:version) }
            .from([
              create_books_migration_status[:version],
              add_author_migration_status[:version],
              add_rating_migration_status[:version],
            ])
            .to([
              create_books_migration_status[:version],
              add_rating_migration_status[:version],
              new_version,
            ])
        end
      end

      context 'when we do not want to rerun the migration' do
        include_examples 'renames file'
        include_examples 'swaps version in schema_versions'
        include_examples 'does not run migrations'
      end

      context 'when we want to rerun the migration' do
        let(:rerun) { true }

        include_examples 'renames file'
        include_examples 'swaps version in schema_versions'

        it 'brings to top and reruns' do
          expect(Rails.logger).to receive(:info).with('Migrating to AddBookAuthor (20200804234040)').ordered
          expect(Rails.logger).to receive(:info).with("Migrating to AddBookAuthor (#{new_version})").ordered

          subject
        end
      end
    end
  end
end
