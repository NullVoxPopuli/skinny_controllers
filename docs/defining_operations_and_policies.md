## Defining Operations and Policies

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
      @model = User.new(model_params)

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

### Using ransack

```ruby
# config/initializers/skinny_controllers.rb
SkinnyControllers.search_proc = lambda do |relation|
  relation.ransack(params[:q]).result
end
```

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
