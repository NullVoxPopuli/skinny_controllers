module SkinnyControllers
  module Policy
    class Base
      attr_accessor :user, :object, :authorized_via_parent

      # @param [User] user the being to check if they have access to `object`
      # @param [ActiveRecord::Base] object the object that we are wanting to check
      #    the authorization of `user` for
      # @param [Boolean] authorized_via_parent if this object is authorized via
      #    a prior authorization from a parent class / association
      def initialize(user, object, authorized_via_parent: false)
        self.user = user
        self.object = object
        self.authorized_via_parent = authorized_via_parent
      end

      # if a method is not defined for a particular verb or action,
      # this will be used.
      #
      # @example Operation::Object::SendReceipt.run is called, since
      #    `send_receipt` doesn't exist in this class, this `default?`
      #    method will be used.
      def default?
        SkinnyControllers.allow_by_default
      end

      # this should be used when checking access to a single object
      def read?(o = object)
        o.send(accessible_method, user)
      end

      # this should be used when checking access to multilpe objects
      # it will call `read?` on each object of the array
      #
      # if the operation used a scope to find records from
      # an association, then `authorized_via_parent` could be true,
      # in which case, the loop would be skipped.
      #
      # TODO: think of a way to override the authorized_via_parent functionality
      def read_all?
        return true if authorized_via_parent
        # This is expensive, so try to avoid it
        # TODO: look in to creating a cache for
        # these look ups that's invalidated upon
        # object save
        accessible = object.map { |ea| read?(ea) }
        accessible.all?
      end

      def delete?
        read?
      end

      private

      def accessible_method
        SkinnyControllers.accessible_to_method
      end
    end
  end
end
