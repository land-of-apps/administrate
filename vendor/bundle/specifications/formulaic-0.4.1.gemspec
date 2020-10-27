# -*- encoding: utf-8 -*-
# stub: formulaic 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "formulaic".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Caleb Thompson".freeze]
  s.date = "2019-01-30"
  s.description = "Removes the tedium of formulaic form filling with Capybara by allowing you\n    to specify a hash of attributes to be input rather than procedurally calling\n    Capybara\u2019s DSL methods.\n".freeze
  s.email = ["caleb@calebthompson.io".freeze]
  s.homepage = "https://github.com/thoughtbot/formulaic".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Simplify form filling with Capybara".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<i18n>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  else
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<i18n>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
  end
end
