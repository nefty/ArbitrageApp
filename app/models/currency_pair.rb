class CurrencyPair < ApplicationRecord
  belongs_to :exchange
  belongs_to :base_currency
  belongs_to :quote_currency  
end
