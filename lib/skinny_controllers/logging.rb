# frozen_string_literal: true
module SkinnyControllers
  module Logging
    extend ActiveSupport::Concern

    included do
      self.logger = Logger.new
    end

    class Logger
      attr_accessor :_logger
      attr_accessor :_tag
      def initialize
        @_logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
        @_tag = 'skinny_controllers'
      end

      def warn(*args)
        _logger.tagged(_tag) { _logger.warn(*args) }
      end

      def info(*args)
        _logger.tagged(_tag) { _logger.info(*args) }
      end
    end

    module ClassMethods
      attr_accessor :logger
    end
  end
end
