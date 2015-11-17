# 2cool4 ActionController::Base
class FakeController
  # http://www.rubydoc.info/docs/rails/2.3.8/ActionController%2FBase%3Aaction_name
  def action_name
    'index'
  end

  def current_user
    @current_user ||= User.new
  end

  # kinda:
  # http://api.rubyonrails.org/classes/ActionController/Parameters.html
  def params
    {}
  end
end
