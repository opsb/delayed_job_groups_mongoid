module DelayedJobGroups
  class Railtie < Rails::Railtie
    initializer "delayed_job_groups.initialize" do |app|
      require File.dirname(__FILE__) + '/delayed_job_groups/init.rb'  
    end
  end
end
