require_relative 'account'

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
      raise RuntimeError, 'So young!' if user_age < 18
      @age = user_age
  end
end
