$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'mongoid'
require 'ap'
require 'timecop'



ENV['RAILS_ENV'] = 'test'
require 'rails'

Mongoid.configure do |config|
  name = "delayed_job_groups_mongoid"
  host = "localhost"
  
  if ENV['ZENSLAP_ID']
    config.from_hash("uri" => ENV['MONGOHQ_URL'])
  else
    config.master = Mongo::Connection.new.db(name)
    config.slaves = [
      Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)
    ]
  end
  config.persist_in_safe_mode = false
end


require 'rspec'
require 'delayed_job'

Delayed::Worker.logger = Logger.new('/tmp/dj.log')

Delayed::Worker.backend = :mongoid

require 'delayed_job_groups/init.rb'
RSpec.configure do |config|
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  config.after(:each) do
    ::Mongoid.database.collections.select{ |c| c.name !~ /^system/ }.each{ |condemned| condemned.remove }    
    # DatabaseCleaner.clean
  end  
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true  
end