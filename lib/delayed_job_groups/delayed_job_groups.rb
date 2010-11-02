require 'delayed_job'

class Delayed::Backend::ActiveRecord::Job
  scope :in_unlocked_group, lambda{
    delayed_jobs = self.table_name
    unlocked_groups_select = "select distinct #{delayed_jobs}.lock_group from #{delayed_jobs} where #{delayed_jobs}.locked_by is not null"
    where("#{delayed_jobs}.lock_group not in (#{unlocked_groups_select}) or #{delayed_jobs}.lock_group is null")
  }
  scope :orig_ready_to_run, scopes[:ready_to_run]
  scope :ready_to_run, lambda{ |*args|
    orig_ready_to_run(*args).
    in_unlocked_group
  }
end