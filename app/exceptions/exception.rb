class Exception < StandardError
  attr_reader :obj

  def initialize(message, obj)
    @obj = obj
    super(message)
  end
end
