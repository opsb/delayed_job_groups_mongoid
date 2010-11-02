<h1>delayed_job_groups</h1>
<p>
	Adds grouping to jobs. Only 1 job in each group will be executed regardless of the number of workers.
</p>

<h2>Requires</h2>
<ul>
	<li>rails 3</li>
	<li>Latest version of delayed_job from github - current release(v2.1.0.pre2) does not support enqueue hooks</li>
	<li>active_record backend - other backends aren't supported'</li>
<ul>

<h2>Install</h2>
<p>
	# Gemfile
  gem 'delayed_job_groups', :require => false
  
  # application.rb
  AppName::Application.initialize!
  require 'delayed_job_groups; # must be loaded after delayed job has guessed backend 
</p>

<h2>Usage</h2>
<p>
	All that's required is a block that yields the group that should be used for jobs
</p>
<p>
	# active_record_model
	class Person < ActiveRecord::Base
	  job_group{ |person| person.department }
	end
</p>