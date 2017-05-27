require_relative '../app/account'
require_relative '../app/user'
require 'rspec'

RSpec.describe 'Account' do
  before(:each) do
    @user = User.new('Vasya', 'Ivanov', 18)
    @account = @user.account
  end

  it 'belongs to the user' do
    expect(@account.user).to be(@user)
  end

  it 'has list of accounts' do
    expect(Account.all).to include(@account)
  end

  it 'should has an ID' do
    expect(@account.id).to_not be_falsey
  end

  it 'has a balance in the start' do
    expect(@account.balance).to be 0
  end

  context 'when a transfer to another account' do

    before(:all) do
      @other_user = User.new('Petya', 'Petrov', 25)
      @other_account = @other_user.account
    end

    context 'and the subject account has sufficient funds' do

      before(:each) do
        @account.balance = 50
      end

      it 'transfer to the other account' do
        expect(@account.transfer(@other_account, 50)).to be_truthy
      end

      it 'transfer from the other account' do
        expect(@other_account.transfer(@account, 50)).to be_truthy
      end
    end

    context 'and the subject account has not enough funds' do

      it 'transfer to the other account' do
        expect {@account.transfer(@other_account, 50)}.to raise_error(RuntimeError)
      end

      it 'transfer to the other account amount nil' do
        expect {@account.transfer(@other_account, 0)}.to raise_error(RuntimeError)
      end
    end
  end
end
