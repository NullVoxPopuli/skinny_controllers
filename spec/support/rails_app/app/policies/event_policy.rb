# frozen_string_literal: true
class EventPolicy < SkinnyControllers::Policy::Base
  def read?(_o = object)
    # for testing, in real life, this is implicit, and
    # the method does not even need to be defined
    true
  end

  def throw_away?
    # for testing action => verb translation
    #
    # default is true, so if the model is not returned,
    # then the test was a success
    false
  end
end
