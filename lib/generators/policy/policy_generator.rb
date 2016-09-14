# frozen_string_literal: true
class PolicyGenerator < Rails::Generators::NamedBase
  # gives us file_name
  source_root File.expand_path('../templates', __FILE__)

  def generate_layout
    template 'policy.rb.erb', File.join('app/policies', class_path, "#{file_name}_policy.rb")
  end

  def policy_name
    operation_name + 'Policy'
  end

  def operation_name
    file_name.camelize
  end

  def controller_name
    operation_name.pluralize + 'Controller'
  end
end
