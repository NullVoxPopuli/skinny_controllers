# Configuration


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
| `search_proc`| passthrough | can be used to filter results, such as with using ransack |


## Configuring the Controller


```ruby
include SkinnyControllers::Diet
# ...
# in your action
render json: model
```

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

#### parent_class and association_name

If you want to scope the finding of a resource to a parent object, `parent_class` must be set

```ruby
skinny_controllers_config parent_class: ParentClass,
                          assaciation_name: :children,
                          model_class: Child
```

Given the above configuration in a controller, and a request with the params:

```
{
  id: 2,
  parent_id: 78  
}
```

The following query will be made:

```ruby
Parent.find(78).children.find(2)
```

#### model_params_key

Date stored another a different key in `params`?

```ruby
skinny_controllers_config model_class: Child,
                          model_params_key: :progeny
```

Given the above configuration in a controller, and a request with the params:

```
{
  progeny: {
    attribute1: 'value'
  }
}
```

The attributes inside the `progeny` sub hash will be used instead of the default, `child`.

### What if your model is namespaced?

All you have to do is set the `model_class`, and `model_key`.

```ruby
class ItemsController < ApiController # or whatever your superclass is
  include SkinnyControllers::Diet

  skinny_controllers_config model_class: NameSpace::Item
                            model_params_key: :item
end
```
`model_key` specifies the key to look for params when creating / updating the model.

Note that while `model_key` doesn't *have* to be specified, it would default to name_space/item. So, just keep that in mind.
