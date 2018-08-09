require_relative 'lib/bitmask_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "bitmask_attributes"
  spec.version       = BitmaskAttributes::VERSION.dup
  spec.authors       = ['Joel Moss']
  spec.email         = "joel@developwithstyle.com"

  spec.summary       = %Q{Simple bitmask attribute support for ActiveRecord}
  spec.homepage      = "http://github.com/joelmoss/bitmask_attributes"
  spec.license       = "MIT"

  spec.files         = Dir['CHANGELOG.rdoc', 'README.rdoc', 'LICENSE', 'lib/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  rails_versions = ['>= 4.1', '< 6']
  spec.required_ruby_version = '>= 2.1'

  spec.add_runtime_dependency 'activerecord', rails_versions

  spec.add_development_dependency "sdoc"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'combustion', '~> 0.7'
end
