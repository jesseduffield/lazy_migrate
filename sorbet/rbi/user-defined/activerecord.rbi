# typed: strict
class ActiveRecord::Migrator::Compatibility::V5_1
  def current; end
  def current_migration; end
  def current_version; end
  def ddl_transaction(migration); end
  def down?; end
  def execute_migration_in_transaction(migration, direction); end
  def finish; end
  def generate_migrator_advisory_lock_id; end
  def initialize(direction, migrations, target_version = nil); end
  def invalid_target?; end
  def load_migrated; end
  def migrate; end
  def migrate_without_lock; end
  def migrated; end
  def migrations; end
  def pending_migrations; end
  def ran?(migration); end
  def record_environment; end
  def record_version_state_after_migrating(version); end
  def run; end
  def run_without_lock; end
  def runnable; end
  def self.any_migrations?; end
  def self.current_environment; end
  def self.current_version(connection = nil); end
  def self.down(migrations_paths, target_version = nil); end
  def self.forward(migrations_paths, steps = nil); end
  def self.get_all_versions(connection = nil); end
  def self.last_migration; end
  def self.last_stored_environment; end
  def self.migrate(migrations_paths, target_version = nil, &block); end
  def self.migration_files(paths); end
  def self.migrations(paths); end
  def self.migrations_path=(arg0); end
  def self.migrations_paths; end
  def self.migrations_paths=(arg0); end
  def self.migrations_status(paths); end
  def self.move(direction, migrations_paths, steps); end
  def self.needs_migration?(connection = nil); end
  def self.open(migrations_paths); end
  def self.parse_migration_filename(filename); end
  def self.protected_environment?; end
  def self.rollback(migrations_paths, steps = nil); end
  def self.run(direction, migrations_paths, target_version); end
  def self.schema_migrations_table_name(*args, &block); end
  def self.up(migrations_paths, target_version = nil); end
  def start; end
  def target; end
  def up?; end
  def use_advisory_lock?; end
  def use_transaction?(migration); end
  def validate(migrations); end
  def with_advisory_lock; end
end
