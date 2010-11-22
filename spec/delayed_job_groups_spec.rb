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

describe Delayed::Job do
  MAX_RUN_TIME = 4000 # seconds? TBC
  WORKER = 'name_of_worker'
  
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
      group_a_job1 = GroupedJob.new(:repository => "repo1")
      group_a_job2 = GroupedJob.new(:repository => "repo1")
      @group_b_job1 = GroupedJob.new(:repository => "repo2")
      
      [group_a_job1, @group_b_job1].each{ |job| Delayed::Job.enqueue job }
      queued_job = Delayed::Job.enqueue group_a_job2
      queued_job.lock_exclusively!(MAX_RUN_TIME, WORKER)      
    end
    
    it "should find no unlocked jobs" do
      Delayed::Job.find_available(WORKER, MAX_RUN_TIME).count.should == 1
    end
  end
  
  context "job with no group" do
    before do
      Delayed::Job.enqueue SimpleJob.new
    end
    it "should still be queuable" do
      Delayed::Job.find_available(WORKER, MAX_RUN_TIME).count.should == 1
    end
  end
  
  context "with 2 jobs in the same group, from methods declared as asynchronous, one unlocked and 1 job in a different group" do
    before do
      2.times do
        User.create(:role => "admin").send_welcome_email
      end
      1.times{ Delayed::Job.enqueue GroupedJob.new(:repository => "repo2") }      
      Delayed::Job.first.lock_exclusively!(MAX_RUN_TIME, WORKER)
      
    end
    
    it "should find no jobs that are ready to run" do
      Delayed::Job.find_available(WORKER, MAX_RUN_TIME).count.should == 1
    end
  end
  
  context "with 2 jobs in the same group, from delay() calls, one unlocked and 1 job in a different group" do
    before do
      2.times do
        User.create(:role => "admin").delay.expensive_operation
      end
      1.times{ Delayed::Job.enqueue GroupedJob.new(:repository => "repo2") }      
      Delayed::Job.first.lock_exclusively!(MAX_RUN_TIME, WORKER)
      
    end
    
    it "should find no jobs that are ready to run" do
      Delayed::Job.find_available(WORKER, MAX_RUN_TIME).count.should == 1
    end
  end  
end