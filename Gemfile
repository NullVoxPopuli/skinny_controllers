# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in authorizable.gemspec
gemspec

version = ENV['RAILS_VERSION'] || '5.1'

if version == 'master'
  git 'https://github.com/rails/rails.git' do
    gem 'rails'
  end
else
  gem_version = "~> #{version}.0"

  gem 'rails', gem_version
end
