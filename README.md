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

# Usage

## In a controller:

```ruby
include SkinnyControllers::Diet
# ...
# in your action
render json: model
```

and that's it!


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

-------------------------------------------------------

## How is this different from trailblazer?

This may not be horribly apparent, but here is a table overviewing some highlevel differences

| Feature | - | skinny_controllers | [trailblazer](https://github.com/apotonick/trailblazer) |
|----|----|----|----|
| Purpose |-| API - works very well with [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers)| General - additional features for server-side rendered views |
| Added Layers |-| Operations, Policies | Operations, Policies, Forms |
| Validation |-| stay in models | moved to operations via contract block |
| Additional objects|-| none | contacts, representers, callbacks, cells |
| Rendering |-|  done in the controller, and up to the dev to decide how that is done. `ActiveModel::Serializers` with JSON-API is highly recommended |-| representers provide a way to define serializers for json, xml, json-api, etc |
| App Structure |-|  same as rails. `app/operations` and `app/policies` are added | encourages a new structure 'concepts', where cells, view templates, assets, operations, etc are all under `concepts/{model-name}` |


# Contributing

Please refer to each project's style guidelines and guidelines for submitting patches and additions. In general, we follow the "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes
