require_relative 'user'

class Account
  attr_reader :user, :id
  attr_accessor :balance

  @@accounts = []

  def initialize(user)
    @@accounts << self

    @user = user
    @balance = 0
    @id = set_id
  end

  def self.all
    @@accounts
  end

  def transfer(to_account, amount)
    raise RuntimeError, "Wrong argument, amount = #{amount} !" if amount <= 0
    if @balance - amount >= 0
      to_account.balance += amount
      @balance -= amount
    else
      raise RuntimeError, "Transfer from #{self.id} to #{to_account.id} was interrupted, insufficient funds."
    end
  end

  private

  def set_id
    @@accounts.count
  end
end
