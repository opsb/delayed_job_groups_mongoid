require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "delayed_job_groups"
    gem.summary = %Q{Adds job groups to delayed_job}
    gem.description = %Q{Adds job groups to delayed_job}
    gem.email = "oliver@opsb.co.uk"
    gem.homepage = "http://github.com/opsb/delayed_job_groups"
    gem.authors = ["opsb"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
