class ExampleOperation
  class << self
    def find(*args)
      self.new
    end
  end

  def is_accessible_to?(_user)
    true # why not? :-)
  end
end
