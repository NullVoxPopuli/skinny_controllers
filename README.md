# skinny-controllers
[![Gem Version](http://img.shields.io/gem/v/skinny_controllers.svg?style=flat-square)](http://badge.fury.io/rb/skinny_controllers)
[![Build Status](http://img.shields.io/travis/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://travis-ci.org/NullVoxPopuli/skinny_controllers)
[![Code Climate](http://img.shields.io/codeclimate/github/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Test Coverage](http://img.shields.io/codeclimate/coverage/github/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Dependency Status](http://img.shields.io/gemnasium/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://gemnasium.com/NullVoxPopuli/skinny_controllers)

An implementation of role-based policies and operations to help controllers lose weight.

The goal of this project is to help API apps be more slim, and separate logic as much as possible.

# Installation

```ruby
gem 'skinny_controllers'
```
or

`gem install skinny_controllers`

# Usage

In a controller:

```ruby
include SkinnyControllers::Diet
# ...
# in your action
render json: model
```

and that's it!

The above does a multitude of assumptions to make sure that you can type the least amount code possible.

1. Your controller name is based off your controller name
2. Any defined policies or operations follow the formats:
  - `Policy::#{Model.name}Policy`
  - `Operations::#{Model.name}`
3. Your model responds to `find`, and `where`
4. Your model responds to `is_accessible_to?`. This can be changed at `SkinnyControllers.accessible_to_method`

TODO: write a rake task that generates `app/policies` and `app/operations`.

Policies can be placed in `app/policies` of your rails app.

Operations can be placed in `app/operations` of your rails app.
