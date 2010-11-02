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
    payload = job.payload_object
    if payload.class.has_job_groups?
      job.lock_group = payload.class.lock_group(payload)
      job.save
    end
  end  
end