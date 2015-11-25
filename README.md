# skinny-controllers
[![Gem Version](https://badge.fury.io/rb/skinny_controllers.svg)](https://badge.fury.io/rb/skinny_controllers)
[![Build Status](https://travis-ci.org/NullVoxPopuli/skinny_controllers.svg?branch=master)](https://travis-ci.org/NullVoxPopuli/skinny_controllers)
[![Code Climate](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/badges/gpa.svg)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Test Coverage](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/badges/coverage.svg)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/coverage)
[![Dependency Status](https://gemnasium.com/NullVoxPopuli/skinny_controllers.svg)](https://gemnasium.com/NullVoxPopuli/skinny_controllers)

An implementation of role-based policies and operations to help controllers lose weight.

The goal of this project is to help API apps be more slim, and separate logic as much as possible.

This gem is inspired by [trailblazer](https://github.com/apotonick/trailblazer), following similar patterns, yet allowing the structure of the rails app to not be entirely overhauled.

Please note that this is a work in progress, and that the defaults are subject to change. If you have an idea or suggestion for improved defaults, please submit an issue or pull request. :-)

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
  - `class #{Model.name}Policy`
  - `module #{Model.name}Operations`
3. Your model responds to `find`, and `where`
4. Your model responds to `is_accessible_to?`. This can be changed at `SkinnyControllers.accessible_to_method`
5. If relying on the default / implicit operations for create and update, the params key for your model's changes much be formatted as `{ Model.name.underscore => { attributes }}``
6. If using strong parameters, SkinnyControllers will look for `{action}_{model}_params` then `{model}_params` and then `params`. See the `strong_parameters_spec.rb` test to see an example.

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


### What if you want to call your own operations?

Sometimes, magic is scary. You can call anything you want manually (operations and policies).

Here is an example that manually makes the call to the Host Operations and passes the subdomain parameter in to filter the `Host` object on the subdomain.
```ruby
def show
  render json: host_from_subdomain, serializer: each_serializer
end

private

def host_from_subdomain
  @host ||= HostOperations::Read.new(current_user, host_params).run
end
  
def host_params
  params.permit(:subdomain)
end
```

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

### Creating

To achieve default functionality, this operation *may* be defined -- though, it is implicitly assumed to function this way if not defined.
```ruby
module UserOperations
  class Create < SkinnyControllers::Operation::Base
    def run
      return unless allowed?
      @model = model_class.new(model_params)
      @model.save
      @model # or just `model`
    end
  end
end
```

### Updating
```ruby
module UserOperations
  class Create < SkinnyControllers::Operation::Base
    def run
      return unless allowed?
      model.update(model_params)
      model
    end
  end
end
```

### Deleting

Goal: Users should only be able to delete themselves

To achieve default functionality, this operation *may* be defined -- though, it is implicitly assumed to function this way if not defined.
```ruby
module UserOperations
  class Delete < SkinnyControllers::Operation::Base
    def run
      model.destroy if allowed?
    end
  end
end
```

And given that this method exists on the `User` model:
```ruby
# realistically, you'd only want users to be able to access themselves
def is_accessible_to?(user)
  self.id == user.id
end
```

Making a call to the destroy action on the `UsersController` will only succeed if the user trying to delete themselves. (Possibly to 'cancel their account')


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
