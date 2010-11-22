module JobGroups
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
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
    payload = job.payload_object
    target = payload.class == ::Delayed::PerformableMethod ? payload.object : payload    
    if target.class.has_job_groups?
      job.lock_group = target.class.lock_group(target)
      job.save
    end
  end  
end