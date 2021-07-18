require 'rest-client'
require 'json'

class FindOpportunitiesJob < ApplicationJob
  queue_as :default

  def perform()

    api_url = 'https://v6.exchangerate-api.com/v6/1098f03436a94e89a0844b1e'

    # If there is no currency in the database, GET the list of currencies from API
    unless BaseCurrency.find_by(code: 'USD')
      response = RestClient.get "#{api_url}/codes"
      currencies = JSON.parse(response)
      currencies['supported_codes'].each do |currency|
        currency_code = currency[0]
        currency_name = currency[1]
        BaseCurrency.create(name: currency_name, code: currency_code)
        QuoteCurrency.create(name: currency_name, code: currency_code)
      end
    end

    pairs_exist = CurrencyPair.find_by(base_currency: BaseCurrency.find_by(code: 'USD'),
                                quote_currency: QuoteCurrency.find_by(code: 'GBP'))
    exchange = Exchange.first
    BaseCurrency.all.each do |base_currency|
      result = RestClient.get "#{api_url}/latest/#{base_currency.code}"
      rates = JSON.parse(result)
      rates['conversion_rates'].each do |currency_code, exchange_rate|
        quote_currency = QuoteCurrency.find_by(code: currency_code)
        if pairs_exist
          pair = CurrencyPair.find_by(base_currency: base_currency, quote_currency: quote_currency)
          pair.update(exchange_rate: exchange_rate)
        else
          CurrencyPair.create(exchange: exchange, base_currency: base_currency,
                              quote_currency: quote_currency, exchange_rate: exchange_rate)
        end
      end
    end

    puts 'The FindOpportunitiesJob just executed! Hooray!'
    
    # self.set(wait_until: Time.now + (60 * 60 * 24)).perform_later
  end
end
