
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
