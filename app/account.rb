require_relative 'user'
require_relative 'exceptions/insufficient_funds_exception'
require_relative 'exceptions/invalid_parameter_exception'
require 'securerandom'


class Account
  attr_reader :user, :id, :currencies
  attr_accessor :balance

  @@accounts = []

  def initialize(user)
    @@accounts << self

    @user = user
    @id = set_id
    @currencies = {
      uuid_generate => {BTC: 0},
      uuid_generate => {EUR: 0},
      uuid_generate => {USD: 0},
      uuid_generate => {GBP: 0}
    }
  end

  def self.all
    @@accounts
  end

  # Transfers money from account to account within one user.
  # Parameters :
  # 'amount' : transfer amount,
  # 'amount_currency': currency of the Amount field in the format BTC \ EUR \ USD \ GBP,
  # 'from_account' : UUID of the user account
  # 'to_account': UUID of the user account to which the transfer is made

  def exchange_transfers(amount, from_account, to_account)
    currency_from = get_the_currency_by_uuid(from_account)
    currency_to = get_the_currency_by_uuid(to_account)
    verification_of_funds!(amount, from_account, currency_from)
    exchange_rate = exchange_rate(currency_from, currency_to)
    fee = calc_fee(amount)
    @currencies[from_account][currency_from] -= amount + fee
    @currencies[to_account][currency_to] += amount * exchange_rate
  end

# #TODO: Form the body of request
#   def form_the_request
#     method = 'POST'
#     uri = 'https://sandbox.cryptopay.me/api/v2/exchange_transfers'
#     http = 'HTTP/1.1'
#
#     method + ' / ' + http + '\r\nHost: ' + uri + '\r\n\r\n'
#
#   end

  private

  def uuid_generate
    SecureRandom.uuid
  end

  def get_the_currency_by_uuid(uuid)
    @currencies[uuid].keys.first
  end

  def exchange_rate(amount_currency, to_account)
    rates = {BTC: {EUR: 1761.28, USD: 1966.08, GBP: 1582.53},
             EUR: {BTC: 0.00055, USD: 1.1184, GBP: 0.87314},
             USD: {BTC: 0.00047, EUR: 0.89413, GBP: 0.78070},
             GBP: {BTC: 0.00061, EUR: 1.1453, USD: 1.2809}}
    rates[amount_currency][to_account]
  end

  def calc_fee(amount)
    amount * 0.01
  end

  def verification_of_funds!(amount, uuid, currency)
    raise InvalidParameterException, 'Amount is nil' if amount.nil?
    raise InvalidParameterException, "Too small amount of funds (#{amount})" if amount < 0.1
    raise InvalidParameterException, "Amount = #{amount}" if amount.eql?(0)
    raise InvalidParameterException, "Amount has negative value = #{amount}" if amount < 0
    amount_currency = @currencies[uuid][currency]
    fee = calc_fee(amount)
    if amount_currency - fee - amount >= 0
      true
    else
      raise InsufficientFundsException, "Amount currency = #{amount_currency}, fee = #{fee}, amount = #{amount}"
    end
  end

  def set_id
    @@accounts.count
  end
end
