require_relative '../app/user'
require_relative '../app/account'
require_relative '../app/exceptions/insufficient_age_exception'

require 'rspec'

describe User do
  before(:all) do
    @user = User.new("Vasya", "Ivanov", 18)
    @account = @user.account
  end

  it 'has a fullname' do
    expect(@user.fullname).to eq "Vasya" + " " + "Ivanov"
  end

  it 'is younger then 18' do
    expect {User.new("Ivan", "Ivanov", 10)}.to raise_error(InsufficientAgeException)
  end

  it 'has an account' do
    expect(@account.user).to be @user
    expect(@user.account).to be @account
  end
end
