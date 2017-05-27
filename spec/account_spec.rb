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
    expect(@account.currencies).to_not be nil
  end

  context 'when a transfer to another account' do

    before(:each) do
      @btc_uuid = 0
      @eur_uuid = 0
      @usd_uuid = 0
      @gbp_uuid = 0
      @account.currencies.each {|uuid, hash| @btc_uuid = uuid if hash.key?(:BTC)}
      @account.currencies.each {|uuid, hash| @eur_uuid = uuid if hash.key?(:EUR)}
      @account.currencies.each {|uuid, hash| @usd_uuid = uuid if hash.key?(:USD)}
      @account.currencies.each {|uuid, hash| @gbp_uuid = uuid if hash.key?(:GBP)}
    end
    context 'and the subject account has sufficient funds' do

      before(:each) do
        @account.currencies.each_value {|purse| purse.each {|currency, fund| purse[currency] = fund + 50}}
      end

      it 'transfer to the other account successful' do
        expect(@account.exchange_transfers(25, @btc_uuid, @eur_uuid)).to be_truthy
      end

      it 'checking the receipt of funds to the account' do
        expect {@account.exchange_transfers(25, @btc_uuid, @eur_uuid)}.to change {@account.currencies[@eur_uuid][:EUR]}.from(50).to(44082.0)
      end

      it 'check for withdrawals made from account' do
        expect {@account.exchange_transfers(25, @btc_uuid, @eur_uuid)}.to change {@account.currencies[@btc_uuid][:BTC]}.from(50).to(24.75)
      end

      it 'checking lowest possible transfer funds amount' do
        expect(@account.exchange_transfers(0.1, @eur_uuid, @usd_uuid)).to be_truthy
      end
    end

    context 'and the subject account has not enough funds' do

      before(:each) do
        @account.currencies.each_value {|purse| purse.each {|currency, fund| purse[currency] = fund + 10}}
      end

      it 'transfer to the other account' do
        expect {@account.exchange_transfers(25, @btc_uuid, @eur_uuid)}.to raise_error(InsufficientFundsException)
      end

      it 'transfer to the other account amount = 0' do
        expect {@account.exchange_transfers(0, @usd_uuid, @eur_uuid)}.to raise_error(InvalidParameterException)
      end

      it 'transfer to the other account amount nil' do
        expect {@account.exchange_transfers(nil, @btc_uuid, @gbp_uuid)}.to raise_error(InvalidParameterException)
      end

      it 'transfer to the other account negative amount' do
        expect {@account.exchange_transfers(-25, @btc_uuid, @gbp_uuid)}.to raise_error(InvalidParameterException)
      end

      it 'checking lowest possible transfer funds amount exception' do
        expect {@account.exchange_transfers(0.09, @btc_uuid, @gbp_uuid)}.to raise_error(InvalidParameterException)
      end

    end
   end
end
