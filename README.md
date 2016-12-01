# skinny_controllers

_skinny_controllers is a thin layer on top of rails with the goal of allowing for much easier unit-testability, inspired by ember_

A demo app can be found [in the spec here](https://github.com/NullVoxPopuli/skinny_controllers/tree/master/spec/support/rails_app).

[![Join the chat at https://gitter.im/NullVoxPopuli/skinny_controllers](https://badges.gitter.im/NullVoxPopuli/skinny_controllers.svg)](https://gitter.im/NullVoxPopuli/skinny_controllers?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Gem Version](https://badge.fury.io/rb/skinny_controllers.svg)](https://badge.fury.io/rb/skinny_controllers)
[![Build Status](https://travis-ci.org/NullVoxPopuli/skinny_controllers.svg?branch=master)](https://travis-ci.org/NullVoxPopuli/skinny_controllers)
[![Code Climate](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/badges/gpa.svg)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers)
[![Test Coverage](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/badges/coverage.svg)](https://codeclimate.com/github/NullVoxPopuli/skinny_controllers/coverage)
[![Dependency Status](https://gemnasium.com/NullVoxPopuli/skinny_controllers.svg)](https://gemnasium.com/NullVoxPopuli/skinny_controllers)

An implementation of role-based policies and operations to help controllers lose weight.

The goal of this project is to help API apps be more slim, and separate logic as much as possible.

If you have an idea or suggestion for improved defaults, please submit an issue or pull request. :-)

# Overview

- Controllers _only_ contain render logic. Typically, `render json: model`
- Business logic is encapsulated in operations.
  - Without creating any new classes, `render json: model` will give you default CRUD functionality in your controller actions.
  - There is one operation per controller action.
- Policies help determine whether or not the `current_user` is allowed to perform an action on an object.
- [Click here to see how this is different from trailblazer](https://github.com/NullVoxPopuli/skinny_controllers#how-is-this-different-from-trailblazer)


# Installation

```ruby
gem 'skinny_controllers'
```
or

```bash
gem install skinny_controllers
```


## Generators

```bash
rails g operation event_summary
# => create  app/operations/event_summary_operations.rb

rails g policy event_summary
# create  app/policies/event_summary_policy.rb

rails g skinny_controller event_summaries
# create  app/controllers/event_summaries_controller.rb
```

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

1. Your controller name is the name of your _resource_.
2. Any defined policies or operations follow the formats (though they don't have to exist):
  - `class #{resource_name}Policy`
  - `module #{resource_name}Operations`
3. Your model responds to `find`, and `where`
4. If relying on the default / implicit operations for create and update, the params key for your model's changes much be formatted as `{ Model.name.underscore => { attributes }}`
5. If using strong parameters, SkinnyControllers will look for `{action}_{model}_params` then `{model}_params` and then `params`. See the `strong_parameters_spec.rb` test to see an example.

### Per Controller Configuration

```ruby
skinny_controllers_config model_class: AClass,
                          parent_class: ParentClass,
                          asociation_name: :association_aclasses,
                          model_params_key: :aclass
```

#### model_class
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

  skinny_controllers_config model_class: Event

  def index
    render json: model, each_serializer: EventSummariesSerializer
  end

  def show
    render json: model, serializer: EventSummariesSerializer
  end
end
```

Note that `each_serializer` and `serializer` is not part of `SkinnyControllers`, and is part of [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers).

Also note that setting `model_class` may be required if your model is namespaced.

#### parent_class

#### association_name

#### model_params_key


### What if your model is namespaced?

All you have to do is set the `model_class`, and `model_key`.

```ruby
class ItemsController < ApiController # or whatever your superclass is
  include SkinnyControllers::Diet
  self.model_class = NameSpace::Item
  self.model_key = 'item'
end
```
`model_key` specifies the key to look for params when creating / updating the model.

Note that while `model_key` doesn't *have* to be specified, it would default to name_space/item. So, just keep that in mind.

### What if you want to call your own operations?

Sometimes, magic is scary. You can call anything you want manually (operations and policies).

Here is an example that manually makes the call to the Host Operations and passes the subdomain parameter in to filter the `Host` object on the subdomain.
```ruby
def show
  render json: host_from_subdomain, serializer: each_serializer
end

private

def host_from_subdomain
  @host ||= HostOperations::Read.new(current_user, params, host_params).run
end

def host_params
  params.permit(:subdomain)
end
```

The parameters for directly calling an operation are as follows:

| # | Parameter | Default when directly calling an operation | Implicit default | Purpose |
|---|-------------------|--------------------------------------------|------------------------------|------------------------------------------|
| 0 | current_user | n/a | `current_user` | the user performing the action |
| 1 | controller_params | n/a | `params` | the full params hash from the controller |
| 2 | params_for_action | `controller_params` | `create_params`, `index_params`, etc |  e.g.: requiring a foreign key when looking up index |
| 3 | action | `controller_params[:action]` | `action_name` | the name of the current action |
| 4 | options | `{}` | skinny_controllers_config options |

### For JSON-API

Strong parameters must be used on create/update actions.

Here is an example params method

```ruby
private

def event_params
  params
    .require(:data)
    .require(:attributes)
    .permit(:name)
end
```

Note that we don't need the id under the data hash, because in a RESTful api, the id will be available to us through the top level params hash.


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
      @model = model_class.new(model_params)

      # raising an exception here allows the corresponding resource controller to
      # `rescue_from SkinnyControllers::DeniedByPolicy` and have a uniform error
      # returned to the frontend
      raise SkinnyControllers::DeniedByPolicy.new('Something Horrible') unless allowed?

      @model.save
      return @model # or just `model`
    end
  end
end
```

### Updating
```ruby
module UserOperations
  class Update < SkinnyControllers::Operation::Base
    def run
      # this throws a DeniedByPolicy exception if `allowed?` returns false
      check_allowed!

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

NOTE: `allowed?` is `true` by default via the `SkinnyControllers.allow_by_default` option.

## Defining Policies

Policies should be placed in `app/policies` of your rails app.
These are where you define your access logic, and how to decide if a user has access to the `object`

```ruby
class EventPolicy < SkinnyControllers::Policy::Base
  def read?(event = object)
    event.user == user
  end
end
```


## More Advanced Usage

These are snippets taking from other projects.

### Finding a record when the id parameter isn't passed

```ruby
module HostOperations
  class Read < SkinnyControllers::Operation::Base
    def run
       # always allowed, never restricted
       # (because there is now call to allowed?)
      model
    end

    # the params to this method should include the subdomain
    # e.g.: { subdomain: 'swingin2015' }
    def model_from_params
      subdomain = params[:subdomain]
      host = Host.find_by_subdomain(subdomain)
    end
  end
end
```

### The built in model-finding methods can be completely ignored

The `model` method does not need to be overridden. `run` is what is called on the operation.

```ruby
module MembershipRenewalOperations
  # MembershipRenewalsController#index
  class ReadAll < SkinnyControllers::Operation::Base

    def run
      # default 'model' functionality is avoided
      latest_renewals
    end

    private

    def organization
      id = params[:organization_id]
      Organization.find(id)
    end

    def renewals
      options = organization.membership_options.includes(renewals: [:user, :membership_option])
      options.map(&:renewals).flatten
    end

    def latest_renewals
      sorted_renewals = renewals.sort_by{|r| [r.user_id,r.updated_at]}.reverse

      # unique picks the first option.
      # so, because the list is sorted by user id, then updated at,
      # for each user, the first renewal will be chosen...
      # and because it is descending, that means the most recent renewal
      sorted_renewals.uniq { |r| r.user_id }
    end
  end

end
```

### Updating / Deleting the current_user

This is something you could do if you always know your model ahead of time.

```ruby
module UserOperations
  class Update < SkinnyControllers::Operation::Base
    def run
      return unless allowed_for?(current_user)
      # update with password provided by Devise
      current_user.update_with_password(model_params)
      current_user
    end
  end

  class Delete < SkinnyControllers::Operation::Base
    def run
      if allowed_for?(current_user)
        if current_user.upcoming_events.count > 0
          current_user.errors.add(
            :base,
            "You cannot delete your account when you are about to attend an event."
          )
        else
          current_user.destroy
        end

        current_user
      end
    end
  end

end
```

## Testing

The whole goal of this project is to minimize the complexity or existence of controller tests, and provide
a way to unit test business logic.

In the following examples, I'll be using RSpec -- but there isn't anything that would prevent you from using a different testing framework, if you so choose.

### Operations

```ruby
describe HostOperations do
  describe HostOperations::Read do
    context 'model_from_params' do
      let(:subdomain){ 'subdomain' }
      # an operation takes a user, and a list of params
      # there are optional parameters as well, but generally may not be required.
      # see: `SkinnyControllers:::Operation::Base`
      let(:operation){ HostOperations::Read.new(nil, { subdomain: subdomain }) }

      it 'finds an event' do
        host = create(:host, domain: subdomain)
        model = operation.run
        expect(model).to eq host
      end
      #...
```

### Policies

With policies, I like to test using Procs, because the setup is the same for most actions, and it's easier to set up different scenarios.

```ruby
describe PackagePolicy do
  # will test if the owner of this object can access it
  let(:by_owner){
    ->(method){
      package = create(:package)
      # a policy takes a user and an object
      policy = PackagePolicy.new(package.event.hosted_by, package)
      policy.send(method)
    }
  }

  # will test if the person registering with this package has permission
  let(:by_registrant){
    ->(method){
      event = create(:event)
      package = create(:package, event: event)
      attendance = create(:attendance, host: event, package: package)
      # a policy takes a user and an object
      policy = PackagePolicy.new(attendance.attendee, package)
      policy.send(method)
    }
  }

  context 'can be read?' do
    it 'by the event owner' do
      result = by_owner.call(:read?)
      expect(result).to eq true
    end

    it 'by a registrant' do
      result = by_registrant.call(:read?)
      expect(result).to eq true
    end
  end

  context 'can be updated?' do
    it 'by the event owner' do
      result = by_owner.call(:update?)
      expect(result).to eq true
    end

    it 'by a registrant' do
      result = by_registrant.call(:update?)
      expect(result).to eq false
    end
  end
```


## Globally Configurable Options

The following options are available:

|Option|Default|Note|
|------|-------|----|
|`operations_namespace` | '' | Optional namespace to put all the operations in. |
|`operations_suffix`|`'Operations'` | Default suffix for the operations namespaces. |
|`policy_suffix`|`'Policy'`  | Default suffix for policies classes. |
|`controller_namespace`|`''`| Global Namespace for all controllers (e.g.: `'API'`) |
|`allow_by_default`| `true` | Default permission |
|`action_map`| see [skinny_controllers.rb](./lib/skinny_controllers.rb#L61)| |


-------------------------------------------------------

## How is this different from trailblazer?

This may not be horribly apparent, but here is a table overviewing some highlevel differences

| Feature | - | skinny_controllers | [trailblazer](https://github.com/apotonick/trailblazer) |
|----|----|----|----|
| Purpose |-| API - works very well with [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers)| General - additional featers for server-side rendered views |
| Added Layers |-| Operations, Policies | Operations, Policies, Forms |
| Validation |-| stay in models | moved to operations via contract block |
| Additional objects|-| none | contacts, representers, callbacks, cells |
| Rendering |-|  done in the controller, and up to the dev to decide how that is done. `ActiveModel::Serializers` with JSON-API is highly recommended |-| representers provide a way to define serializers for json, xml, json-api, etc |
| App Structure |-|  same as rails. `app/operations` and `app/policies` are added | encourages a new structure 'concepts', where cells, view templates, assets, operations, etc are all under `concepts/{model-name}` |
