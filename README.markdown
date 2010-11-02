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
  
    # application.rb
    AppName::Application.initialize!
    require 'delayed_job_groups; # must be loaded after delayed job has guessed backend 

Usage
-----

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
