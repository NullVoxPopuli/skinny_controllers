# frozen_string_literal: true
module SkinnyControllers
  module Policy
    class AllowAll < Base
      def default?
        true
      end

      def read?
        true
      end

      def read_all?
        true
      end
    end
  end
end
