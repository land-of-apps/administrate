# -*- encoding: utf-8 -*-
# stub: rack-timeout 0.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-timeout".freeze
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/sharpstone/rack-timeout/issues", "changelog_uri" => "https://github.com/sharpstone/rack-timeout/blob/v0.6.0/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/gems/rack-timeout/0.6.0/", "source_code_uri" => "https://github.com/sharpstone/rack-timeout" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Caio Chassot".freeze]
  s.date = "2019-12-11"
  s.description = "Rack middleware which aborts requests that have been running for longer than a specified timeout.".freeze
  s.email = "caio@heroku.com".freeze
  s.homepage = "https://github.com/sharpstone/rack-timeout".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Abort requests that are taking too long".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
  end
end
