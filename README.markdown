delayed job groups
==================

Adds grouping to jobs. Only 1 job in each group will be executed regardless of the number of workers.


Requires
--------

* rails 3
* Latest version of delayed_job from github - current release(v2.1.0.pre2) does not support enqueue hooks
* active_record backend - other backends aren't supported'


Install
-------

    # Gemfile
    gem 'delayed_job_groups', :require => false
  
    # config/environment.rb
    AppName::Application.initialize!
    require 'delayed_job_groups; # must be loaded after delayed job has guessed backend 

Add migration to add lock_group column

    # db/migrate/xxx_add_lock_group_to_delayed_jobs
    class AddLockGroupToDelayedJobs < ActiveRecord::Migration
      def self.up
        add_column :delayed_jobs, :lock_group, :string
      end

      def self.down
        remove_column :delayed_jobs, :lock_group
      end
    end


Usage
-----

Job groups are strings. You need to specify what the job_group should be in a block. Delayed job will only perform 1 job from each group at a time.

### Job groups for standard jobs ###

	 class ResizeImageJob < Struct.new(:format)
		 job_group{ |resize_image_job| resize_image_job.format }
		
		 def perform
			 resize_to format
		 end
	 end

	
### Job groups when using delay() ###

	 class Person < ActiveRecord::Base
		 job_group{ |person| person.role }
		
		 def send_welcome
		    ...
		 end
	 end
	
	 Person.create(:role => "admin").delay.send_welcome
	
### Job groups when methods are declared asynchonous ###

	 class Person < ActiveRecord::Base
		 job_group{ |person| person.role }

		 def send_welcome
		    ...
		 end
		 handle_asynchronously :send_welcome
	 end

	 Person.create(:role => "admin").send_welcome
