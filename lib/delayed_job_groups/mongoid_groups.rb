require 'delayed_job'


module Delayed
  class Backend::Mongoid::Job
    field :lock_group
    scope :in_unlocked_group, lambda{ where(:lock_group.nin => self.locked_groups) }
    
    def self.locked_groups
      Delayed::Job.only(:lock_group).where(:locked_by.ne => nil).group.map{ |grouping| grouping["lock_group"] }
    end

    def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
      right_now = db_time_now

      conditions = {:run_at  => {"$lte" => right_now}, :failed_at => nil}
      (conditions[:priority] ||= {})['$gte'] = Worker.min_priority.to_i if Worker.min_priority
      (conditions[:priority] ||= {})['$lte'] = Worker.max_priority.to_i if Worker.max_priority


      where = "this.locked_at == null || this.locked_at < #{make_date(right_now - max_run_time)}"
      results = self.in_unlocked_group.where(conditions.merge(:locked_by => worker_name)).limit(-limit).order_by([['priority', 1], ['run_at', 1]]).to_a
      results += self.in_unlocked_group.where(conditions.merge('$where' => where)).limit(-limit+results.size).order_by([['priority', 1], ['run_at', 1]]).to_a if results.size < limit
      results
    end

  end
end