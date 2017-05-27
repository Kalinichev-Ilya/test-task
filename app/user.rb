require_relative 'account'
require_relative 'exceptions/insufficient_age_exception'

class User
  attr_reader :name, :lname, :fullname, :age, :account

  def initialize(name, lname, user_age)
    @name = name
    @lname = lname
    validate_age(user_age)
    @fullname = name + ' ' + lname
    @account = Account.new(self)
  end

  private

  def validate_age(user_age)
    raise InsufficientAgeException, "So young! Age = #{user_age}, must be >= 18." if user_age < 18
    @age = user_age
  end
end
