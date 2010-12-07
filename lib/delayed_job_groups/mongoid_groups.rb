require 'delayed_job'


module Delayed
  class Backend::Mongoid::Job
    field :lock_group
    scope :in_unlocked_group, lambda{ where(:lock_group.nin => self.locked_groups) }
    scope :locked_jobs, lambda{ where(:locked_at.gt => time_out_threshold ) }
    
    def self.time_out_threshold
      db_time_now - Delayed::Worker.max_run_time
    end

    def self.locked_groups
      Delayed::Job.locked_jobs.only(:lock_group).group.map{ |grouping| grouping["lock_group"] }
    end

    def self.reserve(worker, max_run_time = Worker.max_run_time)
      right_now = db_time_now

      conditions = {:run_at  => {"$lte" => right_now}, :failed_at => nil, :lock_group => { "$nin" => self.locked_groups } }
      (conditions[:priority] ||= {})['$gte'] = Worker.min_priority.to_i if Worker.min_priority
      (conditions[:priority] ||= {})['$lte'] = Worker.max_priority.to_i if Worker.max_priority

      where = "this.locked_by == '#{worker.name}' || this.locked_at == null || this.locked_at < #{make_date(right_now - max_run_time)}"
      conditions.merge!('$where' => where)

      begin
        result = self.db.collection(self.collection.name).find_and_modify(:query => conditions, :sort => [['locked_by', -1], ['priority', 1], ['run_at', 1]], :update => {"$set" => {:locked_at => right_now, :locked_by => worker.name}})
        # Return result as a Mongoid document.
        # When Mongoid starts supporting findAndModify, this extra step should no longer be necessary.
        self.find(:first, :conditions => {:_id => result["_id"]})
      rescue Mongo::OperationFailure
        nil # no jobs available
      end
    end    
  end
end