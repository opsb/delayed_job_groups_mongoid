# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile.rb, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delayed_job_groups}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["opsb"]
  s.date = %q{2010-12-07}
  s.description = %q{Adds job groups to delayed_job}
  s.email = %q{oliver@opsb.co.uk}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "README.markdown",
    "Rakefile.rb",
    "VERSION",
    "config.ru",
    "delayed_job_groups_mongoid.gemspec",
    "lib/delayed_job_groups/init.rb",
    "lib/delayed_job_groups/job_groups.rb",
    "lib/delayed_job_groups/mongoid_groups.rb",
    "lib/delayed_job_groups_mongoid.rb",
    "spec/database.yml",
    "spec/delayed_job_groups_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/opsb/delayed_job_groups}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Adds job groups to delayed_job}
  s.test_files = [
    "spec/delayed_job_groups_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 0"])
      s.add_runtime_dependency(%q<delayed_job>, ["= 2.1.1"])
      s.add_runtime_dependency(%q<delayed_job_mongoid>, ["= 1.0.1"])
      s.add_runtime_dependency(%q<mongoid>, ["= 2.0.0.beta.20"])
      s.add_runtime_dependency(%q<bson_ext>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<delayed_job>, ["= 2.1.1"])
      s.add_dependency(%q<delayed_job_mongoid>, ["= 1.0.1"])
      s.add_dependency(%q<mongoid>, ["= 2.0.0.beta.20"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<delayed_job>, ["= 2.1.1"])
    s.add_dependency(%q<delayed_job_mongoid>, ["= 1.0.1"])
    s.add_dependency(%q<mongoid>, ["= 2.0.0.beta.20"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
  end
end

