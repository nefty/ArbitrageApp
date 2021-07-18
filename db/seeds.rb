# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Exchange.create(name: 'forex')

Currency.create([{ name: 'US Dollars', code: 'USD', exchange_id: 1 },
                 { name: 'Great British Pounds', code: 'GBP', exchange_id: 1 }])

CurrencyPair.create([{base_currency: 1, quote_currency: 2, exchange_rate: 2, exchange: Exchange.find(1)},
                     {base_currency: 2, quote_currency: 1, exchange_rate: 0.75, exchange: Exchange.find(1)}])

Opportunity.create()

Trade.create([{opportunity: Opportunity.find(1), currency_pair: CurrencyPair.find(1), order: 0 },
              {opportunity: Opportunity.find(1), currency_pair: CurrencyPair.find(2), order: 1 }])
