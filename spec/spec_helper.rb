$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler/setup'
require 'logger'



ENV['RAILS_ENV'] = 'test'
require 'rails'

require 'active_record'
config = YAML.load(File.read('spec/database.yml'))
ActiveRecord::Base.configurations = {'test' => config['sqlite']}
ActiveRecord::Base.establish_connection
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.text     :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.datetime :failed_at
    table.string   :locked_by
    table.string   :lock_group
    table.timestamps
    
    table.integer :queue_id
  end
end

require 'rspec'
require 'delayed_job'

Delayed::Worker.logger = Logger.new('/tmp/dj.log')
ActiveRecord::Base.logger = Delayed::Worker.logger
Delayed::Worker.backend = :active_record

require 'delayed_job_groups'
RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.transaction_joinable = false
    ActiveRecord::Base.connection.begin_db_transaction
  end
  config.after do
    if ActiveRecord::Base.connection.open_transactions != 0
      ActiveRecord::Base.connection.rollback_db_transaction
      ActiveRecord::Base.connection.decrement_open_transactions
    end
    ActiveRecord::Base.clear_active_connections!
  end
end