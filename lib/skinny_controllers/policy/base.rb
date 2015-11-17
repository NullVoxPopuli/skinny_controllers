module SkinnyControllers
  module Policy
    class Base
      attr_accessor :user, :object, :authorized_via_parent

      def initialize(user, object, authorized_via_parent: false)
        self.user = user
        self.object = object
        self.authorized_via_parent = authorized_via_parent
      end

      def default?
        SkinnyControllers.allow_by_default
      end

      # defaults
      def read?(o = object)
        o.send(:accessible_method, user)
      end

      def read_all?
        return true if authorized_via_parent
        # This is expensive, so try to avoid it
        # TODO: look in to creating a cache for
        # these look ups that's invalidated upon
        # object save
        accessible = object.map { |ea| read?(ea) }
        accessible.all?
      end

      private

      def accessible_method
        SkinnyControllers.accessible_to_method
      end
    end
  end
end
