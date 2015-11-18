# skinny-controllers
[![Gem Version](http://img.shields.io/gem/v/skinny_controllers.svg?style=flat-square)](http://badge.fury.io/rb/skinny_controllers)
[![Build Status](http://img.shields.io/travis/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://travis-ci.org/NullVoxPopuli/skinny_controllers)
[![Code Climate](http://img.shields.io/codeclimate/github/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Test Coverage](http://img.shields.io/codeclimate/coverage/github/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Dependency Status](http://img.shields.io/gemnasium/NullVoxPopuli/skinny_controllers.svg?style=flat-square)](https://gemnasium.com/NullVoxPopuli/skinny_controllers)

An implementation of role-based policies and operations to help controllers lose weight.

The goal of this project is to help API apps be more slim, and separate logic as much as possible.

This gem is inspired by [trailblazer](https://github.com/apotonick/trailblazer), following similar patterns, yet allowing the structure of the rails app to not be entirely overhauled.

# Installation

```ruby
gem 'skinny_controllers'
```
or

`gem install skinny_controllers`

# Usage

## In a controller:

```ruby
include SkinnyControllers::Diet
# ...
# in your action
render json: model
```

and that's it!

The above does a multitude of assumptions to make sure that you can type the least amount code possible.

1. Your controller name is based off your model name (configurable per controller)
2. Any defined policies or operations follow the formats (though they don't have to exist):
  - `#{Model.name}Policy`
  - `#{Model.name}Operations`
3. Your model responds to `find`, and `where`
4. Your model responds to `is_accessible_to?`. This can be changed at `SkinnyControllers.accessible_to_method`

### Your model name might be different from your resource name
Lets say you have a JSON API resource that you'd like to render that has some additional/subset of data.
Maybe the model is an `Event`, and the resource an `EventSummary` (which could do some aggregation of `Event` data).

The naming of all the objects should be as follows:
 - `EventSummariesController`
 - `EventSummaryOperations::*`
 - `EventSummaryPolicy`
 - and the model is still `Event`

In `EventSummariesController`, you would make the following additions:
```ruby
class EventSummariesController < ApiController # or whatever your superclass is
  include SkinnyControllers::Diet
  self.model_class = Event

  def index
    render json: model, each_serializer: EventSummariesSerializer
  end

  def show
    render json: model, serializer: EventSummariesSerializer
  end
end
```
Note that `each_serializer` and `serializer` is not part of `SkinnyControllers`, and is part of [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers).

## Defining Operations

Operations should be placed in `app/operations` of your rails app.

For operations concerning an `Event`, they should be under `app/operations/event_operations/`.

Using the example from the specs:
```ruby
module EventOperations
  class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end
end
```

alternatively, all operation verbs can be stored in the same file under (for example) `app/operations/user_operations.rb`

```ruby
module UserOperations
  class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end

  class ReadAll < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end
end
```


## Defining Policies

Policies should be placed in `app/policies` of your rails app.
These are where you define your access logic, and how to decide if a user has access to the `object`

```ruby
class EventPolicy < SkinnyControllers::Policy::Base
  def read?(o = object)
    o.is_accessible_to?(user)
  end
end
```


## Globally Configurable Options

All of these can be set on `SkinnyControllers`,
e.g.:
```ruby
SkinnyControllers.controller_namespace = 'API'
```

The following options are available:

|Option|Default|Note|
|------|-------|----|
|`operations_namespace` | '' | Optional namespace to put all the operations in. |
|`operations_suffix`|`'Operations'` | Default suffix for the operations namespaces. |
|`policy_suffix`|`'Policy'`  | Default suffix for policies classes. |
|`controller_namespace`|`''`| Global Namespace for all controllers (e.g.: `'API'`) |
|`allow_by_default`| `true` | Default permission |
|`accessible_to_method`|`is_accessible_to?`| method to call an the object that the user might be able to access |
|`accessible_to_scope`| `accessible_to`| scope / class method on an object that the user might be able to access |
|`action_map`| see [skinny_controllers.rb](./lib/skinny_controllers.rb#L61)| |


## TODO

 - Configurable Error Renderer
   - Default to JSON API format errors?
