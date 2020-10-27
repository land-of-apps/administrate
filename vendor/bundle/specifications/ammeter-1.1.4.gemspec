# -*- encoding: utf-8 -*-
# stub: ammeter 1.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "ammeter".freeze
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rothenberg".freeze]
  s.date = "2016-09-23"
  s.description = "Write specs for your Rails 3+ generators".freeze
  s.email = ["alex@alexrothenberg.com".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Write specs for your Rails 3+ generators".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 3.0"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_runtime_dependency(%q<rspec-rails>.freeze, [">= 2.2"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 2.2"])
    s.add_development_dependency(%q<rails>.freeze, [">= 3.1"])
    s.add_development_dependency(%q<uglifier>.freeze, [">= 1.2.4"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0.9.2.2"])
    s.add_development_dependency(%q<coffee-rails>.freeze, [">= 3.2.2"])
    s.add_development_dependency(%q<sass-rails>.freeze, [">= 3.2.5"])
    s.add_development_dependency(%q<jquery-rails>.freeze, [">= 2.0.2"])
    s.add_development_dependency(%q<haml-rails>.freeze, [">= 0.4"])
    s.add_development_dependency(%q<cucumber>.freeze, [">= 0.10"])
    s.add_development_dependency(%q<aruba>.freeze, [">= 0.3"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 1"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 2.2"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.2"])
    s.add_dependency(%q<rails>.freeze, [">= 3.1"])
    s.add_dependency(%q<uglifier>.freeze, [">= 1.2.4"])
    s.add_dependency(%q<rake>.freeze, [">= 0.9.2.2"])
    s.add_dependency(%q<coffee-rails>.freeze, [">= 3.2.2"])
    s.add_dependency(%q<sass-rails>.freeze, [">= 3.2.5"])
    s.add_dependency(%q<jquery-rails>.freeze, [">= 2.0.2"])
    s.add_dependency(%q<haml-rails>.freeze, [">= 0.4"])
    s.add_dependency(%q<cucumber>.freeze, [">= 0.10"])
    s.add_dependency(%q<aruba>.freeze, [">= 0.3"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 1"])
  end
end
