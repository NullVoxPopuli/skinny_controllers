# frozen_string_literal: true
module SkinnyControllers
  module Policy
    class DenyAll < Base
      def default?
        false
      end

      def read?
        false
      end

      def read_all?
        false
      end
    end
  end
end
