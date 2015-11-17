require 'spec_helper'

require 'rails/all'
require 'factory_girl'
require 'factory_girl_rails'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

require 'support/rails_app/config/environment'

# set up db
# be sure to update the schema if required by doing
# - cd spec/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load "support/rails_app/db/schema.rb" # use db agnostic schema by default


require 'support/rails_app/factory_girl'
# require 'support/rails_app/factories'
