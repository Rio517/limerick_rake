#borrowed from http://www.manu-j.com/blog/truncate-all-tables-in-a-ruby-on-rails-application/221/

namespace :db do
  task :load_config => :rails_env do
    require 'active_record'
    ActiveRecord::Base.configurations = Rails::VERSION::MAJOR == 2 ? Rails::Configuration.new.database_configuration : Rails::Application::config.database_configuration
  end
 
  desc "Create Sample Data for the application"
  task(:truncate => :load_config) do
   begin
    config = ActiveRecord::Base.configurations[Rails.env]
    ActiveRecord::Base.establish_connection
    case config["adapter"]
      when "mysql", "postgresql"
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.execute("TRUNCATE #{table}") unless table == 'schema_migrations'
        end
      when "sqlite", "sqlite3"
        ActiveRecord::Base.connection.tables.each do |table|
          unless table == 'schema_migrations'
            ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
            ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence where name='#{table}'")
          end
        end
       ActiveRecord::Base.connection.execute("VACUUM")
     end
     rescue
      $stderr.puts "Error while truncating. Make sure you have a valid database.yml file and have created the database tables before running this command. You should be able to run rake db:migrate without an error"
    end
  end
end