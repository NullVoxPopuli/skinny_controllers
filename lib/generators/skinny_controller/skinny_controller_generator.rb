# frozen_string_literal: true
class SkinnyControllerGenerator < Rails::Generators::NamedBase
  # gives us file_name
  source_root File.expand_path('../templates', __FILE__)

  def generate_layout
    template 'skinny_controller.rb.erb',
      File.join('app/controllers', class_path, "#{file_name}_controller.rb")
  end

  def operation_name
    file_name.camelize
  end

  def controller_name
    operation_name.pluralize + 'Controller'
  end

  def parent_class
    if defined?(::ApiController)
      'ApiController'
    elsif defined?(::APIController)
      'APIController'
    elsif defined?(::ApplicationController)
      'ApplicationController'
    else
      'ActionController::Base'
    end
  end
end
