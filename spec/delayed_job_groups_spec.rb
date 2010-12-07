require 'spec/spec_helper'

class GroupedJob
  include Mongoid::Document  
  include JobGroups
  field :repository
  
  job_group{ |simple_job| simple_job.repository }

  def perform
    puts "running grouped job"
  end
end

class SimpleJob
  include Mongoid::Document  
  include JobGroups
    
  def perform
    puts "running simple job"
  end
end

class User
  include Mongoid::Document  
  include JobGroups
    
  job_group{ |user| user.role }  
  def send_welcome_email
    puts "thanking user"
  end
  handle_asynchronously :send_welcome_email  
  def expensive_operation
    puts "working hard"
  end
end

module Delayed
  class Backend::Mongoid::Job
    def lock!(worker, time = Time.now.utc)
      self.locked_by = worker.name
      self.locked_at = time
      save!
    end
  end
end

describe Delayed::Job do
  Delayed::Worker.max_run_time = MAX_RUN_TIME = 5.hours
  WORKER = OpenStruct.new.tap{|worker| worker.name = "name_of_worker"}
  
  context "a job" do
    before do
      Delayed::Job.enqueue GroupedJob.new(:repository => "repo1")
    end
    
    it "should have a job group" do
      Delayed::Job.first.lock_group.should == "repo1"
    end
  end
  
  context "with 2 jobs in the same group, one locked, one unlocked and 1 job in a different group" do
    before do
      2.times do |n|
        Delayed::Job.enqueue GroupedJob.new(:repository => 'repo1', :priority => n)
      end
      1.times{ Delayed::Job.enqueue GroupedJob.new(:repository => 'repo2', :priority => 3) }
      Delayed::Job.where(:lock_group => "repo1").first.lock!(WORKER)
    end
    
    it "should have one locked job" do
      Delayed::Job.locked_jobs.count.should == 1
    end
    
    it "should have one locked group" do
      Delayed::Job.locked_groups.should == ['repo1']
    end
    
    it "should not reserve job from same group" do
      Delayed::Job.reserve(WORKER).lock_group.should_not == "repo1"
    end
  end
  
  context "job with no group" do
    before do
      Delayed::Job.enqueue SimpleJob.new
    end
    it "should still be queuable" do
      Delayed::Job.reserve(WORKER).should_not be_nil
    end
  end
  
  context "with 2 jobs in the same group, from methods declared as asynchronous, one unlocked and 1 job in a different group" do
    before do
      2.times do
        User.create(:role => "admin").send_welcome_email
      end
      1.times{ User.create(:role => "PA").send_welcome_email }   
      Delayed::Job.where(:lock_group => "admin").first.lock!(WORKER)
    end
    
    it "should only find the job in the different group" do
      Delayed::Job.reserve(WORKER).lock_group.should == "PA"
    end
  end
  
  context "with 2 jobs in the same group, from delay() calls, one unlocked and 1 job in a different group" do
    before do
      2.times do
        User.create(:role => "admin").delay.expensive_operation
      end
      1.times{ Delayed::Job.enqueue GroupedJob.new(:repository => "repo2") }   
      Delayed::Job.where(:lock_group => "admin").each{ |job| job.update :priority => 1}
      Delayed::Job.where(:lock_group => "repo2").each{ |job| job.update :priority => 2}
      Delayed::Job.where(:lock_group => "admin").first.lock!(WORKER)
    end
    
    it "should find only the job in the different group" do
      Delayed::Job.reserve(WORKER).lock_group.should == "repo2"
    end
  end  
  
  context "with 2 jobs in the same group, one timed out" do
    before do
      @timed_out, @other = (1..2).map{ Delayed::Job.enqueue GroupedJob.new(:repository => "repo1") }
      @timed_out.lock!(WORKER)
      Timecop.freeze(Time.now.utc + MAX_RUN_TIME + 1.minute)
    end
    
    after do
      Timecop.return
    end

    it "should find no locked jobs" do
      Delayed::Job.locked_jobs(MAX_RUN_TIME).count.should == 0
    end
  end
end