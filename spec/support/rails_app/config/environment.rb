# Load the Rails application.
require File.expand_path('../application', __FILE__)

Object.send(:remove_const, :SkinnyControllers) if defined? SkinnyControllers

gem_path = File.expand_path('../../../../../lib/', __FILE__)
$LOAD_PATH.unshift(gem_path) unless $LOAD_PATH.include?(gem_path)

require 'skinny_controllers'

# Initialize the Rails application.
Rails.application.initialize!
