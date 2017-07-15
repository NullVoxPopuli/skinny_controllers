module Api
  module V2
    class CommentsController < ApplicationController
      include SkinnyControllers::Diet

      def create
        render json: model
      end
    end
  end
end
