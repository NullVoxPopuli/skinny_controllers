# frozen_string_literal: true
class OperationGenerator < Rails::Generators::NamedBase
  # gives us file_name
  source_root File.expand_path('../templates', __FILE__)

  def generate_layout
    template 'operation.rb.erb', File.join('app/operations', class_path, "#{file_name}_operations.rb")
  end

  def operation_name
    file_name.camelize
  end

  def controller_name
    operation_name.pluralize + 'Controller'
  end
end
