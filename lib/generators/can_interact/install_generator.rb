# encoding: utf-8
require "rails/generators"
require "rails/generators/migration"
require "active_record"

# Генератор создаёт новую миграцию, которая создаёт таблицу interactions
module CanInteract
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path( "../templates", __FILE__ )
    desc "generates migration thats creates interactions table"

    def make_migration
      migration_template "migration.rb", "db/migrate/create_interactions"
    end

    private

    include Rails::Generators::Migration

    # Код взят из генератора моделей
    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      if ActiveRecord::Base.timestamped_migrations
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
      else
        "%.3d" % next_migration_number
      end
    end
  end
end