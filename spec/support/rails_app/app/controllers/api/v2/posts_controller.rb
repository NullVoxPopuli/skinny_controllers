module Api
  module V2
    class PostsController < ApplicationController
      include SkinnyControllers::Diet

      def create
        render json: model
      end
    end
  end
end
