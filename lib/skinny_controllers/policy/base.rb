# frozen_string_literal: true
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

      # @param [Symbol] method_name
      # @param [Array] args
      # @param [Proc] block
      def method_missing(method_name, *args, &block)
        # unless the method ends in a question mark, re-route to default method_missing
        return super unless method_name.to_s =~ /(.+)\?/

        action = Regexp.last_match(1)
        # alias destroy to delete
        # TODO: this means that a destroy method, if defined,
        #       will never be called.... good or bad?
        #       should there be a difference between delete and destroy?
        return send('delete?') if action == 'destroy'

        # we know that these methods don't take any parameters,
        # so args and block can be ignored
        SkinnyControllers.logger.warn("method '#{action}' in policy '#{self.class.name}' was not found. Using :default?")
        send(:default?)
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s =~ /(.+)\?/ || super
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
        default?
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

        # Might be deceptive...
        return true if object.nil? || object.empty?

        # This is expensive, so try to avoid it
        # TODO: look in to creating a cache for
        # these look ups that's invalidated upon
        # object save
        accessible = object.map { |ea| read?(ea) }
        accessible.all?
      end
    end
  end
end
