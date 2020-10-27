# -*- encoding: utf-8 -*-
# stub: administrate-field-image 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "administrate-field-image".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Grayson Wright".freeze, "Nick Charlton".freeze]
  s.date = "2017-03-24"
  s.description = "Official Image field plugin for Administrate".freeze
  s.email = ["wright.grayson@gmail.com".freeze, "nick@nickcharlton.net".freeze]
  s.homepage = "https://github.com/graysonwright/administrate-field-image".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Official Image field plugin for Administrate".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<administrate>.freeze, [">= 0.2.0.rc1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
  else
    s.add_dependency(%q<administrate>.freeze, [">= 0.2.0.rc1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
  end
end
