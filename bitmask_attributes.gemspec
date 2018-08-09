# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bitmask_attributes/version"

Gem::Specification.new do |spec|
  spec.name          = "bitmask_attributes"
  spec.summary       = %Q{Simple bitmask attribute support for ActiveRecord}
  spec.email         = "joel@developwithstyle.com"
  spec.homepage      = "http://github.com/joelmoss/bitmask_attributes"
  spec.authors       = ['Joel Moss']

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ['lib']
  spec.version       = BitmaskAttributes::VERSION.dup

  rails_versions = ['>= 4.1', '< 6']
  spec.required_ruby_version = '>= 2.1'

  spec.add_runtime_dependency 'activerecord', rails_versions

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'combustion', '~> 0.7'
end
