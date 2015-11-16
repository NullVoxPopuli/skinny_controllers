# -*- encoding: utf-8 -*-

# allows bundler to use the gemspec for dependencies
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'skinny_controllers/version'

Gem::Specification.new do |s|
  s.name        = 'skinny_controllers'
  s.version     = SkinnyControllers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['L. Preston Sego III']
  s.email       = 'LPSego3+dev@gmail.com'
  s.homepage    = 'https://github.com/NullVoxPopuli/skinny-controllers'
  s.summary     = "SkinnyControllers-#{SkinnyControllers::VERSION}"
  s.description = 'An implementation of role-based policies and operations to help controllers lose weight.'

  s.files        = Dir['CHANGELOG.md', 'LICENSE' 'MIT-LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'

  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'activesupport'

  s.add_development_dependency 'rails'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'rubocop'
end
