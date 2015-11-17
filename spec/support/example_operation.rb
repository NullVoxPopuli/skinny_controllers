class ExampleOperation
  class << self
    def find(*_args)
      new
    end
  end

  def is_accessible_to?(_user)
    true # why not? :-)
  end
end
