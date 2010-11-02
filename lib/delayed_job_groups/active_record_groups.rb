class ActiveRecord::Base
  class << self
    def job_group(&block)
      @lock_group_factory = block
    end
    
    def has_job_groups?
      !!@lock_group_factory
    end

    def lock_group(payload)
      @lock_group_factory.call(payload)
    end    
  end
  
  def enqueue(job)
    target = job.payload_object.class == ::Delayed::PerformableMethod ? job.payload_object.object : job.payload_object    
    if target.class.has_job_groups?
      job.lock_group = target.class.lock_group(target)
      job.save
    end
  end  
end